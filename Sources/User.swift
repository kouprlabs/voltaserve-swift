// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

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

        public init(
            query: String? = nil,
            organizationID: String? = nil,
            groupID: String? = nil,
            excludeGroupMembers: Bool? = nil,
            page: Int? = nil,
            size: Int? = nil,
            sortBy: SortBy? = nil,
            sortOrder: SortOrder? = nil
        ) {
            self.query = query
            self.organizationID = organizationID
            self.groupID = groupID
            self.excludeGroupMembers = excludeGroupMembers
            self.page = page
            self.size = size
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }

        public var urlQuery: String? {
            var items: [URLQueryItem] = []
            if let base64Query = query,
               let data = Data(base64Encoded: base64Query),
               let query = String(data: data, encoding: .utf8) {
                items.append(.init(name: "query", value: query))
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

    public struct Entity: Codable, Equatable, Hashable {
        public let id: String
        public let username: String
        public let email: String
        public let fullName: String
        public let picture: String?
        public let createTime: String
        public let updateTime: String?

        public init(
            id: String,
            username: String,
            email: String,
            fullName: String,
            picture: String? = nil,
            createTime: String,
            updateTime: String? = nil
        ) {
            self.id = id
            self.username = username
            self.email = email
            self.fullName = fullName
            self.picture = picture
            self.createTime = createTime
            self.updateTime = updateTime
        }
    }

    public struct List: Codable {
        public let data: [Entity]
        public let totalPages: Int
        public let totalElements: Int
        public let page: Int
        public let size: Int

        public init(
            data: [Entity],
            totalPages: Int,
            totalElements: Int,
            page: Int,
            size: Int
        ) {
            self.data = data
            self.totalPages = totalPages
            self.totalElements = totalElements
            self.page = page
            self.size = size
        }
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
            var request = URLRequest(url: url())
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

    public func delete(_: DeleteOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: url())
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

    public func updateFullName(_ options: UpdateFullNameOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForPatchFullName())
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

    public func updateEmailRequest(_ options: UpdateEmailRequestOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForUpdateEmailRequest())
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

    public func updateEmailConfirmation(_ options: UpdateEmailConfirmationOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForUpdateEmailConfirmation())
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

    public func updatePassword(_ options: UpdatePasswordOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForUpdatePassword())
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

    public func updatePicture(data: Data, onProgress: ((Double) -> Void)? = nil) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForUpdatePicture())
            request.httpMethod = "POST"
            request.appendAuthorizationHeader(accessToken)

            let boundary = UUID().uuidString
            request.setValue(
                "multipart/form-data; boundary=\(boundary)",
                forHTTPHeaderField: "Content-Type"
            )

            var httpBody = Data()
            httpBody.append(Data("--\(boundary)\r\n".utf8))
            httpBody.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"file\"\r\n".utf8))
            httpBody.append(Data("Content-Type: application/octet-stream\r\n\r\n".utf8))

            httpBody.append(data)
            httpBody.append(Data("\r\n--\(boundary)--\r\n".utf8))

            let task = URLSession.shared.uploadTask(with: request, from: httpBody) { responseData, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: responseData,
                    error: error,
                    type: Entity.self
                )
            }
            task.resume()

            if let onProgress {
                let progressHandler = {
                    onProgress(task.progress.fractionCompleted * 100)
                }
                let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    progressHandler()
                    if task.progress.isFinished {
                        timer.invalidate()
                    }
                }
                RunLoop.main.add(timer, forMode: .default)
            }
        }
    }

    public func deletePicture() async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForDeletePicture())
            request.httpMethod = "POST"
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

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/user")!
    }

    public func urlForPatchFullName() -> URL {
        URL(string: "\(url())/update_full_name")!
    }

    public func urlForUpdateEmailRequest() -> URL {
        URL(string: "\(url())/update_email_request")!
    }

    public func urlForUpdateEmailConfirmation() -> URL {
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

    public struct Entity: Codable, Equatable, Hashable {
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
