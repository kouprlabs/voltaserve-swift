// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

@testable import Voltaserve
import XCTest

final class OrganizationTests: XCTestCase {
    var factory: DisposableFactory?

    func testOrganizationFlow() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }

        let client = factory.client.organization

        /* Create organizations */
        var options: [VOOrganization.CreateOptions] = []
        for index in 0 ..< 6 {
            options.append(.init(name: "Test Organization \(index)"))
        }
        var organizations: [VOOrganization.Entity] = []
        for index in 0 ..< options.count {
            try await organizations.append(factory.organization(options[index]))
        }

        /* Test creation */
        for index in 0 ..< organizations.count {
            XCTAssertEqual(organizations[index].name, options[index].name)
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
        let organization = try await client.fetch(organizations[0].id)
        XCTAssertEqual(organization.name, organizations[0].name)

        /* Test patch name */
        let newName = "New Organization"
        let alpha = try await client.patchName(organization.id, options: .init(name: newName))
        XCTAssertEqual(alpha.name, newName)
        let beta = try await factory.client.organization.fetch(organization.id)
        XCTAssertEqual(beta.name, newName)

        /* Test leave */
        do {
            try await client.leave(organization.id)
        } catch let error as VOErrorResponse {
            XCTAssertEqual(error.code, "cannot_remove_last_owner_of_organization")
        } catch {
            XCTFail("Invalid error: \(error)")
        }

        /* Test delete */
        for organization in organizations {
            try await client.delete(organization.id)
        }
        for organization in organizations {
            do {
                _ = try await client.fetch(organization.id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "organization_not_found")
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
