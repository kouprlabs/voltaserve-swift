// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

@testable import Voltaserve
import XCTest

final class FileTests: XCTestCase {
    var factory: DisposableFactory?

    func testFileFlow() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))

        /* Create files */
        var options: [VOFile.CreateFileOptions] = []
        for index in 0 ..< 6 {
            options.append(.init(
                workspaceID: workspace.id,
                name: "Test File \(index).txt",
                data: Data("Test Content \(index)".utf8)
            ))
        }
        var files: [VOFile.Entity] = []
        for index in 0 ..< options.count {
            try await files.append(factory.file(options[index]))
        }

        /* Test creation */
        for index in 0 ..< files.count {
            XCTAssertEqual(files[index].name, options[index].name)
            XCTAssertEqual(files[index].workspaceID, options[index].workspaceID)
            XCTAssertEqual(files[index].permission, .owner)
        }

        /* Test list */

        /* Page 1 */
        let page1 = try await client.fetchList(workspace.rootID, options: .init(page: 1, size: 3))
        XCTAssertGreaterThanOrEqual(page1.totalElements, options.count)
        XCTAssertEqual(page1.page, 1)
        XCTAssertEqual(page1.size, 3)
        XCTAssertEqual(page1.data.count, page1.size)

        /* Page 2 */
        let page2 = try await client.fetchList(workspace.rootID, options: .init(page: 2, size: 3))
        XCTAssertGreaterThanOrEqual(page2.totalElements, options.count)
        XCTAssertEqual(page2.page, 2)
        XCTAssertEqual(page2.size, 3)
        XCTAssertEqual(page2.data.count, page2.size)

        /* Test fetch */
        let file = try await client.fetch(files[0].id)
        XCTAssertEqual(file.name, files[0].name)
        XCTAssertEqual(file.workspaceID, files[0].workspaceID)

        /* Test patch name */
        let newName = "New File.txt"
        let resultAlpha = try await client.patchName(file.id, options: .init(name: newName))
        XCTAssertEqual(resultAlpha.name, newName)
        let fileAlpha = try await client.fetch(file.id)
        XCTAssertEqual(fileAlpha.name, newName)

        /* Test delete */
        for file in files {
            try await client.delete(file.id)
        }
        for file in files {
            do {
                _ = try await client.fetch(file.id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "file_not_found")
            } catch {
                XCTFail("Invalid error: \(error)")
            }
        }
    }

    func testUserPermissionsFlow() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        guard let otherFactory = try? await DisposableFactory.withOtherCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.file
        let otherClient = otherFactory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))
        let folder = try await factory.folder(.init(workspaceID: workspace.id, name: "Test Folder"))

        /* Send invitation and accept it */

        let otherUser = try await otherFactory.client.authUser.fetch()
        try await factory.client.invitation.create(.init(
            organizationID: organization.id,
            emails: [otherUser.email]
        ))
        let incomingInvitations = try await otherFactory.client.invitation.fetchIncoming(.init(size: 5))
        try await otherFactory.client.invitation.accept(incomingInvitations.data.first!.id)

        /* Grant permission to the other user */

        try await client.grantUserPermission(.init(ids: [folder.id], userID: otherUser.id, permission: .editor))

        /* Test the other user has the permission */

        let permissions = try await client.fetchUserPermissions(folder.id)
        XCTAssertEqual(permissions.count, 1)
        XCTAssertEqual(permissions.first!.user.id, otherUser.id)
        XCTAssertEqual(permissions.first!.permission, .editor)

        /* Test the other user can access the file */

        let folderAgain = try await otherClient.fetch(folder.id)
        XCTAssertEqual(folderAgain.id, folder.id)
        XCTAssertEqual(folderAgain.permission, .editor)

        /* Revoke permission from the other user */

        try await client.revokeUserPermission(.init(ids: [folder.id], userID: otherUser.id))

        /* Test the other user no longer has the permission */

        let newPermissions = try await client.fetchUserPermissions(folder.id)
        XCTAssertEqual(newPermissions.count, 0)

        /* Test the other user can no longer access the file */

        do {
            _ = try await otherClient.fetch(folder.id)
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, "file_not_found")
        } catch {
            XCTFail("Invalid error: \(error)")
        }
    }

    func testGroupPermissionsFlow() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        guard let otherFactory = try? await DisposableFactory.withOtherCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.file
        let otherClient = otherFactory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))
        let group = try await factory.group(.init(name: "Test Group", organizationID: organization.id))
        let folder = try await factory.folder(.init(workspaceID: workspace.id, name: "Test Folder"))

        /* Send invitation and accept it */

        let otherUser = try await otherFactory.client.authUser.fetch()
        try await factory.client.invitation.create(.init(
            organizationID: organization.id,
            emails: [otherUser.email]
        ))
        let incomingInvitations = try await otherFactory.client.invitation.fetchIncoming(.init(size: 5))
        try await otherFactory.client.invitation.accept(incomingInvitations.data.first!.id)

        /* Add the other user to the group */

        try await factory.client.group.addMember(group.id, options: .init(userID: otherUser.id))

        /* Grant permission to the group */

        try await client.grantGroupPermission(.init(ids: [folder.id], groupID: group.id, permission: .editor))

        /* Test the group has the permission */

        let permissions = try await client.fetchGroupPermissions(folder.id)
        XCTAssertEqual(permissions.count, 1)
        XCTAssertEqual(permissions.first?.group.id, group.id)
        XCTAssertEqual(permissions.first?.permission, .editor)

        /* Test the other user can access the file */

        let folderAgain = try await otherClient.fetch(folder.id)
        XCTAssertEqual(folderAgain.id, folder.id)
        XCTAssertEqual(folderAgain.permission, .editor)

        /* Revoke permission from the group */

        try await client.revokeGroupPermission(.init(ids: [folder.id], groupID: group.id))

        /* Test the group no longer has the permission */

        let newPermissions = try await client.fetchGroupPermissions(folder.id)
        XCTAssertEqual(newPermissions.count, 0)

        /* Test the other user can no longer access the file */

        do {
            _ = try await otherClient.fetch(folder.id)
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, "file_not_found")
        } catch {
            XCTFail("Invalid error: \(error)")
        }
    }

    func testFetchPath() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))

        let folderA = try await factory.folder(.init(
            workspaceID: workspace.id,
            name: "Test Folder A"
        ))
        let folderB = try await factory.folder(.init(
            workspaceID: workspace.id,
            parentID: folderA.id,
            name: "Test Folder B"
        ))
        let folderC = try await factory.folder(.init(
            workspaceID: workspace.id,
            parentID: folderB.id,
            name: "Test Folder C"
        ))

        let path = try await client.fetchPath(folderC.id)
        XCTAssertEqual(path.count, 4)
    }

    func testFetchCount() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))

        for index in 0 ..< 3 {
            _ = try await factory.folder(.init(workspaceID: workspace.id, name: "Test Folder \(index)"))
        }

        let count = try await client.fetchCount(workspace.rootID)
        XCTAssertEqual(count, 3)
    }

    func testDeleteMany() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))

        var ids = [String]()
        for index in 0 ..< 3 {
            let folder = try await factory.folder(.init(workspaceID: workspace.id, name: "Test Folder \(index)"))
            ids.append(folder.id)
        }

        _ = try await client.delete(.init(ids: ids))
        for id in ids {
            do {
                _ = try await client.fetch(id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "file_not_found")
            } catch {
                XCTFail("Invalid error: \(error)")
            }
        }
    }

    func testCopy() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))

        let file = try await factory.file(.init(
            workspaceID: workspace.id,
            name: "Test File.txt",
            data: Data("Test Content".utf8)
        ))
        let folder = try await factory.folder(.init(workspaceID: workspace.id, name: "Test Folder"))

        let copiedFile = try await client.copy(file.id, to: folder.id)
        XCTAssertEqual(copiedFile.name, file.name)
        XCTAssertEqual(copiedFile.parentID, folder.id)

        do {
            _ = try await client.copy(file.id, to: workspace.rootID)
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, "file_with_similar_name_exists")
        } catch {
            XCTFail("Invalid error: \(error)")
        }
    }

    func testCopyMany() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))

        var files: [VOFile.Entity] = []
        for index in 0 ..< 3 {
            try await files.append(factory.file(.init(
                workspaceID: workspace.id,
                name: "Test File \(index).txt",
                data: Data("Test Content \(index)".utf8)
            )))
        }
        let folder = try await factory.folder(.init(workspaceID: workspace.id, name: "Test Folder"))

        let copyResult = try await client.copy(.init(sourceIDs: files.map(\.id), targetID: folder.id))
        XCTAssertEqual(copyResult.succeeded.count, files.count)
        XCTAssertEqual(copyResult.failed.count, 0)
        XCTAssertEqual(copyResult.new.count, files.count)
    }

    func testMove() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))

        let file = try await factory.file(.init(
            workspaceID: workspace.id,
            name: "Test File.txt",
            data: Data("Test Content".utf8)
        ))
        let folder = try await factory.folder(.init(workspaceID: workspace.id, name: "Test Folder"))

        let movedFile = try await client.move(file.id, to: folder.id)
        XCTAssertEqual(movedFile.parentID, folder.id)

        do {
            _ = try await factory.file(.init(
                workspaceID: workspace.id,
                name: "Test File.txt",
                data: Data("Test Content".utf8)
            ))
            _ = try await client.move(file.id, to: workspace.rootID)
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, "file_with_similar_name_exists")
        } catch {
            XCTFail("Invalid error: \(error)")
        }
    }

    func testMoveMany() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.file

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))

        var files: [VOFile.Entity] = []
        for index in 0 ..< 3 {
            try await files.append(factory.file(.init(
                workspaceID: workspace.id,
                name: "Test File \(index).txt",
                data: Data("Test Content \(index)".utf8)
            )))
        }
        let folder = try await factory.folder(.init(workspaceID: workspace.id, name: "Test Folder"))

        let moveResult = try await client.move(.init(sourceIDs: files.map(\.id), targetID: folder.id))
        XCTAssertEqual(moveResult.succeeded.count, files.count)
        XCTAssertEqual(moveResult.failed.count, 0)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }
}
