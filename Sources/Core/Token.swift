// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

public struct VOToken {
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

    public struct Value {
        public var accessToken: String

        public init(accessToken: String) {
            self.accessToken = accessToken
        }
    }
}
