// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct VOInvitation {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetchIncomingList(_ options: ListIncomingOptions) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForListIncoming(urlForIncoming(), options: options))
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

    public func fetchIncomingProbe(_ options: ListIncomingOptions) async throws -> Probe {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForProbeIncoming(urlForIncoming(), options: options))
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

    public func fetchIncomingCount() async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForIncomingCount())
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: Int.self
                )
            }
            task.resume()
        }
    }

    public func fetchOutgoingList(_ options: ListOutgoingOptions) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForProbeOutgoing(urlForOutgoing(), options: options))
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

    public func fetchOutgoingProbe(_ options: ListOutgoingOptions) async throws -> Probe {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForListOutgoing(urlForOutgoing(), options: options))
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

    public func create(_ options: CreateOptions) async throws -> [Entity] {
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
                    type: [Entity].self
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

    public func resend(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForResend(id))
            request.httpMethod = "POST"
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

    public func accept(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForAccept(id))
            request.httpMethod = "POST"
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

    public func decline(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForDecline(id))
            request.httpMethod = "POST"
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
        URL(string: "\(baseURL)/invitations")!
    }

    public func urlForID(_ id: String) -> URL {
        URL(string: "\(url())/\(id)")!
    }

    public func urlForIncoming() -> URL {
        URL(string: "\(url())/incoming")!
    }

    public func urlForIncomingCount() -> URL {
        URL(string: "\(url())/incoming/count")!
    }

    public func urlForOutgoing() -> URL {
        URL(string: "\(url())/outgoing")!
    }

    public func urlForResend(_ id: String) -> URL {
        URL(string: "\(urlForID(id))/resend")!
    }

    public func urlForAccept(_ id: String) -> URL {
        URL(string: "\(urlForID(id))/accept")!
    }

    public func urlForDecline(_ id: String) -> URL {
        URL(string: "\(urlForID(id))/decline")!
    }

    public func urlForListIncoming(_ url: URL, options: ListIncomingOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(url)?\(query)")!
        } else {
            url
        }
    }

    public func urlForProbeIncoming(_ url: URL, options: ListIncomingOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(url)/probe?\(query)")!
        } else {
            URL(string: "\(url)/probe")!
        }
    }

    public func urlForListOutgoing(_ url: URL, options: ListOutgoingOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(url)?\(query)")!
        } else {
            url
        }
    }

    public func urlForProbeOutgoing(_ url: URL, options: ListOutgoingOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(url)/probe?\(query)")!
        } else {
            URL(string: "\(url)/probe")!
        }
    }

    // MARK: - Payloads

    public struct CreateOptions: Codable {
        public let organizationID: String
        public let emails: [String]

        public init(organizationID: String, emails: [String]) {
            self.organizationID = organizationID
            self.emails = emails
        }

        enum CodingKeys: String, CodingKey {
            case organizationID = "organizationId"
            case emails
        }
    }

    public struct ListIncomingOptions {
        public let organizationID: String?
        public let page: Int?
        public let size: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?

        public init(
            organizationID: String? = nil,
            page: Int? = nil,
            size: Int? = nil,
            sortBy: SortBy? = nil,
            sortOrder: SortOrder? = nil
        ) {
            self.organizationID = organizationID
            self.size = size
            self.page = page
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }

        public var urlQuery: String? {
            var items: [URLQueryItem] = []
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
            case organizationID = "organizationId"
            case size
            case page
            case sortBy
            case sortOrder
        }
    }

    public struct ListOutgoingOptions {
        public let organizationID: String
        public let page: Int?
        public let size: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?

        public init(
            organizationID: String,
            page: Int? = nil,
            size: Int? = nil,
            sortBy: SortBy? = nil,
            sortOrder: SortOrder? = nil
        ) {
            self.organizationID = organizationID
            self.size = size
            self.page = page
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }

        public var urlQuery: String? {
            var items: [URLQueryItem] = [.init(name: "organization_id", value: organizationID)]
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
            case organizationID = "organizationId"
            case size
            case page
            case sortBy
            case sortOrder
        }
    }

    public enum SortBy: String, Codable, CustomStringConvertible {
        case email
        case dateCreated
        case dateModified

        public var description: String {
            switch self {
            case .email:
                "email"
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

    public enum InvitationStatus: String, Codable {
        case pending
        case accepted
        case declined
    }

    public struct Entity: Codable, Equatable, Hashable {
        public let id: String
        public let owner: VOUser.Entity?
        public let email: String
        public let organization: VOOrganization.Entity?
        public let status: InvitationStatus
        public let createTime: String
        public let updateTime: String?

        public init(
            id: String,
            owner: VOUser.Entity? = nil,
            email: String,
            organization: VOOrganization.Entity? = nil,
            status: InvitationStatus,
            createTime: String,
            updateTime: String? = nil
        ) {
            self.id = id
            self.owner = owner
            self.email = email
            self.organization = organization
            self.status = status
            self.createTime = createTime
            self.updateTime = updateTime
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
