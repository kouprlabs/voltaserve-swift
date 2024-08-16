// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

struct VOInsights {
    let baseURL: String
    let accessToken: String

    // MARK: - Requests

    // MARK: - URLs

    // MARK: - Payloads

    // MARK: - Types

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    public struct Language: Codable {
        public let id: String
        public let iso6393: String
        public let name: String
    }

    public struct Info: Codable {
        public let isAvailable: Bool
        public let isOutdated: Bool
        public let snapshot: VOSnapshot.Entity?
    }

    public struct Entity: Codable {
        public let text: String
        public let label: String
        public let frequency: Int
    }

    public struct EntityList: Codable {
        public let data: [Entity]
        public let totalPages: Int
        public let totalElements: Int
        public let page: Int
        public let size: Int
    }

    public enum SortBy: String, Codable {
        case name
        case frequency
    }

    public enum SortOrder: String, Codable {
        case asc
        case sesc
    }
}
