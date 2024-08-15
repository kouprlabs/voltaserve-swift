// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

struct Storage {
    var baseURL: String
    var accessToken: String

    struct Usage: Codable {
        let bytes: Int
        let maxBytes: Int
        let percentage: Int
    }
}
