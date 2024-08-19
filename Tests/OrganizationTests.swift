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

final class OrganizationTests: XCTestCase {
    var config = Config()

    func testOrganizationFlow() async throws {
        let token = try await fetchTokenOrFail()
        let client = VOOrganization(baseURL: config.apiURL, accessToken: token.accessToken)

        /* Create organizations */
        var options: [VOOrganization.CreateOptions] = []
        for index in 0 ..< 6 {
            options.append(.init(name: "Test Organization \(index)"))
        }
        var organizations: [VOOrganization.Entity] = []
        for index in 0..<options.count {
            let organization = try await client.create(options[index])
            organizations.append(organization)
        }
        
        /* Test creation */
        for index in 0 ..< organizations.count {
            XCTAssertEqual(organizations[index].name, options[index].name)
        }
        
        /* Test list */

        /* Page 1 */
        let page1 = try await client.fetchList(VOOrganization.ListOptions(page: 1, size: 3))
        XCTAssertGreaterThanOrEqual(page1.totalElements, options.count)
        XCTAssertEqual(page1.page, 1)
        XCTAssertEqual(page1.size, 3)
        XCTAssertEqual(page1.data.count, page1.size)

        /* Page 2 */
        let page2 = try await client.fetchList(VOOrganization.ListOptions(page: 2, size: 3))
        XCTAssertGreaterThanOrEqual(page2.totalElements, options.count)
        XCTAssertEqual(page2.page, 2)
        XCTAssertEqual(page2.size, 3)
        XCTAssertEqual(page2.data.count, page2.size)
        
        /* Test fetch */
        let organization = try await client.fetch(organizations[0].id)
        XCTAssertEqual(organization.name, organizations[0].name)
        
        /* Test patch name */
        let newName = "New Organization"
        let resultAlpha = try await client.patchName(organization.id, options: .init(name: newName))
        XCTAssertEqual(resultAlpha.name, newName)
        let updatedOrganization = try await client.fetch(organization.id)
        XCTAssertEqual(updatedOrganization.name, newName)
        
        /* Test delete */
        for organization in organizations {
            try await client.delete(organization.id)
        }
        for organization in organizations {
            do {
                _ = try await client.fetch(organization.id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "organization_not_found")
            }
        }
    }
}
