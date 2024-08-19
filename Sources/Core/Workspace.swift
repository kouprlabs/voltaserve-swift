// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct VOWorkspace {
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

    public func create(_ options: CreateOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func patchName(_ id: String, options: PatchNameOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForName(id),
                method: .patch,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func patchStorageCapacity(_ id: String, options: PatchStorageCapacityOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForStorageCapacity(id),
                method: .patch,
                parameters: options,
                encoder: JSONParameterEncoder.default,
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
        public let organizationId: String
        public let storageCapacity: Int

        public init(name: String, image: String? = nil, organizationId: String, storageCapacity: Int) {
            self.name = name
            self.image = image
            self.organizationId = organizationId
            self.storageCapacity = storageCapacity
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

    public struct Entity: Codable {
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

    public struct List: Codable {
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
}
