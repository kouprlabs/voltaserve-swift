// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

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
