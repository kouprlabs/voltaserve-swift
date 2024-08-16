// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct VOOrganization {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetch(_ id: String) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(urlForID(id), headers: headersWithAuthorization(accessToken)).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func fetchList(_ options: ListOptions) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForList(options: options),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: List.self)
            }
        }
    }

    public func fetchMembers(_ id: String) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForMembers(id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: List.self)
            }
        }
    }

    public func create(_ options: CreateOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url(),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func patchName(_ id: String, options: PatchNameOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForID(id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
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

    public func patchName(_ id: String) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForPatchName(id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func leave(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForID(id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/organizations")!
    }

    public func urlForID(_ id: String) -> URL {
        URL(string: "\(baseURL)/organizations/\(id)")!
    }

    public func urlForList(options: ListOptions) -> URL {
        var urlComponents = URLComponents()
        if let query = options.query {
            if let base64Query = try? JSONEncoder().encode(query).base64EncodedString() {
                urlComponents.queryItems?.append(URLQueryItem(name: "query", value: base64Query))
            }
        }
        if let size = options.size {
            urlComponents.queryItems?.append(URLQueryItem(name: "size", value: String(size)))
        }
        if let page = options.page {
            urlComponents.queryItems?.append(URLQueryItem(name: "page", value: String(page)))
        }
        if let sortBy = options.sortBy {
            urlComponents.queryItems?.append(URLQueryItem(name: "sort_by", value: sortBy.rawValue))
        }
        if let sortOrder = options.sortOrder {
            urlComponents.queryItems?.append(URLQueryItem(name: "sort_order", value: sortOrder.rawValue))
        }
        let query = urlComponents.url?.query
        if let query {
            return URL(string: "\(baseURL)/v2/organizations?\(query)")!
        } else {
            return URL(string: "\(baseURL)/v2/organizations")!
        }
    }

    public func urlForPatchName(_ id: String) -> URL {
        URL(string: "\(baseURL)/organizations/\(id)/name")!
    }

    public func urlForLeave(_ id: String) -> URL {
        URL(string: "\(baseURL)/organizations/\(id)/leave")!
    }

    public func urlForMembers(_ id: String) -> URL {
        URL(string: "\(baseURL)/organizations/\(id)/members")!
    }

    // MARK: - Payloads

    public struct CreateOptions: Codable {
        public let name: String
        public let image: String?
    }

    public struct PatchNameOptions: Codable {
        public let name: String
    }

    public struct RemoveMemberOptions: Codable {
        public let userId: String
    }

    public struct ListOptions: Codable {
        public let query: String?
        public let size: Int?
        public let page: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?
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

    // MARK: - Types

    public struct Entity: Codable {
        public let id: String
        public let name: String
        public let permission: VOPermission.Value
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
