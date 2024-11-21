// Copyright (c) 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// You can find a copy of the license in the LICENSE file
// included in the root of this repository or at
// https://opensource.org/licenses/MIT.

@testable import VoltaserveCore
import XCTest

final class AccountTests: XCTestCase {
    var factory: DisposableFactory?

    func testFetchPasswordRequirements() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.account

        let passwordRequirements = try await client.fetchPasswordRequirements()
        XCTAssertTrue(passwordRequirements.minLength > 0)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }
}
