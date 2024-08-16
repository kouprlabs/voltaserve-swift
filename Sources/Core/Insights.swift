// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

struct VOInsights {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func create(_ id: String, options _: CreateOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForFile(id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func fetchInfo(_ id: String) async throws -> Info {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(urlForInfo(id), headers: headersWithAuthorization(accessToken)).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Info.self)
            }
        }
    }

    public func fetchEntities(_ id: String, options: ListEntitiesOptions) async throws -> EntityList {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForListEntities(id, options: options),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: EntityList.self)
            }
        }
    }

    public func fetchLanguages() async throws -> [Language] {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(urlForLanguages(), headers: headersWithAuthorization(accessToken)).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: [Language].self)
            }
        }
    }

    // MARK: - URLs

    public func urlForFile(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/insights/\(id)")!
    }

    public func urlForInfo(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/insights/\(id)/info")!
    }

    public func urlForEntities(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/insights/\(id)/entities")!
    }

    public func urlForLanguages() -> URL {
        URL(string: "\(baseURL)/v2/insights/languages")!
    }

    public func urlForListEntities(_ id: String, options: ListEntitiesOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(urlForEntities(id))?\(query)")!
        } else {
            urlForEntities(id)
        }
    }

    // MARK: - Payloads

    struct CreateOptions: Codable {
        public let languageID: String

        enum CodingKeys: String, CodingKey {
            case languageID = "languageId"
        }
    }

    public struct ListEntitiesOptions: Codable {
        public let query: String?
        public let size: Int?
        public let page: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?

        public var urlQuery: String? {
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

    public enum SortBy: String, Codable {
        case name
        case frequency
    }

    public enum SortOrder: String, Codable {
        case asc
        case sesc
    }

    // MARK: - Types

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
}
