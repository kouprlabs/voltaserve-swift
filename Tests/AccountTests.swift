// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

@testable import Voltaserve
import XCTest

final class SnapshotTests: XCTestCase {
    let config = Config()

    func testFetchPasswordRequirements() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let passwordRequirements = try await clients.account.fetchPasswordRequirements()
        XCTAssertTrue(passwordRequirements.minLength > 0)
    }
}
