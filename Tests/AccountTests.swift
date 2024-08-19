// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

@testable import Voltaserve
import XCTest

final class SnapshotTests: XCTestCase {
    let config = Config()

    func testFetchPasswordRequirements() async throws {
        let token = try await fetchTokenOrFail()
        let accountClient = VOAccount(baseURL: config.idpURL, accessToken: token.accessToken)

        let passwordRequirements = try await accountClient.fetchPasswordRequirements()
        XCTAssertTrue(passwordRequirements.minLength > 0)
    }
}
