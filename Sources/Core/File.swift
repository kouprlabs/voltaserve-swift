// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

struct File {
    var baseURL: String
    var accessToken: String

    // MARK: - Requests

    func fetch(_ id: String) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForID(id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    func fetchPath(_ id: String) async throws -> [Entity] {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(urlForPath(id), headers: headersWithAuthorization(accessToken)).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: [Entity].self)
            }
        }
    }

    func fetchCount(id: String) async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(urlForCount(id), headers: headersWithAuthorization(accessToken)).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Int.self)
            }
        }
    }

    func fetchList(_ id: String, options: ListOptions) async throws -> List {
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

    func fetchSegmentedPage(_ id: String, page: Int, fileExtension: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForSegmentedPage(id: id, page: page, fileExtension: fileExtension),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleDataResponse(continuation: continuation, response: response)
            }
        }
    }

    func fetchSegmentedThumbnail(_ id: String, page: Int, fileExtension: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForSegmentedThumbnail(id: id, page: page, fileExtension: String(fileExtension.dropFirst())),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleDataResponse(continuation: continuation, response: response)
            }
        }
    }

    func fetchUserPermissions(_ id: String) async throws -> UserPermission {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForUserPermissions(id: id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: UserPermission.self)
            }
        }
    }

    func fetchGroupPermissions(_ id: String) async throws -> GroupPermission {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForGroupPermissions(id: id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: GroupPermission.self)
            }
        }
    }

    func create(_ options: CreateOptions) async throws -> Entity {
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

    func patch(_ id: String, options: PatchOptions) async throws -> Entity {
        try await upload(urlForID(id), method: .patch, data: options.data)
    }

    private func upload(
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

    func patchName(id: String, options: PatchNameOptions) async throws -> Entity {
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

    func delete(id: String) async throws {
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

    func delete(_ options: DeleteOptions) async throws {
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

    func move(_ id: String, to targetID: String) async throws {
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

    func move(_ options: MoveOptions) async throws {
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

    func copy(_ id: String, to targetID: String) async throws {
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

    func copy(_ options: MoveOptions) async throws {
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

    func grantUserPermission(_ options: GrantUserPermissionOptions) async throws {
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

    func revokeUserPermission(_ options: RevokeUserPermissionOptions) async throws {
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

    func grantGroupPermission(_ options: GrantGroupPermissionOptions) async throws {
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

    func revokeGroupPermission(_ options: RevokeGroupPermissionOptions) async throws {
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

    func url() -> URL {
        URL(string: "\(baseURL)/v2/files")!
    }

    func urlForID(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)")!
    }

    func urlForPath(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/path")!
    }

    func urlForCount(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/count")!
    }

    func urlForPatchName(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/name")!
    }

    func urlForMove(_ id: String, to targetID: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/move/\(targetID)")!
    }

    func urlForMove() -> URL {
        URL(string: "\(baseURL)/v2/files/move")!
    }

    func urlForCopy(_ id: String, to targetID: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/copy/\(targetID)")!
    }

    func urlForCopy() -> URL {
        URL(string: "\(baseURL)/v2/files/copy")!
    }

    func urlForList(id: String, options: ListOptions) -> URL {
        var urlComponents = URLComponents()
        if let page = options.page {
            urlComponents.queryItems?.append(URLQueryItem(name: "page", value: String(page)))
        }
        if let size = options.size {
            urlComponents.queryItems?.append(URLQueryItem(name: "size", value: String(size)))
        }
        if let sortBy = options.sortBy {
            urlComponents.queryItems?.append(URLQueryItem(name: "sort_by", value: sortBy.rawValue))
        }
        if let sortOrder = options.sortOrder {
            urlComponents.queryItems?.append(URLQueryItem(name: "sort_order", value: sortOrder.rawValue))
        }
        if let type = options.type {
            urlComponents.queryItems?.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        if let query = options.query {
            if let base64Query = try? JSONEncoder().encode(query).base64EncodedString() {
                urlComponents.queryItems?.append(URLQueryItem(name: "query", value: base64Query))
            }
        }
        let query = urlComponents.url?.query
        if let query {
            return URL(string: "\(baseURL)/v2/files/\(id)?\(query)")!
        } else {
            return URL(string: "\(baseURL)/v2/files/\(id)")!
        }
    }

    func urlForCreate(_ options: CreateOptions) -> URL {
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

    func urlForOriginal(id: String, fileExtension: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/original.\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    func urlForPreview(id: String, fileExtension: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/preview.\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    func urlForSegmentedPage(id: String, page: Int, fileExtension: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/segmentation/pages/\(page).\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    func urlForSegmentedThumbnail(id: String, page: Int, fileExtension: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/segmentation/thumbnails/\(page).\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    func urlForUserPermissions(id: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/user_permissions")!
    }

    func urlForGroupPermissions(id: String) -> URL {
        URL(string: "\(baseURL)/v2/files/\(id)/group_permissions")!
    }

    func urlForGrantUserPermission() -> URL {
        URL(string: "\(baseURL)/v2/files/grant_user_permission")!
    }

    func urlForRevokeUserPermission() -> URL {
        URL(string: "\(baseURL)/v2/files/revoke_user_permission")!
    }

    func urlForGrantGroupPermission() -> URL {
        URL(string: "\(baseURL)/v2/files/grant_group_permission")!
    }

    func urlForRevokeGroupPermission() -> URL {
        URL(string: "\(baseURL)/v2/files/revoke_group_permission")!
    }

    // MARK: - Payloads

    struct PatchOptions {
        let data: Data
        let onProgress: ((Double) -> Void)?
    }

    struct ListOptions: Codable {
        let size: Int?
        let page: Int?
        let type: FileType?
        let sortBy: SortBy?
        let sortOrder: SortOrder?
        let query: Query?
    }

    struct CreateOptions {
        let type: FileType
        let workspaceID: String
        let parentID: String?
        let name: String?
        let data: Data?
        let onProgress: ((Double) -> Void)?
    }

    struct PatchNameOptions: Codable {
        let name: String
    }

    struct DeleteOptions: Codable {
        let ids: [String]
    }

    struct MoveOptions: Codable {
        let sourceIds: [String]
        let targetId: String
    }

    struct GrantUserPermissionOptions: Codable {
        let ids: [String]
        let userId: String
        let permission: String
    }

    struct RevokeUserPermissionOptions: Codable {
        let ids: [String]
        let userId: String
    }

    struct GrantGroupPermissionOptions: Codable {
        let ids: [String]
        let groupId: String
        let permission: String
    }

    struct RevokeGroupPermissionOptions: Codable {
        let ids: [String]
        let groupId: String
    }

    // MARK: - Types

    enum FileType: String, Codable {
        case file
        case folder
    }

    enum SortBy: String, Codable, CustomStringConvertible {
        case name
        case kind
        case size
        case dateCreated
        case dateModified

        var description: String {
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

    enum SortOrder: String, Codable {
        case asc
        case desc
    }

    enum PermissionType: String, Codable {
        case viewer
        case editor
        case owner
    }

    struct Entity: Codable {
        let id: String
        let workspaceId: String
        let name: String
        let type: FileType
        let parentId: String
        let permission: PermissionType
        let isShared: Bool
        let snapshot: Snapshot.Entity?
        let createTime: String
        let updateTime: String?
    }

    struct List: Codable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
        let query: Query?
    }

    struct UserPermission: Codable {
        let id: String
        let user: User.Entity
        let permission: String
    }

    struct GroupPermission: Codable {
        let id: String
        let group: Group.Entity
        let permission: String
    }

    struct Query: Codable {
        let text: String
        let type: FileType?
        let createTimeAfter: Int?
        let createTimeBefore: Int?
        let updateTimeAfter: Int?
        let updateTimeBefore: Int?

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
