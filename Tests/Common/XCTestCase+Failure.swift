// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

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
