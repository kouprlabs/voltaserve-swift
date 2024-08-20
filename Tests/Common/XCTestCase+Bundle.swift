// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
import XCTest

extension XCTestCase {
    var resourcesBundle: Bundle {
        Bundle(url: Bundle(for: type(of: self)).url(
            forResource: "Voltaserve_VoltaserveTests",
            withExtension: "bundle"
        )!)!
    }
}
