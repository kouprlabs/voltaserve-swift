// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

public struct VOStorage {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    // MARK: - URLs

    // MARK: - Payloads

    // MARK: - Types

    public struct Usage: Codable {
        public let bytes: Int
        public let maxBytes: Int
        public let percentage: Int
    }
}
