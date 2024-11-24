// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct VOInsights {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = URL(string: baseURL)!.appendingPathComponent("v3").absoluteString
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetchInfo(_ id: String) async throws -> Info {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForInfo(id))
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: Info.self
                )
            }
            task.resume()
        }
    }

    public func fetchEntityList(_ id: String, options: ListEntitiesOptions) async throws
        -> EntityList
    {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForListEntities(id, options: options))
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: EntityList.self
                )
            }
            task.resume()
        }
    }

    public func fetchEntityProbe(_ id: String, options: ListEntitiesOptions) async throws
        -> EntityProbe
    {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForProbeEntities(id, options: options))
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: EntityProbe.self
                )
            }
            task.resume()
        }
    }

    public func fetchLanguages() async throws -> [Language] {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForLanguages())
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: [Language].self
                )
            }
            task.resume()
        }
    }

    public func create(_ id: String, options: CreateOptions) async throws -> VOTask.Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForFile(id))
            request.httpMethod = "POST"
            request.appendAuthorizationHeader(accessToken)
            request.setJSONBody(options, continuation: continuation)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: VOTask.Entity.self
                )
            }
            task.resume()
        }
    }

    public func patch(_ id: String) async throws -> VOTask.Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForFile(id))
            request.httpMethod = "PATCH"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: VOTask.Entity.self
                )
            }
            task.resume()
        }
    }

    public func delete(_ id: String) async throws -> VOTask.Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForFile(id))
            request.httpMethod = "DELETE"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: VOTask.Entity.self
                )
            }
            task.resume()
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/insights")!
    }

    public func urlForFile(_ id: String) -> URL {
        URL(string: "\(url())/\(id)")!
    }

    public func urlForInfo(_ id: String) -> URL {
        URL(string: "\(urlForFile(id))/info")!
    }

    public func urlForEntities(_ id: String) -> URL {
        URL(string: "\(urlForFile(id))/entities")!
    }

    public func urlForLanguages() -> URL {
        URL(string: "\(url())/languages")!
    }

    public func urlForListEntities(_ id: String, options: ListEntitiesOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(urlForEntities(id))?\(query)")!
        } else {
            urlForEntities(id)
        }
    }

    public func urlForProbeEntities(_ id: String, options: ListEntitiesOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(urlForEntities(id))/probe?\(query)")!
        } else {
            URL(string: "\(urlForEntities(id))/probe")!
        }
    }

    // MARK: - Payloads

    public struct CreateOptions: Codable {
        public let languageID: String

        public init(languageID: String) {
            self.languageID = languageID
        }

        enum CodingKeys: String, CodingKey {
            case languageID = "languageId"
        }
    }

    public struct ListEntitiesOptions {
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

        public var urlQuery: String? {
            var items: [URLQueryItem] = []
            if let query {
                items.append(.init(name: "query", value: query))
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
        case desc
    }

    // MARK: - Types

    public struct Language: Codable, Equatable, Hashable {
        public let id: String
        public let iso6393: String
        public let name: String

        public init(id: String, iso6393: String, name: String) {
            self.id = id
            self.iso6393 = iso6393
            self.name = name
        }
    }

    public struct Info: Codable, Equatable, Hashable {
        public let isAvailable: Bool
        public let isOutdated: Bool
        public let snapshot: VOSnapshot.Entity?

        public init(isAvailable: Bool, isOutdated: Bool, snapshot: VOSnapshot.Entity? = nil) {
            self.isAvailable = isAvailable
            self.isOutdated = isOutdated
            self.snapshot = snapshot
        }
    }

    public struct Entity: Codable, Equatable, Hashable, Identifiable {
        public var id: String { text }
        public let text: String
        public let label: String
        public let frequency: Int

        public init(text: String, label: String, frequency: Int) {
            self.text = text
            self.label = label
            self.frequency = frequency
        }
    }

    public struct EntityList: Codable, Equatable, Hashable {
        public let data: [Entity]
        public let totalPages: Int
        public let totalElements: Int
        public let page: Int
        public let size: Int

        public init(data: [Entity], totalPages: Int, totalElements: Int, page: Int, size: Int) {
            self.data = data
            self.totalPages = totalPages
            self.totalElements = totalElements
            self.page = page
            self.size = size
        }
    }

    public struct EntityProbe: Codable, Equatable, Hashable {
        public let totalPages: Int
        public let totalElements: Int

        public init(totalPages: Int, totalElements: Int) {
            self.totalPages = totalPages
            self.totalElements = totalElements
        }
    }
}
