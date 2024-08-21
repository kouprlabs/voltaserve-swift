// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import XCTest

final class InvitationTests: XCTestCase {
    var factory: DisposableFactory?
    var otherFactory: DisposableFactory?

    func testFetchOutgoing() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory

        guard let otherFactory = try? await DisposableFactory.withOtherCredentials() else {
            failedToCreateFactory()
            return
        }
        self.otherFactory = otherFactory

        let client = factory.client.invitation

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let otherUser = try await otherFactory.client.authUser.fetch()

        _ = try await client.create(.init(organizationID: organization.id, emails: [otherUser.email]))

        let outgoing = try await client.fetchOutgoing(.init(organizationID: organization.id))
        XCTAssertEqual(outgoing.totalElements, 1)
    }

    func testDelete() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory

        guard let otherFactory = try? await DisposableFactory.withOtherCredentials() else {
            failedToCreateFactory()
            return
        }
        self.otherFactory = otherFactory

        let client = factory.client.invitation
        let otherClient = factory.client.invitation

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let otherUser = try await otherFactory.client.authUser.fetch()

        let invitations = try await client.create(.init(
            organizationID: organization.id,
            emails: [otherUser.email]
        ))
        try await client.delete(invitations[0].id)
        let outgoing = try await otherClient.fetchIncoming(.init())
        XCTAssertEqual(outgoing.totalElements, 0)
    }

    func testDecline() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory

        guard let otherFactory = try? await DisposableFactory.withOtherCredentials() else {
            failedToCreateFactory()
            return
        }
        self.otherFactory = otherFactory

        let client = factory.client.invitation
        let otherClient = otherFactory.client.invitation

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let otherUser = try await otherFactory.client.authUser.fetch()

        let invitations = try await client.create(.init(
            organizationID: organization.id,
            emails: [otherUser.email]
        ))
        try await otherClient.decline(invitations[0].id)

        let incoming = try await otherClient.fetchIncoming(.init())
        XCTAssertEqual(incoming.totalElements, 0)

        let outgoing = try await client.fetchOutgoing(.init(organizationID: organization.id))
        XCTAssertEqual(outgoing.totalElements, 1)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
        await otherFactory?.dispose()
    }
}
