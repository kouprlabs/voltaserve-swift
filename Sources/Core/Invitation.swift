// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

struct VOInvitation {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetchIncoming(_ options: ListOptions) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForList(urlForIncoming(), options: options),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: List.self)
            }
        }
    }

    public func fetchOutgoing(_ options: ListOptions) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForList(urlForOutgoing(), options: options),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: List.self)
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

    public func resend(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForResend(id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func accept(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForAccept(id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func decline(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForDecline(id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/invitations")!
    }

    public func urlForID(_ id: String) -> URL {
        URL(string: "\(baseURL)/invitations/\(id)")!
    }

    public func urlForIncoming() -> URL {
        URL(string: "\(baseURL)/invitations/incoming")!
    }

    public func urlForOutgoing() -> URL {
        URL(string: "\(baseURL)/invitations/outgoing")!
    }

    public func urlForResend(_ id: String) -> URL {
        URL(string: "\(baseURL)/invitations/\(id)/resend")!
    }

    public func urlForAccept(_ id: String) -> URL {
        URL(string: "\(baseURL)/invitations/\(id)/accept")!
    }

    public func urlForDecline(_ id: String) -> URL {
        URL(string: "\(baseURL)/invitations/\(id)/decline")!
    }

    public func urlForList(_ url: URL, options: ListOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(url)?\(query)")!
        } else {
            url
        }
    }

    // MARK: - Payloads

    public struct CreateOptions: Codable {
        public let organizationID: String
        public let emails: [String]

        enum CodingKeys: String, CodingKey {
            case organizationID = "organizationId"
            case emails
        }
    }

    public struct ListOptions: Codable {
        public let organizationID: String?
        public let size: Int?
        public let page: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?

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

    public struct Entity: Codable {
        public let id: String
        public let owner: VOUser.Entity
        public let email: [String]
        public let organization: VOOrganization.Entity
        public let status: InvitationStatus
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
