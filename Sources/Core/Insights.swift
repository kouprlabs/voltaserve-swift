// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

struct Insights {
    public var baseURL: String
    public var accessToken: String

    public struct Language: Codable {
        public let id: String
        public let iso6393: String
        public let name: String
    }

    public struct Info: Codable {
        public let isAvailable: Bool
        public let isOutdated: Bool
        public let snapshot: Snapshot.Entity?
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
