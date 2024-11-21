// Copyright (c) 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// See the LICENSE file in the root of this repository for details,
// or visit <https://opensource.org/licenses/MIT>.

import XCTest

extension XCTestCase {
    func failedToCreateFactory() {
        XCTFail("Failed to create factory")
    }

    func expectedToFail() {
        XCTFail("Expected to fail")
    }

    func invalidError(_ error: Error) {
        XCTFail("Invalid error: \(error)")
    }
}
