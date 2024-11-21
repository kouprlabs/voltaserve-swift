// Copyright 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// You can find a copy of the license in the LICENSE file
// included in the root of this repository or at
// https://opensource.org/licenses/MIT.

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct VOWorkspace {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = URL(string: baseURL)!.appendingPathComponent("v3").absoluteString
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetch(_ id: String) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForID(id))
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: Entity.self
                )
            }
            task.resume()
        }
    }

    public func fetchList(_ options: ListOptions) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForList(options))
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: List.self
                )
            }
            task.resume()
        }
    }

    public func fetchProbe(_ options: ListOptions) async throws -> Probe {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForProbe(options))
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: Probe.self
                )
            }
            task.resume()
        }
    }

    public func create(_ options: CreateOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: url())
            request.httpMethod = "POST"
            request.appendAuthorizationHeader(accessToken)
            request.setJSONBody(options, continuation: continuation)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: Entity.self
                )
            }
            task.resume()
        }
    }

    public func patchName(_ id: String, options: PatchNameOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForName(id))
            request.httpMethod = "PATCH"
            request.appendAuthorizationHeader(accessToken)
            request.setJSONBody(options, continuation: continuation)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: Entity.self
                )
            }
            task.resume()
        }
    }

    public func patchStorageCapacity(_ id: String, options: PatchStorageCapacityOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForStorageCapacity(id))
            request.httpMethod = "PATCH"
            request.appendAuthorizationHeader(accessToken)
            request.setJSONBody(options, continuation: continuation)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: Entity.self
                )
            }
            task.resume()
        }
    }

    public func delete(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForID(id))
            request.httpMethod = "DELETE"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleEmptyResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error
                )
            }
            task.resume()
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/workspaces")!
    }

    public func urlForID(_ id: String) -> URL {
        URL(string: "\(url())/\(id)")!
    }

    public func urlForList(_ options: ListOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(url())?\(query)")!
        } else {
            url()
        }
    }

    public func urlForProbe(_ options: ListOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(url())/probe?\(query)")!
        } else {
            URL(string: "\(url())/probe")!
        }
    }

    public func urlForName(_ id: String) -> URL {
        URL(string: "\(urlForID(id))/name")!
    }

    public func urlForStorageCapacity(_ id: String) -> URL {
        URL(string: "\(urlForID(id))/storage_capacity")!
    }

    // MARK: - Payloads

    public struct CreateOptions: Codable {
        public let name: String
        public let image: String?
        public let organizationID: String
        public let storageCapacity: Int

        public init(name: String, image: String? = nil, organizationID: String, storageCapacity: Int) {
            self.name = name
            self.image = image
            self.organizationID = organizationID
            self.storageCapacity = storageCapacity
        }

        enum CodingKeys: String, CodingKey {
            case name
            case image
            case organizationID = "organizationId"
            case storageCapacity
        }
    }

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

    public struct PatchNameOptions: Codable {
        public let name: String

        public init(name: String) {
            self.name = name
        }
    }

    public struct PatchStorageCapacityOptions: Codable {
        public let storageCapacity: Int

        public init(storageCapacity: Int) {
            self.storageCapacity = storageCapacity
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

    public struct Entity: Codable, Equatable, Hashable {
        public let id: String
        public let name: String
        public let permission: VOPermission.Value
        public let storageCapacity: Int
        public let rootID: String
        public let organization: VOOrganization.Entity
        public let createTime: String
        public let updateTime: String?

        public init(
            id: String,
            name: String,
            permission: VOPermission.Value,
            storageCapacity: Int,
            rootID: String,
            organization: VOOrganization.Entity,
            createTime: String,
            updateTime: String? = nil
        ) {
            self.id = id
            self.name = name
            self.permission = permission
            self.storageCapacity = storageCapacity
            self.rootID = rootID
            self.organization = organization
            self.createTime = createTime
            self.updateTime = updateTime
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case permission
            case storageCapacity
            case rootID = "rootId"
            case organization
            case createTime
            case updateTime
        }
    }

    public struct List: Codable, Equatable, Hashable {
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

    public struct Probe: Codable, Equatable, Hashable {
        public let totalPages: Int
        public let totalElements: Int

        public init(totalPages: Int, totalElements: Int) {
            self.totalPages = totalPages
            self.totalElements = totalElements
        }
    }
}
