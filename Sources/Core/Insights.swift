// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

struct VOInsights {
    let baseURL: String
    let accessToken: String

    // MARK: - Requests

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

    public func urlForLanguages() -> URL {
        URL(string: "\(baseURL)/v2/insights/languages")!
    }

    public func urlForListEntities(_ id: String, options: ListEntitiesOptions) -> URL {
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
            return URL(string: "\(baseURL)/v2/insights/\(id)/entities?\(query)")!
        } else {
            return URL(string: "\(baseURL)/v2/insights/\(id)/entities")!
        }
    }

    // MARK: - Payloads

    struct CreateOptions {
        public let languageId: String
    }

    public struct ListEntitiesOptions {
        public let query: String?
        public let size: Int?
        public let page: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?
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

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

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
