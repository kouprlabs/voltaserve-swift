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
            AF.request(
                urlForPath(id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
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

    public func fetchUserPermissions(_ id: String) async throws -> [UserPermission] {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForUserPermissions(id: id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: [UserPermission].self)
            }
        }
    }

    public func fetchGroupPermissions(_ id: String) async throws -> [GroupPermission] {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForGroupPermissions(id: id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: [GroupPermission].self)
            }
        }
    }

    public func createFile(_ options: CreateFileOptions) async throws -> Entity {
        try await upload(urlForCreateFile(options), method: .post, data: options.data)
    }

    public func createFolder(_ options: CreateFolderOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForCreateFolder(options),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
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
            AF.upload(
                // If we don't give a value in fileName, Alamofire doesn't populate the "file" form field
                multipartFormData: { $0.append(data, withName: "file", fileName: "file") },
                to: url,
                method: method,
                headers: headersWithAuthorization(accessToken)
            )
            .uploadProgress { progress in
                onProgress?(progress.fractionCompleted * 100)
            }
            .responseData { response in
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

    public func move(_ id: String, to targetID: String) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForMove(id, to: targetID),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func move(_ options: MoveOptions) async throws -> MoveResult {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForMove(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: MoveResult.self)
            }
        }
    }

    public func copy(_ id: String, to targetID: String) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForCopy(id, to: targetID),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Entity.self)
            }
        }
    }

    public func copy(_ options: CopyOptions) async throws -> CopyResult {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForCopy(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: CopyResult.self)
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
        URL(string: "\(url())/\(id)")!
    }

    public func urlForPath(_ id: String) -> URL {
        URL(string: "\(urlForID(id))/path")!
    }

    public func urlForCount(_ id: String) -> URL {
        URL(string: "\(urlForID(id))/count")!
    }

    public func urlForName(_ id: String) -> URL {
        URL(string: "\(urlForID(id))/name")!
    }

    public func urlForMove(_ id: String, to targetID: String) -> URL {
        URL(string: "\(urlForID(id))/move/\(targetID)")!
    }

    public func urlForMove() -> URL {
        URL(string: "\(url())/move")!
    }

    public func urlForCopy(_ id: String, to targetID: String) -> URL {
        URL(string: "\(urlForID(id))/copy/\(targetID)")!
    }

    public func urlForCopy() -> URL {
        URL(string: "\(url())/copy")!
    }

    public func urlForList(id: String, options: ListOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(urlForID(id))/list?\(query)")!
        } else {
            urlForID(id)
        }
    }

    public func urlForCreateFile(_ options: CreateFileOptions) -> URL {
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            .init(name: "type", value: FileType.file.rawValue),
            .init(name: "workspace_id", value: options.workspaceID),
            .init(name: "name", value: options.name)
        ]
        if let parentID = options.parentID {
            urlComponents.queryItems?.append(.init(name: "parent_id", value: parentID))
        }
        let query = urlComponents.url?.query
        return URL(string: "\(url())?" + query!)!
    }

    public func urlForCreateFolder(_ options: CreateFolderOptions) -> URL {
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            .init(name: "type", value: FileType.folder.rawValue),
            .init(name: "workspace_id", value: options.workspaceID),
            .init(name: "name", value: options.name)
        ]
        if let parentID = options.parentID {
            urlComponents.queryItems?.append(URLQueryItem(name: "parent_id", value: parentID))
        }
        let query = urlComponents.url?.query
        return URL(string: "\(url())?" + query!)!
    }

    public func urlForOriginal(id: String, fileExtension: String) -> URL {
        URL(string: "\(urlForID(id))/original.\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    public func urlForPreview(id: String, fileExtension: String) -> URL {
        URL(string: "\(urlForID(id))/preview.\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    public func urlForSegmentedPage(id: String, page: Int, fileExtension: String) -> URL {
        URL(string: "\(urlForID(id))/segmentation/pages/\(page).\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    public func urlForSegmentedThumbnail(id: String, page: Int, fileExtension: String) -> URL {
        URL(string: "\(urlForID(id))/segmentation/thumbnails/\(page).\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    public func urlForUserPermissions(id: String) -> URL {
        URL(string: "\(urlForID(id))/user_permissions")!
    }

    public func urlForGroupPermissions(id: String) -> URL {
        URL(string: "\(urlForID(id))/group_permissions")!
    }

    public func urlForGrantUserPermission() -> URL {
        URL(string: "\(url())/grant_user_permission")!
    }

    public func urlForRevokeUserPermission() -> URL {
        URL(string: "\(url())/revoke_user_permission")!
    }

    public func urlForGrantGroupPermission() -> URL {
        URL(string: "\(url())/grant_group_permission")!
    }

    public func urlForRevokeGroupPermission() -> URL {
        URL(string: "\(url())/revoke_group_permission")!
    }

    // MARK: - Payloads

    public struct PatchOptions {
        public let data: Data
        public let onProgress: ((Double) -> Void)?

        public init(data: Data, onProgress: ((Double) -> Void)? = nil) {
            self.data = data
            self.onProgress = onProgress
        }
    }

    public struct ListOptions {
        public let page: Int?
        public let size: Int?
        public let type: FileType?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?
        public let query: Query?

        public init(
            page: Int? = nil,
            size: Int? = nil,
            type: FileType? = nil,
            sortBy: SortBy? = nil,
            sortOrder: SortOrder? = nil,
            query: Query? = nil
        ) {
            self.size = size
            self.page = page
            self.type = type
            self.sortBy = sortBy
            self.sortOrder = sortOrder
            self.query = query
        }

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

    public struct CreateFileOptions {
        public let workspaceID: String
        public let parentID: String?
        public let name: String
        public let data: Data
        public let onProgress: ((Double) -> Void)?

        public init(
            workspaceID: String,
            parentID: String? = nil,
            name: String,
            data: Data,
            onProgress: ((Double) -> Void)? = nil
        ) {
            self.workspaceID = workspaceID
            self.parentID = parentID
            self.name = name
            self.data = data
            self.onProgress = onProgress
        }

        enum CodingKeys: String, CodingKey {
            case workspaceID = "workspaceId"
            case parentID = "parentId"
            case name
            case data
        }
    }

    public struct CreateFolderOptions {
        public let workspaceID: String
        public let parentID: String?
        public let name: String

        public init(
            workspaceID: String,
            parentID: String? = nil,
            name: String
        ) {
            self.workspaceID = workspaceID
            self.parentID = parentID
            self.name = name
        }

        enum CodingKeys: String, CodingKey {
            case workspaceID = "workspaceId"
            case parentID = "parentId"
            case name
        }
    }

    public struct PatchNameOptions: Codable {
        public let name: String

        public init(name: String) {
            self.name = name
        }
    }

    public struct DeleteOptions: Codable {
        public let ids: [String]

        public init(ids: [String]) {
            self.ids = ids
        }
    }

    public struct MoveOptions: Codable {
        public let sourceIDs: [String]
        public let targetID: String

        public init(sourceIDs: [String], targetID: String) {
            self.sourceIDs = sourceIDs
            self.targetID = targetID
        }

        enum CodingKeys: String, CodingKey {
            case sourceIDs = "sourceIds"
            case targetID = "targetId"
        }
    }

    public struct CopyOptions: Codable {
        public let sourceIDs: [String]
        public let targetID: String

        public init(sourceIDs: [String], targetID: String) {
            self.sourceIDs = sourceIDs
            self.targetID = targetID
        }

        enum CodingKeys: String, CodingKey {
            case sourceIDs = "sourceIds"
            case targetID = "targetId"
        }
    }

    public struct GrantUserPermissionOptions: Codable {
        public let ids: [String]
        public let userID: String
        public let permission: String

        public init(ids: [String], userID: String, permission: String) {
            self.ids = ids
            self.userID = userID
            self.permission = permission
        }

        enum CodingKeys: String, CodingKey {
            case ids
            case userID = "userId"
            case permission
        }
    }

    public struct RevokeUserPermissionOptions: Codable {
        public let ids: [String]
        public let userID: String

        public init(ids: [String], userID: String) {
            self.ids = ids
            self.userID = userID
        }

        enum CodingKeys: String, CodingKey {
            case ids
            case userID = "userId"
        }
    }

    public struct GrantGroupPermissionOptions: Codable {
        public let ids: [String]
        public let groupID: String
        public let permission: String

        public init(ids: [String], groupID: String, permission: String) {
            self.ids = ids
            self.groupID = groupID
            self.permission = permission
        }

        enum CodingKeys: String, CodingKey {
            case ids
            case groupID = "groupId"
            case permission
        }
    }

    public struct RevokeGroupPermissionOptions: Codable {
        public let ids: [String]
        public let groupID: String

        public init(ids: [String], groupID: String) {
            self.ids = ids
            self.groupID = groupID
        }

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
        public let parentID: String?
        public let permission: PermissionType
        public let isShared: Bool
        public let snapshot: VOSnapshot.Entity?
        public let createTime: String
        public let updateTime: String?

        public init(
            id: String,
            workspaceID: String,
            name: String,
            type: FileType,
            parentID: String?,
            permission: PermissionType,
            isShared: Bool,
            snapshot: VOSnapshot.Entity? = nil,
            createTime: String,
            updateTime: String? = nil
        ) {
            self.id = id
            self.workspaceID = workspaceID
            self.name = name
            self.type = type
            self.parentID = parentID
            self.permission = permission
            self.isShared = isShared
            self.snapshot = snapshot
            self.createTime = createTime
            self.updateTime = updateTime
        }

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

        public init(
            data: [Entity],
            totalPages: Int,
            totalElements: Int,
            page: Int,
            size: Int,
            query: Query? = nil
        ) {
            self.data = data
            self.totalPages = totalPages
            self.totalElements = totalElements
            self.page = page
            self.size = size
            self.query = query
        }
    }

    public struct UserPermission: Codable {
        public let id: String
        public let user: VOUser.Entity
        public let permission: VOPermission.Value

        public init(id: String, user: VOUser.Entity, permission: VOPermission.Value) {
            self.id = id
            self.user = user
            self.permission = permission
        }
    }

    public struct GroupPermission: Codable {
        public let id: String
        public let group: VOGroup.Entity
        public let permission: VOPermission.Value

        public init(id: String, group: VOGroup.Entity, permission: VOPermission.Value) {
            self.id = id
            self.group = group
            self.permission = permission
        }
    }

    public struct Query: Codable {
        public let text: String
        public let type: FileType?
        public let createTimeAfter: Int?
        public let createTimeBefore: Int?
        public let updateTimeAfter: Int?
        public let updateTimeBefore: Int?

        public init(
            text: String, type: FileType? = nil,
            createTimeAfter: Int? = nil,
            createTimeBefore: Int? = nil,
            updateTimeAfter: Int? = nil,
            updateTimeBefore: Int? = nil
        ) {
            self.text = text
            self.type = type
            self.createTimeAfter = createTimeAfter
            self.createTimeBefore = createTimeBefore
            self.updateTimeAfter = updateTimeAfter
            self.updateTimeBefore = updateTimeBefore
        }

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

    public struct CopyResult: Codable {
        public let new: [String]
        public let succeeded: [String]
        public let failed: [String]

        public init(new: [String], succeeded: [String], failed: [String]) {
            self.new = new
            self.succeeded = succeeded
            self.failed = failed
        }
    }

    public struct MoveResult: Codable {
        public let succeeded: [String]
        public let failed: [String]

        public init(succeeded: [String], failed: [String]) {
            self.succeeded = succeeded
            self.failed = failed
        }
    }
}
