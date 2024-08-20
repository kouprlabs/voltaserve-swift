// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

@testable import Voltaserve
import XCTest

final class GroupTests: XCTestCase {
    let config = Config()
    var disposableGroups: [VOGroup.Entity] = []
    var disposableOrganizations: [VOOrganization.Entity] = []

    func testGroupFlow() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)

        /* Create groups */
        var options: [VOGroup.CreateOptions] = []
        for index in 0 ..< 6 {
            options.append(.init(name: "Test Group \(index)", organizationID: organization.id))
        }
        var groups: [VOGroup.Entity] = []
        for index in 0 ..< options.count {
            try await groups.append(createDisposableGroup(clients.group, options: options[index]))
        }

        /* Test creation */
        for index in 0 ..< groups.count {
            XCTAssertEqual(groups[index].name, options[index].name)
            XCTAssertEqual(groups[index].organization.id, options[index].organizationID)
        }

        /* Test list */

        /* Page 1 */
        let page1 = try await clients.group.fetchList(.init(page: 1, size: 3))
        XCTAssertGreaterThanOrEqual(page1.totalElements, options.count)
        XCTAssertEqual(page1.page, 1)
        XCTAssertEqual(page1.size, 3)
        XCTAssertEqual(page1.data.count, page1.size)

        /* Page 2 */
        let page2 = try await clients.group.fetchList(.init(page: 2, size: 3))
        XCTAssertGreaterThanOrEqual(page2.totalElements, options.count)
        XCTAssertEqual(page2.page, 2)
        XCTAssertEqual(page2.size, 3)
        XCTAssertEqual(page2.data.count, page2.size)

        /* Test fetch */
        let group = try await clients.group.fetch(groups[0].id)
        XCTAssertEqual(group.name, groups[0].name)
        XCTAssertEqual(group.organization.id, groups[0].organization.id)

        /* Test patch name */
        let newName = "New Group"
        let resultAlpha = try await clients.group.patchName(group.id, options: .init(name: newName))
        XCTAssertEqual(resultAlpha.name, newName)
        let groupAlpha = try await clients.group.fetch(group.id)
        XCTAssertEqual(groupAlpha.name, newName)

        /* Test delete */
        for group in groups {
            try await clients.group.delete(group.id)
        }
        for group in groups {
            do {
                _ = try await clients.group.fetch(group.id)
            } catch let error as VOErrorResponse {
                XCTAssertEqual(error.code, "group_not_found")
            } catch {
                XCTFail("Invalid error: \(error)")
            }
        }
    }

    override func tearDown() async throws {
        try await super.tearDown()

        let clients = try await Clients(fetchTokenOrFail())

        try await disposeGroups(clients.group)
        try await disposeOrganizations(clients.organization)
    }
}
