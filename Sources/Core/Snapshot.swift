// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct VOSnapshot {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetchList(options: ListOptions) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForList(options),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: List.self)
            }
        }
    }

    public func activate(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForActivate(id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func detach(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForDetach(id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/v2/snapshots")!
    }

    public func urlForList(_ options: ListOptions) -> URL {
        if let query = options.urlQuery {
            URL(string: "\(url())?\(query)")!
        } else {
            url()
        }
    }

    public func urlForActivate(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/snapshots/\(id)/activate")!
    }

    public func urlForDetach(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/snapshots/\(id)/detach")!
    }

    // MARK: - Payloads

    public struct ListOptions: Codable {
        public let fileID: String
        public let query: String?
        public let organizationID: String?
        public let size: Int?
        public let page: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?

        public var urlQuery: String? {
            var items: [URLQueryItem] = [.init(name: "file_id", value: fileID)]
            if let query, let base64Query = try? JSONEncoder().encode(query).base64EncodedString() {
                items.append(.init(name: "query", value: base64Query))
            }
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
            case fileID = "fileId"
            case query
            case organizationID = "organizationId"
            case size
            case page
            case sortBy
            case sortOrder
        }
    }

    public struct ActivateOptions: Codable {
        public let fileID: String

        enum CodingKeys: String, CodingKey {
            case fileID = "fileId"
        }
    }

    public struct DetachOptions: Codable {
        public let fileID: String

        enum CodingKeys: String, CodingKey {
            case fileID = "fileId"
        }
    }

    public enum SortBy: String, Codable, CustomStringConvertible {
        case version
        case dateCreated
        case dateModified

        public var description: String {
            switch self {
            case .version:
                "version"
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
        public let version: Int
        public let status: Status
        public let original: Download
        public let preview: Download?
        public let ocr: Download?
        public let text: Download?
        public let entities: Download?
        public let mosaic: Download?
        public let segmentation: Download?
        public let thumbnail: Download?
        public let language: String?
        public let isActive: Bool
        public let task: TaskInfo?
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

    public enum Status: String, Codable {
        case waiting
        case processing
        case ready
        case error
    }

    public struct TaskInfo: Codable {
        public let id: String
        public let isPending: Bool
    }

    public struct Download: Codable {
        public let fileExtension: String?
        public let size: Int?
        public let image: ImageProps?
        public let document: DocumentProps?

        enum CodingKeys: String, CodingKey {
            case fileExtension = "extension"
            case size
            case image
            case document
        }
    }

    public struct ImageProps: Codable {
        public let width: Int
        public let height: Int
        public let zoomLevels: [ZoomLevel]?
    }

    public struct DocumentProps: Codable {
        public let pages: PagesProps?
        public let thumbnails: ThumbnailsProps?
    }

    public struct PagesProps: Codable {
        public let count: Int
        public let fileExtension: String

        enum CodingKeys: String, CodingKey {
            case count
            case fileExtension = "extension"
        }
    }

    public struct ThumbnailsProps: Codable {
        public let fileExtension: String

        enum CodingKeys: String, CodingKey {
            case fileExtension = "extension"
        }
    }

    public struct Tile: Codable {
        public let width: Int
        public let height: Int
        public let lastColWidth: Int
        public let lastRowHeight: Int
    }

    public struct ZoomLevel: Codable {
        public let index: Int
        public let width: Int
        public let height: Int
        public let rows: Int
        public let cols: Int
        public let scaleDownPercentage: Int
        public let tile: Tile
    }
}
