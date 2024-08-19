// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

@testable import Voltaserve
import XCTest

final class OrganizationTests: XCTestCase {
    var config = Config()
    var disposableOrganizations: [VOOrganization.Entity] = []

    func testOrganizationFlow() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        /* Create organizations */
        var options: [VOOrganization.CreateOptions] = []
        for index in 0 ..< 6 {
            options.append(.init(name: "Test Organization \(index)"))
        }
        var organizations: [VOOrganization.Entity] = []
        for index in 0 ..< options.count {
            try await organizations.append(createDisposableOrganization(clients.organization, options: options[index]))
        }

        /* Test creation */
        for index in 0 ..< organizations.count {
            XCTAssertEqual(organizations[index].name, options[index].name)
        }

        /* Test list */

        /* Page 1 */
        let page1 = try await clients.organization.fetchList(.init(page: 1, size: 3))
        XCTAssertGreaterThanOrEqual(page1.totalElements, options.count)
        XCTAssertEqual(page1.page, 1)
        XCTAssertEqual(page1.size, 3)
        XCTAssertEqual(page1.data.count, page1.size)

        /* Page 2 */
        let page2 = try await clients.organization.fetchList(.init(page: 2, size: 3))
        XCTAssertGreaterThanOrEqual(page2.totalElements, options.count)
        XCTAssertEqual(page2.page, 2)
        XCTAssertEqual(page2.size, 3)
        XCTAssertEqual(page2.data.count, page2.size)

        /* Test fetch */
        let organization = try await clients.organization.fetch(organizations[0].id)
        XCTAssertEqual(organization.name, organizations[0].name)

        /* Test patch name */
        let newName = "New Organization"
        let resultAlpha = try await clients.organization.patchName(organization.id, options: .init(name: newName))
        XCTAssertEqual(resultAlpha.name, newName)
        let organizationAlpha = try await clients.organization.fetch(organization.id)
        XCTAssertEqual(organizationAlpha.name, newName)

        /* Test leave */
        do {
            try await clients.organization.leave(organization.id)
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, "cannot_remove_last_owner_of_organization")
        } catch {
            XCTFail()
        }

        /* Test delete */
        for organization in organizations {
            try await clients.organization.delete(organization.id)
        }
        for organization in organizations {
            do {
                _ = try await clients.organization.fetch(organization.id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "organization_not_found")
            }
        }
    }
}
