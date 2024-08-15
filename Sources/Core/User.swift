// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

struct User {
    var baseURL: String
    var accessToken: String

    enum SortBy: Codable, CustomStringConvertible {
        case email
        case fullName

        var description: String {
            switch self {
            case .email:
                "email"
            case .fullName:
                "full_name"
            }
        }
    }

    enum SortOrder: String, Codable {
        case asc
        case desc
    }

    struct Entity: Codable {
        let id: String
        let username: String
        let email: String
        let fullName: String
        let picture: String?
    }

    struct List: Codable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
    }
}
