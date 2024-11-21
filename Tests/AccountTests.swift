// Copyright (c) 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// See the LICENSE file in the root of this repository for details,
// or visit <https://opensource.org/licenses/MIT>.

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
