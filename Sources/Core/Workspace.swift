// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

public struct Workspace {
    public var baseURL: String
    public var accessToken: String

    public enum SortBy: Codable, CustomStringConvertible {
        case name
        case dateCreated
        case dateModified

        public var description: String {
            switch self {
            case .name:
                "name"
            case .dateCreated:
                "date_created"
            case .dateModified:
                "date_modified"
            }
        }
    }

    public enum SortOrder: String, Codable {
        case asc
        case desc
    }

    public struct Entity: Codable {
        public let id: String
        public let name: String
        public let permission: Permission.Value
        public let storageCapacity: Int
        public let rootId: String
        public let organization: Organization.Entity
        public let createTime: String
        public let updateTime: String?
    }

    public struct List: Codable {
        public let data: [Entity]
        public let totalPages: Int
        public let totalElements: Int
        public let page: Int
        public let size: Int
    }
}
