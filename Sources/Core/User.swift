// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct VOUser {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

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

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/users")!
    }

    public func urlForList(_ options: ListOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(url())?\(query)")!
        } else {
            url()
        }
    }

    // MARK: - Payloads

    public struct ListOptions {
        public let query: String?
        public let organizationID: String?
        public let groupID: String?
        public let excludeGroupMembers: Bool?
        public let size: Int?
        public let page: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?

        public var urlQuery: String? {
            var items: [URLQueryItem] = []
            if let query, let base64Query = try? JSONEncoder().encode(query).base64EncodedString() {
                items.append(.init(name: "query", value: base64Query))
            }
            if let organizationID {
                items.append(.init(name: "organization_id", value: organizationID))
            }
            if let groupID {
                items.append(.init(name: "group_id", value: groupID))
            }
            if let excludeGroupMembers {
                items.append(.init(name: "exclude_group_members", value: String(excludeGroupMembers)))
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
        case email
        case fullName

        public var description: String {
            switch self {
            case .email:
                "email"
            case .fullName:
                "full_name"
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
        public let username: String
        public let email: String
        public let fullName: String
        public let picture: String?
    }

    public struct List: Codable {
        public let data: [Entity]
        public let totalPages: Int
        public let totalElements: Int
        public let page: Int
        public let size: Int
    }
}

public struct VOAuthUser {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetch() async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(url(), headers: headersWithAuthorization(accessToken)).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func delete(_ options: DeleteOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url(),
                method: .delete,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func updateFullName(_ options: UpdateFullNameOptions) async throws -> Entity {
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

    public func updateEmailRequest(_ options: UpdateEmailRequestOptions) async throws -> Entity {
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

    public func updateEmailConfirmation(_ options: UpdateEmailConfirmationOptions) async throws -> Entity {
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

    public func updatePassword(_ options: UpdatePasswordOptions) async throws -> Entity {
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

    public func updatePicture(data: Data, onProgress: ((Double) -> Void)? = nil) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.upload(
                multipartFormData: { multipartFormData in multipartFormData.append(data, withName: "file") },
                to: urlForUpdatePicture(),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            )
            .uploadProgress { progress in
                onProgress?(progress.fractionCompleted * 100)
            }.responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func deletePicture() async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForDeletePicture(),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/user")!
    }

    public func urlForUpdateFullName() -> URL {
        URL(string: "\(url())/update_full_name")!
    }

    public func urlForUpdateEmailRequest() -> URL {
        URL(string: "\(url())/update_email_request")!
    }

    public func urlForUpdateEmailConfirmation(token _: String) -> URL {
        URL(string: "\(url())/update_email_confirmation")!
    }

    public func urlForUpdatePassword() -> URL {
        URL(string: "\(url())/update_password")!
    }

    public func urlForUpdatePicture() -> URL {
        URL(string: "\(url())/update_picture")!
    }

    public func urlForDeletePicture() -> URL {
        URL(string: "\(url())/delete_picture")!
    }

    // MARK: - Payloads

    public struct UpdateFullNameOptions: Codable {
        public let fullName: String

        public init(fullName: String) {
            self.fullName = fullName
        }
    }

    public struct UpdateEmailRequestOptions: Codable {
        public let email: String

        public init(email: String) {
            self.email = email
        }
    }

    public struct UpdateEmailConfirmationOptions: Codable {
        public let token: String

        public init(token: String) {
            self.token = token
        }
    }

    public struct UpdatePasswordOptions: Codable {
        public let currentPassword: String
        public let newPassword: String

        public init(currentPassword: String, newPassword: String) {
            self.currentPassword = currentPassword
            self.newPassword = newPassword
        }
    }

    public struct DeleteOptions: Codable {
        public let password: String

        public init(password: String) {
            self.password = password
        }
    }

    // MARK: - Types

    public struct Entity: Codable {
        public let id: String
        public let username: String
        public let email: String
        public let fullName: String
        public let picture: String?

        public init(
            id: String,
            username: String,
            email: String,
            fullName: String,
            picture: String? = nil
        ) {
            self.id = id
            self.username = username
            self.email = email
            self.fullName = fullName
            self.picture = picture
        }
    }
}
