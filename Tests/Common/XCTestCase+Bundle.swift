// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
import XCTest

extension XCTestCase {
    func getResourceURL(forResource resource: String, withExtension fileExtension: String) -> URL? {
        #if os(Linux)
            URL(fileURLWithPath: "Tests/Resources/\(resource).\(fileExtension)")
        #else
            Bundle(url: Bundle(for: type(of: self)).url(
                forResource: "Voltaserve_VoltaserveTests",
                withExtension: "bundle"
            )!)!.url(forResource: resource, withExtension: fileExtension)
        #endif
    }
}
