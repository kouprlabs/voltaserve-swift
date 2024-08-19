// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

@testable import Voltaserve
import XCTest

final class WorkspaceTests: XCTestCase {
    var config = Config()
    var disposableOrganizations: [VOOrganization.Entity] = []
    var disposableWorkspaces: [VOWorkspace.Entity] = []

    func testWorkspaceFlow() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)

        /* Create workspaces */
        var options: [VOWorkspace.CreateOptions] = []
        for index in 0 ..< 6 {
            options.append(.init(
                name: "Test Workspace \(index)",
                organizationId: organization.id,
                storageCapacity: 100_000_000 + index
            ))
        }
        var workspaces: [VOWorkspace.Entity] = []
        for index in 0 ..< options.count {
            try await workspaces.append(createDisposableWorkspace(clients.workspace, options: options[index]))
        }

        /* Test creation */
        for index in 0 ..< workspaces.count {
            XCTAssertEqual(workspaces[index].name, options[index].name)
            XCTAssertEqual(workspaces[index].organization.id, options[index].organizationId)
            XCTAssertEqual(workspaces[index].storageCapacity, options[index].storageCapacity)
        }

        /* Test list */

        /* Page 1 */
        let page1 = try await clients.workspace.fetchList(.init(page: 1, size: 3))
        XCTAssertGreaterThanOrEqual(page1.totalElements, options.count)
        XCTAssertEqual(page1.page, 1)
        XCTAssertEqual(page1.size, 3)
        XCTAssertEqual(page1.data.count, page1.size)

        /* Page 2 */
        let page2 = try await clients.workspace.fetchList(.init(page: 2, size: 3))
        XCTAssertGreaterThanOrEqual(page2.totalElements, options.count)
        XCTAssertEqual(page2.page, 2)
        XCTAssertEqual(page2.size, 3)
        XCTAssertEqual(page2.data.count, page2.size)

        /* Test fetch */
        let workspace = try await clients.workspace.fetch(workspaces[0].id)
        XCTAssertEqual(workspace.name, workspaces[0].name)
        XCTAssertEqual(workspace.organization.id, workspaces[0].organization.id)
        XCTAssertEqual(workspace.storageCapacity, workspaces[0].storageCapacity)

        /* Test patch name */
        let newName = "New Workspace"
        let resultAlpha = try await clients.workspace.patchName(workspace.id, options: .init(name: newName))
        XCTAssertEqual(resultAlpha.name, newName)
        let workspaceAlpha = try await clients.workspace.fetch(workspace.id)
        XCTAssertEqual(workspaceAlpha.name, newName)

        /* Test patch storage capacity */
        let newStorageCapacity = 200_000_000
        let resultBeta = try await clients.workspace.patchStorageCapacity(
            workspace.id,
            options: .init(storageCapacity: newStorageCapacity)
        )
        XCTAssertEqual(resultBeta.storageCapacity, newStorageCapacity)
        let workspaceBeta = try await clients.workspace.fetch(workspace.id)
        XCTAssertEqual(workspaceBeta.storageCapacity, newStorageCapacity)

        /* Test delete */
        for workspace in workspaces {
            try await clients.workspace.delete(workspace.id)
        }
        for workspace in workspaces {
            do {
                _ = try await clients.workspace.fetch(workspace.id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "workspace_not_found")
            } catch {
                XCTFail("Invalid error: \(error)")
            }
        }
    }
}
