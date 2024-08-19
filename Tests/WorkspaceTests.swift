// Copyright 2023 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file licenses/BSL.txt.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// licenses/AGPL.txt.

@testable import Voltaserve
import XCTest

final class WorkspaceTests: XCTestCase {
    var config = Config()

    func testWorkspaceFlow() async throws {
        let token = try await fetchTokenOrFail()
        let organizationClient = VOOrganization(baseURL: config.apiURL, accessToken: token.accessToken)
        let workspaceClient = VOWorkspace(baseURL: config.apiURL, accessToken: token.accessToken)
        
        /* Create organization */
        let organization = try await organizationClient.create(.init(name: "Test Organization"))

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
            let workspace = try await workspaceClient.create(options[index])
            workspaces.append(workspace)
        }

        /* Test creation */
        for index in 0 ..< workspaces.count {
            XCTAssertEqual(workspaces[index].name, options[index].name)
            XCTAssertEqual(workspaces[index].organization.id, options[index].organizationId)
            XCTAssertEqual(workspaces[index].storageCapacity, options[index].storageCapacity)
        }

        /* Test list */

        /* Page 1 */
        let page1 = try await workspaceClient.fetchList(VOWorkspace.ListOptions(page: 1, size: 3))
        XCTAssertGreaterThanOrEqual(page1.totalElements, options.count)
        XCTAssertEqual(page1.page, 1)
        XCTAssertEqual(page1.size, 3)
        XCTAssertEqual(page1.data.count, page1.size)

        /* Page 2 */
        let page2 = try await workspaceClient.fetchList(VOWorkspace.ListOptions(page: 2, size: 3))
        XCTAssertGreaterThanOrEqual(page2.totalElements, options.count)
        XCTAssertEqual(page2.page, 2)
        XCTAssertEqual(page2.size, 3)
        XCTAssertEqual(page2.data.count, page2.size)

        /* Test fetch */
        let workspace = try await workspaceClient.fetch(workspaces[0].id)
        XCTAssertEqual(workspace.name, workspaces[0].name)
        XCTAssertEqual(workspace.organization.id, workspaces[0].organization.id)
        XCTAssertEqual(workspace.storageCapacity, workspaces[0].storageCapacity)

        /* Test patch name */
        let newName = "New Workspace"
        let resultAlpha = try await workspaceClient.patchName(workspace.id, options: .init(name: newName))
        XCTAssertEqual(resultAlpha.name, newName)
        let workspaceAlpha = try await workspaceClient.fetch(workspace.id)
        XCTAssertEqual(workspaceAlpha.name, newName)

        /* Test patch storage capacity */
        let newStorageCapacity = 200_000_000
        let resultBeta = try await workspaceClient.patchStorageCapacity(
            workspace.id,
            options: .init(storageCapacity: newStorageCapacity)
        )
        XCTAssertEqual(resultBeta.storageCapacity, newStorageCapacity)
        let workspaceBeta = try await workspaceClient.fetch(workspace.id)
        XCTAssertEqual(workspaceBeta.storageCapacity, newStorageCapacity)

        /* Test delete */
        for workspace in workspaces {
            try await workspaceClient.delete(workspace.id)
        }
        for workspace in workspaces {
            do {
                _ = try await workspaceClient.fetch(workspace.id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "workspace_not_found")
            }
        }

        /* Delete organization */
        try await organizationClient.delete(organization.id)
    }
}
