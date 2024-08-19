// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct VOTask {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetch(_ id: String) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForID(id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func fetchList(_ options: ListOptions) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForList(options),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: List.self)
            }
        }
    }

    public func fetchCount() async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForCount(),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Int.self)
            }
        }
    }

    public func dismiss(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForDimiss(id: id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func dismiss() async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForDismiss(),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/tasks")!
    }

    public func urlForID(_ id: String) -> URL {
        URL(string: "\(url())/\(id)")!
    }

    public func urlForList(_ options: ListOptions) -> URL {
        if let query = options.query {
            URL(string: "\(url())?\(query)")!
        } else {
            url()
        }
    }

    public func urlForCount() -> URL {
        URL(string: "\(url())/count")!
    }

    public func urlForDimiss(id: String) -> URL {
        URL(string: "\(urlForID(id))/dismiss")!
    }

    public func urlForDismiss() -> URL {
        URL(string: "\(url())/dismiss")!
    }

    // MARK: - Payloads

    public struct ListOptions {
        public let query: String?
        public let page: Int?
        public let size: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?

        public init(
            query: String? = nil,
            page: Int? = nil,
            size: Int? = nil,
            sortBy: SortBy? = nil,
            sortOrder: SortOrder? = nil
        ) {
            self.query = query
            self.size = size
            self.page = page
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }

        var urlQuery: String? {
            var items: [URLQueryItem] = []
            if let query, let base64Query = try? JSONEncoder().encode(query).base64EncodedString() {
                items.append(.init(name: "query", value: base64Query))
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
        public let error: String?
        public let percentage: Int?
        public let isIndeterminate: Bool
        public let userID: String
        public let status: Status
        public let payload: Payload?

        public init(
            id: String,
            name: String,
            error: String? = nil,
            percentage: Int? = nil,
            isIndeterminate: Bool,
            userID: String,
            status: Status,
            payload: Payload? = nil
        ) {
            self.id = id
            self.name = name
            self.error = error
            self.percentage = percentage
            self.isIndeterminate = isIndeterminate
            self.userID = userID
            self.status = status
            self.payload = payload
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case error
            case percentage
            case isIndeterminate
            case userID = "userId"
            case status
            case payload
        }
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
