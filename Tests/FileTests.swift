// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

@testable import Voltaserve
import XCTest

final class FileTests: XCTestCase {
    let config = Config()
    var disposableOrganizations: [VOOrganization.Entity] = []
    var disposableGroups: [VOGroup.Entity] = []
    var disposableWorkspaces: [VOWorkspace.Entity] = []
    var disposableFiles: [VOFile.Entity] = []

    func testFileFlow() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

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
            try await files.append(createDisposableFile(clients.file, options: options[index]))
        }

        /* Test creation */
        for index in 0 ..< files.count {
            XCTAssertEqual(files[index].name, options[index].name)
            XCTAssertEqual(files[index].workspaceID, options[index].workspaceID)
            XCTAssertEqual(files[index].permission, .owner)
        }

        /* Test list */

        /* Page 1 */
        let page1 = try await clients.file.fetchList(workspace.rootID, options: .init(page: 1, size: 3))
        XCTAssertGreaterThanOrEqual(page1.totalElements, options.count)
        XCTAssertEqual(page1.page, 1)
        XCTAssertEqual(page1.size, 3)
        XCTAssertEqual(page1.data.count, page1.size)

        /* Page 2 */
        let page2 = try await clients.file.fetchList(workspace.rootID, options: .init(page: 2, size: 3))
        XCTAssertGreaterThanOrEqual(page2.totalElements, options.count)
        XCTAssertEqual(page2.page, 2)
        XCTAssertEqual(page2.size, 3)
        XCTAssertEqual(page2.data.count, page2.size)

        /* Test fetch */
        let file = try await clients.file.fetch(files[0].id)
        XCTAssertEqual(file.name, files[0].name)
        XCTAssertEqual(file.workspaceID, files[0].workspaceID)

        /* Test patch name */
        let newName = "New File.txt"
        let resultAlpha = try await clients.file.patchName(file.id, options: .init(name: newName))
        XCTAssertEqual(resultAlpha.name, newName)
        let fileAlpha = try await clients.file.fetch(file.id)
        XCTAssertEqual(fileAlpha.name, newName)

        /* Test delete */
        for file in files {
            try await clients.file.delete(file.id)
        }
        for file in files {
            do {
                _ = try await clients.file.fetch(file.id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "file_not_found")
            } catch {
                XCTFail("Invalid error: \(error)")
            }
        }
    }

    func testUserPermissionsFlow() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        let folder = try await createDisposableFolder(clients.file, options: .init(
            workspaceID: workspace.id,
            name: "Test Folder"
        ))

        let permissions = try await clients.file.fetchUserPermissions(folder.id)
        XCTAssertEqual(permissions.count, 0)

        let me = try await clients.authUser.fetch()

        try await clients.file.revokeUserPermission(.init(ids: [folder.id], userID: me.id))
        do {
            _ = try await clients.file.fetch(folder.id)
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, "file_not_found")
        } catch {
            XCTFail("Invalid error: \(error)")
        }
    }

    func testGroupPermissionsFlow() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        let folder = try await createDisposableFolder(clients.file, options: .init(
            workspaceID: workspace.id,
            name: "Test Folder"
        ))

        let group = try await createDisposableGroup(clients.group, organizationID: organization.id)
        try await clients.file.grantGroupPermission(.init(ids: [folder.id], groupID: group.id, permission: .editor))

        let permissions = try await clients.file.fetchGroupPermissions(folder.id)
        XCTAssertEqual(permissions.count, 1)
        XCTAssertEqual(permissions.first?.group.id, group.id)
        XCTAssertEqual(permissions.first?.permission, .editor)

        try await clients.file.revokeGroupPermission(.init(ids: [folder.id], groupID: group.id))
        let newPermissions = try await clients.file.fetchGroupPermissions(folder.id)
        XCTAssertEqual(newPermissions.count, 0)
    }

    func testFetchPath() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        let folderA = try await createDisposableFolder(clients.file, options: .init(
            workspaceID: workspace.id,
            name: "Test Folder A"
        ))
        let folderB = try await createDisposableFolder(clients.file, options: .init(
            workspaceID: workspace.id,
            parentID: folderA.id,
            name: "Test Folder B"
        ))
        let folderC = try await createDisposableFolder(clients.file, options: .init(
            workspaceID: workspace.id,
            parentID: folderB.id,
            name: "Test Folder C"
        ))

        let path = try await clients.file.fetchPath(folderC.id)
        XCTAssertEqual(path.count, 4)
    }

    func testFetchCount() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        for index in 0 ..< 3 {
            _ = try await createDisposableFolder(clients.file, options: .init(
                workspaceID: workspace.id,
                name: "Test Folder \(index)"
            ))
        }

        let count = try await clients.file.fetchCount(workspace.rootID)
        XCTAssertEqual(count, 3)
    }

    func testDeleteMany() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        var ids = [String]()
        for index in 0 ..< 3 {
            let folder = try await createDisposableFolder(clients.file, options: .init(
                workspaceID: workspace.id,
                name: "Test Folder \(index)"
            ))
            ids.append(folder.id)
        }

        _ = try await clients.file.delete(.init(ids: ids))
        for id in ids {
            do {
                _ = try await clients.file.fetch(id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "file_not_found")
            } catch {
                XCTFail("Invalid error: \(error)")
            }
        }
    }

    func testCopy() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        let file = try await createDisposableFile(clients.file, options: .init(
            workspaceID: workspace.id,
            name: "Test File.txt",
            data: Data("Test Content".utf8)
        ))
        let folder = try await createDisposableFolder(clients.file, options: .init(
            workspaceID: workspace.id,
            name: "Test Folder"
        ))

        let copiedFile = try await clients.file.copy(file.id, to: folder.id)
        XCTAssertEqual(copiedFile.name, file.name)
        XCTAssertEqual(copiedFile.parentID, folder.id)

        do {
            _ = try await clients.file.copy(file.id, to: workspace.rootID)
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, "file_with_similar_name_exists")
        } catch {
            XCTFail("Invalid error: \(error)")
        }
    }

    func testCopyMany() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        var files: [VOFile.Entity] = []
        for index in 0 ..< 3 {
            try await files.append(createDisposableFile(clients.file, options: .init(
                workspaceID: workspace.id,
                name: "Test File \(index).txt",
                data: Data("Test Content \(index)".utf8)
            )))
        }
        let folder = try await createDisposableFolder(clients.file, options: .init(
            workspaceID: workspace.id,
            name: "Test Folder"
        ))

        let copyResult = try await clients.file.copy(.init(
            sourceIDs: files.map(\.id),
            targetID: folder.id
        ))
        XCTAssertEqual(copyResult.succeeded.count, files.count)
        XCTAssertEqual(copyResult.failed.count, 0)
        XCTAssertEqual(copyResult.new.count, files.count)
    }

    func testMove() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        let file = try await createDisposableFile(clients.file, options: .init(
            workspaceID: workspace.id,
            name: "Test File.txt",
            data: Data("Test Content".utf8)
        ))
        let folder = try await createDisposableFolder(clients.file, options: .init(
            workspaceID: workspace.id,
            name: "Test Folder"
        ))

        let movedFile = try await clients.file.move(file.id, to: folder.id)
        XCTAssertEqual(movedFile.parentID, folder.id)

        do {
            _ = try await createDisposableFile(clients.file, options: .init(
                workspaceID: workspace.id,
                name: "Test File.txt",
                data: Data("Test Content".utf8)
            ))
            _ = try await clients.file.move(file.id, to: workspace.rootID)
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, "file_with_similar_name_exists")
        } catch {
            XCTFail("Invalid error: \(error)")
        }
    }

    func testMoveMany() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        var files: [VOFile.Entity] = []
        for index in 0 ..< 3 {
            try await files.append(createDisposableFile(clients.file, options: .init(
                workspaceID: workspace.id,
                name: "Test File \(index).txt",
                data: Data("Test Content \(index)".utf8)
            )))
        }
        let folder = try await createDisposableFolder(clients.file, options: .init(
            workspaceID: workspace.id,
            name: "Test Folder"
        ))

        let moveResult = try await clients.file.move(.init(
            sourceIDs: files.map(\.id),
            targetID: folder.id
        ))
        XCTAssertEqual(moveResult.succeeded.count, files.count)
        XCTAssertEqual(moveResult.failed.count, 0)
    }
}
