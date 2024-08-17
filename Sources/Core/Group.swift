// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct VOGroup {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetch(_ id: String) async throws -> VOGroup.Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(urlForID(id), headers: headersWithAuthorization(accessToken)).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: VOGroup.Entity.self)
            }
        }
    }

    public func fetchList(_ options: ListOptions) async throws -> VOGroup.List {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForList(options: options),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: VOGroup.List.self)
            }
        }
    }

    public func create(_ options: CreateOptions) async throws -> VOGroup.Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: VOGroup.Entity.self)
            }
        }
    }

    public func patchName(_ id: String, options: PatchNameOptions) async throws -> VOGroup.Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForID(id),
                method: .patch,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: VOGroup.Entity.self)
            }
        }
    }

    public func delete(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForID(id),
                method: .delete,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/groups")!
    }

    public func urlForID(_ id: String) -> URL {
        URL(string: "\(baseURL)/groups/\(id)")!
    }

    public func urlForList(options: ListOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(url())?\(query)")!
        } else {
            url()
        }
    }

    public func urlForMembers(_ id: String) -> URL {
        URL(string: "\(baseURL)/groups/\(id)/members")!
    }

    // MARK: - Payloads

    public struct ListOptions {
        public let query: String?
        public let organizationID: String?
        public let size: Int?
        public let page: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?

        var urlQuery: String? {
            var items: [URLQueryItem] = []
            if let query, let base64Query = try? JSONEncoder().encode(query).base64EncodedString() {
                items.append(.init(name: "query", value: base64Query))
            }
            if let organizationID {
                items.append(.init(name: "organization_id", value: organizationID))
            }
            if let size {
                items.append(.init(name: "size", value: String(size)))
            }
            if let page {
                items.append(.init(name: "page", value: String(page)))
            }
            if let sortBy {
                items.append(.init(name: "sort_by", value: sortBy.rawValue))
            }
            if let sortOrder {
                items.append(.init(name: "sort_order", value: sortOrder.rawValue))
            }
            var components = URLComponents()
            components.queryItems = items
            return components.url?.query
        }

        enum CodingKeys: String, CodingKey {
            case query
            case organizationID = "organizationId"
            case size
            case page
            case sortBy
            case sortOrder
        }
    }

    public enum SortBy: String, Codable, CustomStringConvertible {
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

    public struct CreateOptions: Codable {
        public let name: String
        public let image: String?
        public let organizationID: String

        enum CodingKeys: String, CodingKey {
            case name
            case image
            case organizationID = "organizationId"
        }
    }

    public struct PatchNameOptions: Codable {
        public let name: String
    }

    public struct AddMemberOptions: Codable {
        public let userID: String

        enum CodingKeys: String, CodingKey {
            case userID = "userId"
        }
    }

    public struct RemoveMemberOptions: Codable {
        public let userID: String

        enum CodingKeys: String, CodingKey {
            case userID = "userId"
        }
    }

    // MARK: - Types

    public struct Entity: Codable {
        public let id: String
        public let name: String
        public let organization: VOOrganization.Entity
        public let permission: String
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
