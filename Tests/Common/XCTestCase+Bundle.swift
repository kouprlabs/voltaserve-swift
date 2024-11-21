// Copyright (c) 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// See the LICENSE file in the root of this repository for details,
// or visit <https://opensource.org/licenses/MIT>.

import Foundation
import XCTest

extension XCTestCase {
    func getResourceURL(forResource resource: String, withExtension fileExtension: String) -> URL? {
        #if os(Linux)
            URL(fileURLWithPath: "Tests/Resources/\(resource).\(fileExtension)")
        #else
            Bundle(url: Bundle(for: type(of: self)).url(
                forResource: "VoltaserveCore_VoltaserveTests",
                withExtension: "bundle"
            )!)!.url(forResource: resource, withExtension: fileExtension)
        #endif
    }
}
