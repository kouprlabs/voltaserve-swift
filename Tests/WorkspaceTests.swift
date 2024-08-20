// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

@testable import Voltaserve
import XCTest

final class WorkspaceTests: XCTestCase {
    var factory: DisposableFactory?

    func testWorkspaceFlow() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.workspace

        let organization = try await factory.organization(.init(name: "Test Organization"))

        /* Create workspaces */
        var options: [VOWorkspace.CreateOptions] = []
        for index in 0 ..< 6 {
            options.append(.init(
                name: "Test Workspace \(index)",
                organizationID: organization.id,
                storageCapacity: 100_000_000 + index
            ))
        }
        var workspaces: [VOWorkspace.Entity] = []
        for index in 0 ..< options.count {
            try await workspaces.append(factory.workspace(options[index]))
        }

        /* Test creation */
        for index in 0 ..< workspaces.count {
            XCTAssertEqual(workspaces[index].name, options[index].name)
            XCTAssertEqual(workspaces[index].organization.id, options[index].organizationID)
            XCTAssertEqual(workspaces[index].storageCapacity, options[index].storageCapacity)
        }

        /* Test list */

        /* Page 1 */
        let page1 = try await client.fetchList(.init(page: 1, size: 3))
        XCTAssertGreaterThanOrEqual(page1.totalElements, options.count)
        XCTAssertEqual(page1.page, 1)
        XCTAssertEqual(page1.size, 3)
        XCTAssertEqual(page1.data.count, page1.size)

        /* Page 2 */
        let page2 = try await client.fetchList(.init(page: 2, size: 3))
        XCTAssertGreaterThanOrEqual(page2.totalElements, options.count)
        XCTAssertEqual(page2.page, 2)
        XCTAssertEqual(page2.size, 3)
        XCTAssertEqual(page2.data.count, page2.size)

        /* Test fetch */
        let workspace = try await client.fetch(workspaces[0].id)
        XCTAssertEqual(workspace.name, workspaces[0].name)
        XCTAssertEqual(workspace.organization.id, workspaces[0].organization.id)
        XCTAssertEqual(workspace.storageCapacity, workspaces[0].storageCapacity)

        /* Test patch name */
        let newName = "New Workspace"
        let resultAlpha = try await client.patchName(workspace.id, options: .init(name: newName))
        XCTAssertEqual(resultAlpha.name, newName)
        let workspaceAlpha = try await client.fetch(workspace.id)
        XCTAssertEqual(workspaceAlpha.name, newName)

        /* Test patch storage capacity */
        let newStorageCapacity = 200_000_000
        let resultBeta = try await client.patchStorageCapacity(
            workspace.id,
            options: .init(storageCapacity: newStorageCapacity)
        )
        XCTAssertEqual(resultBeta.storageCapacity, newStorageCapacity)
        let workspaceBeta = try await client.fetch(workspace.id)
        XCTAssertEqual(workspaceBeta.storageCapacity, newStorageCapacity)

        /* Test delete */
        for workspace in workspaces {
            try await client.delete(workspace.id)
        }
        for workspace in workspaces {
            do {
                _ = try await client.fetch(workspace.id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "workspace_not_found")
            } catch {
                XCTFail("Invalid error: \(error)")
            }
        }
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }
}
