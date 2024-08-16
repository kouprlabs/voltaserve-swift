// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

public struct Storage {
    public var baseURL: String
    public var accessToken: String

    public struct Usage: Codable {
        public let bytes: Int
        public let maxBytes: Int
        public let percentage: Int
    }
}
