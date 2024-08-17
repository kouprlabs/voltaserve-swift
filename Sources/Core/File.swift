// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct VOFile {
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

    public func fetchPath(_ id: String) async throws -> [Entity] {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(urlForPath(id), headers: headersWithAuthorization(accessToken)).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: [Entity].self)
            }
        }
    }

    public func fetchCount(_ id: String) async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(urlForCount(id), headers: headersWithAuthorization(accessToken)).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Int.self)
            }
        }
    }

    public func fetchList(_ id: String, options: ListOptions) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForList(id: id, options: options),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: List.self)
            }
        }
    }

    public func fetchSegmentedPage(_ id: String, page: Int, fileExtension: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForSegmentedPage(id: id, page: page, fileExtension: fileExtension),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleDataResponse(continuation: continuation, response: response)
            }
        }
    }

    public func fetchSegmentedThumbnail(_ id: String, page: Int, fileExtension: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForSegmentedThumbnail(id: id, page: page, fileExtension: String(fileExtension.dropFirst())),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleDataResponse(continuation: continuation, response: response)
            }
        }
    }

    public func fetchUserPermissions(_ id: String) async throws -> UserPermission {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForUserPermissions(id: id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: UserPermission.self)
            }
        }
    }

    public func fetchGroupPermissions(_ id: String) async throws -> GroupPermission {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForGroupPermissions(id: id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: GroupPermission.self)
            }
        }
    }

    public func create(_ options: CreateOptions) async throws -> Entity {
        switch options.type {
        case .file:
            try await upload(urlForCreate(options), method: .post, data: options.data!)
        case .folder:
            try await withCheckedThrowingContinuation { continuation in
                AF.request(
                    urlForCreate(options),
                    method: .post,
                    headers: headersWithAuthorization(accessToken)
                ).responseData { response in
                    handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
                }
            }
        }
    }

    public func patch(_ id: String, options: PatchOptions) async throws -> Entity {
        try await upload(urlForID(id), method: .patch, data: options.data)
    }

    func upload(
        _ url: URL,
        method: HTTPMethod,
        data: Data,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "file")
            }, to: url, method: method, headers: headersWithAuthorization(accessToken))
                .uploadProgress { progress in
                    onProgress?(progress.fractionCompleted * 100)
                }
                .responseData { response in
                    handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
                }
        }
    }

    public func patchName(id: String, options: PatchNameOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForPatchName(id),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func delete(id: String) async throws {
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

    public func move(_ id: String, to targetID: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForMove(id, to: targetID),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func move(_ options: MoveOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForMove(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func copy(_ id: String, to targetID: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForCopy(id, to: targetID),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func copy(_ options: MoveOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForCopy(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func grantUserPermission(_ options: GrantUserPermissionOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForGrantUserPermission(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func revokeUserPermission(_ options: RevokeUserPermissionOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForRevokeUserPermission(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func grantGroupPermission(_ options: GrantGroupPermissionOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForGrantGroupPermission(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func revokeGroupPermission(_ options: RevokeGroupPermissionOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForRevokeGroupPermission(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/files")!
    }

    public func urlForID(_ id: String) -> URL {
        URL(string: "\(baseURL)/files/\(id)")!
    }

    public func urlForPath(_ id: String) -> URL {
        URL(string: "\(baseURL)/files/\(id)/path")!
    }

    public func urlForCount(_ id: String) -> URL {
        URL(string: "\(baseURL)/files/\(id)/count")!
    }

    public func urlForPatchName(_ id: String) -> URL {
        URL(string: "\(baseURL)/files/\(id)/name")!
    }

    public func urlForMove(_ id: String, to targetID: String) -> URL {
        URL(string: "\(baseURL)/files/\(id)/move/\(targetID)")!
    }

    public func urlForMove() -> URL {
        URL(string: "\(baseURL)/files/move")!
    }

    public func urlForCopy(_ id: String, to targetID: String) -> URL {
        URL(string: "\(baseURL)/files/\(id)/copy/\(targetID)")!
    }

    public func urlForCopy() -> URL {
        URL(string: "\(baseURL)/files/copy")!
    }

    public func urlForList(id: String, options: ListOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(urlForID(id))?\(query)")!
        } else {
            urlForID(id)
        }
    }

    public func urlForCreate(_ options: CreateOptions) -> URL {
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: options.type.rawValue),
            URLQueryItem(name: "workspace_id", value: options.workspaceID)
        ]
        if let parentID = options.parentID {
            urlComponents.queryItems?.append(URLQueryItem(name: "parent_id", value: parentID))
        }
        if let name = options.name {
            urlComponents.queryItems?.append(URLQueryItem(name: "name", value: name))
        }
        let query = urlComponents.url?.query
        return URL(string: "\(baseURL)/v2/files?" + query!)!
    }

    public func urlForOriginal(id: String, fileExtension: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/original.\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    public func urlForPreview(id: String, fileExtension: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/preview.\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    public func urlForSegmentedPage(id: String, page: Int, fileExtension: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/segmentation/pages/\(page).\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    public func urlForSegmentedThumbnail(id: String, page: Int, fileExtension: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/segmentation/thumbnails/\(page).\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    public func urlForUserPermissions(id: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/user_permissions")!
    }

    public func urlForGroupPermissions(id: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/group_permissions")!
    }

    public func urlForGrantUserPermission() -> URL {
        URL(string: "\(baseURL)/v2/files/grant_user_permission")!
    }

    public func urlForRevokeUserPermission() -> URL {
        URL(string: "\(baseURL)/v2/files/revoke_user_permission")!
    }

    public func urlForGrantGroupPermission() -> URL {
        URL(string: "\(baseURL)/v2/files/grant_group_permission")!
    }

    public func urlForRevokeGroupPermission() -> URL {
        URL(string: "\(baseURL)/v2/files/revoke_group_permission")!
    }

    // MARK: - Payloads

    public struct PatchOptions {
        public let data: Data
        public let onProgress: ((Double) -> Void)?
    }

    public struct ListOptions: Codable {
        public let size: Int?
        public let page: Int?
        public let type: FileType?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?
        public let query: Query?

        var urlQuery: String? {
            var items: [URLQueryItem] = []
            if let page {
                items.append(.init(name: "page", value: String(page)))
            }
            if let size {
                items.append(.init(name: "size", value: String(size)))
            }
            if let sortBy {
                items.append(.init(name: "sort_by", value: sortBy.rawValue))
            }
            if let sortOrder {
                items.append(.init(name: "sort_order", value: sortOrder.rawValue))
            }
            if let type {
                items.append(.init(name: "type", value: type.rawValue))
            }
            if let query, let base64Query = try? JSONEncoder().encode(query).base64EncodedString() {
                items.append(.init(name: "query", value: base64Query))
            }
            var components = URLComponents()
            components.queryItems = items
            return components.url?.query
        }
    }

    public enum SortBy: String, Codable, CustomStringConvertible {
        case name
        case kind
        case size
        case dateCreated
        case dateModified

        public var description: String {
            switch self {
            case .name:
                "name"
            case .kind:
                "kind"
            case .size:
                "size"
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

    public struct CreateOptions {
        public let type: FileType
        public let workspaceID: String
        public let parentID: String?
        public let name: String?
        public let data: Data?
        public let onProgress: ((Double) -> Void)?

        enum CodingKeys: String, CodingKey {
            case type
            case workspaceID = "workspaceId"
            case parentID = "parentId"
            case name
            case data
        }
    }

    public struct PatchNameOptions: Codable {
        public let name: String
    }

    public struct DeleteOptions: Codable {
        public let ids: [String]
    }

    public struct MoveOptions: Codable {
        public let sourceIDs: [String]
        public let targetID: String

        enum CodingKeys: String, CodingKey {
            case sourceIDs = "sourceIds"
            case targetID = "targetId"
        }
    }

    public struct GrantUserPermissionOptions: Codable {
        public let ids: [String]
        public let userID: String
        public let permission: String

        enum CodingKeys: String, CodingKey {
            case ids
            case userID = "userId"
            case permission
        }
    }

    public struct RevokeUserPermissionOptions: Codable {
        public let ids: [String]
        public let userID: String

        enum CodingKeys: String, CodingKey {
            case ids
            case userID = "userId"
        }
    }

    public struct GrantGroupPermissionOptions: Codable {
        public let ids: [String]
        public let groupID: String
        public let permission: String

        enum CodingKeys: String, CodingKey {
            case ids
            case groupID = "groupId"
            case permission
        }
    }

    public struct RevokeGroupPermissionOptions: Codable {
        public let ids: [String]
        public let groupID: String

        enum CodingKeys: String, CodingKey {
            case ids
            case groupID = "groupId"
        }
    }

    // MARK: - Types

    public enum FileType: String, Codable {
        case file
        case folder
    }

    public enum PermissionType: String, Codable {
        case viewer
        case editor
        case owner
    }

    public struct Entity: Codable {
        public let id: String
        public let workspaceID: String
        public let name: String
        public let type: FileType
        public let parentID: String
        public let permission: PermissionType
        public let isShared: Bool
        public let snapshot: VOSnapshot.Entity?
        public let createTime: String
        public let updateTime: String?

        enum CodingKeys: String, CodingKey {
            case id
            case workspaceID = "workspaceId"
            case name
            case type
            case parentID = "parentId"
            case permission
            case isShared
            case snapshot
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
        public let query: Query?
    }

    public struct UserPermission: Codable {
        public let id: String
        public let user: VOUser.Entity
        public let permission: String
    }

    public struct GroupPermission: Codable {
        public let id: String
        public let group: VOGroup.Entity
        public let permission: String
    }

    public struct Query: Codable {
        public let text: String
        public let type: FileType?
        public let createTimeAfter: Int?
        public let createTimeBefore: Int?
        public let updateTimeAfter: Int?
        public let updateTimeBefore: Int?

        static func encodeToBase64(_ value: String) -> String {
            guard let data = value.data(using: .utf8) else {
                return ""
            }
            return data.base64EncodedString()
        }

        static func decodeFromBase64(_ value: String) -> String? {
            guard !value.isEmpty, let data = Data(base64Encoded: value) else {
                return nil
            }
            return String(decoding: data, as: UTF8.self)
        }
    }
}
