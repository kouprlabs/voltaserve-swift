// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

struct Invitation {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    public enum SortBy: Codable, CustomStringConvertible {
        case email
        case dateCreated
        case dateModified

        public var description: String {
            switch self {
            case .email:
                "email"
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

    public enum InvitationStatus: String, Codable {
        case pending
        case accepted
        case declined
    }

    public struct Entity: Codable {
        public let id: String
        public let owner: User.Entity
        public let email: [String]
        public let organization: Organization.Entity
        public let status: InvitationStatus
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
