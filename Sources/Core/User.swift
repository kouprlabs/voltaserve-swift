// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

public struct VOUser {
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
        case email
        case fullName

        public var description: String {
            switch self {
            case .email:
                "email"
            case .fullName:
                "full_name"
            }
        }
    }

    public enum SortOrder: String, Codable {
        case asc
        case desc
    }

    public struct Entity: Codable {
        public let id: String
        public let username: String
        public let email: String
        public let fullName: String
        public let picture: String?
    }

    public struct List: Codable {
        public let data: [Entity]
        public let totalPages: Int
        public let totalElements: Int
        public let page: Int
        public let size: Int
    }
}

public struct VOAuthUser {
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
}
