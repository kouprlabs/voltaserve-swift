// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve
import XCTest

extension XCTestCase {
    func fetchTokenOrFail() async throws -> VOToken.Value {
        var token = Token()
        if let value = try await token.fetch() {
            return value
        } else {
            throw FailedToFetchToken()
        }
    }

    struct FailedToFetchToken: Error {}
}
