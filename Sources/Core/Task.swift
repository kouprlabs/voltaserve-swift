// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

public struct VOTask {
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
        public let error: String?
        public let percentage: Int?
        public let isIndeterminate: Bool
        public let userId: String
        public let status: Status
        public let payload: Payload?
    }

    public enum Status: String, Codable {
        case waiting
        case running
        case success
        case error
    }

    public struct Payload: Codable {
        public let taskObject: String?

        enum CodingKeys: String, CodingKey {
            case taskObject = "object"
        }
    }

    public struct List: Codable {
        public let data: [Entity]
        public let totalPages: Int
        public let totalElements: Int
        public let page: Int
        public let size: Int
    }
}
