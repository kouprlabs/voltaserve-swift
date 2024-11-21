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

public struct VOSnapshot {
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

    public func activate(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForActivate(id))
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

    public func detach(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForDetach(id))
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
        URL(string: "\(baseURL)/snapshots")!
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

    public func urlForActivate(_ id: String) -> URL {
        URL(string: "\(urlForID(id))/activate")!
    }

    public func urlForDetach(_ id: String) -> URL {
        URL(string: "\(urlForID(id))/detach")!
    }

    // MARK: - Payloads

    public struct ListOptions {
        public let fileID: String
        public let organizationID: String?
        public let page: Int?
        public let size: Int?
        public let sortBy: SortBy?
        public let sortOrder: SortOrder?

        public init(
            fileID: String,
            organizationID: String? = nil,
            page: Int? = nil,
            size: Int? = nil,
            sortBy: SortBy? = nil,
            sortOrder: SortOrder? = nil
        ) {
            self.fileID = fileID
            self.organizationID = organizationID
            self.size = size
            self.page = page
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }

        public var urlQuery: String? {
            var items: [URLQueryItem] = [.init(name: "file_id", value: fileID)]
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

        public init(fileID: String) {
            self.fileID = fileID
        }

        enum CodingKeys: String, CodingKey {
            case fileID = "fileId"
        }
    }

    public struct DetachOptions: Codable {
        public let fileID: String

        public init(fileID: String) {
            self.fileID = fileID
        }

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

    public struct Entity: Codable, Equatable, Hashable {
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

        public init(
            id: String,
            version: Int,
            status: Status,
            original: Download,
            preview: Download? = nil,
            ocr: Download? = nil,
            text: Download? = nil,
            entities: Download? = nil,
            mosaic: Download? = nil,
            segmentation: Download? = nil,
            thumbnail: Download? = nil,
            language: String? = nil,
            isActive: Bool,
            task: TaskInfo? = nil,
            createTime: String,
            updateTime: String? = nil
        ) {
            self.id = id
            self.version = version
            self.status = status
            self.original = original
            self.preview = preview
            self.ocr = ocr
            self.text = text
            self.entities = entities
            self.mosaic = mosaic
            self.segmentation = segmentation
            self.thumbnail = thumbnail
            self.language = language
            self.isActive = isActive
            self.task = task
            self.createTime = createTime
            self.updateTime = updateTime
        }
    }

    public struct List: Codable, Equatable {
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

    public enum Status: String, Codable {
        case waiting
        case processing
        case ready
        case error
    }

    public struct TaskInfo: Codable, Equatable, Hashable {
        public let id: String
        public let isPending: Bool

        public init(id: String, isPending: Bool) {
            self.id = id
            self.isPending = isPending
        }
    }

    public struct Download: Codable, Equatable, Hashable {
        public let fileExtension: String?
        public let size: Int?
        public let image: ImageProps?
        public let document: DocumentProps?

        public init(
            fileExtension: String? = nil,
            size: Int? = nil,
            image: ImageProps? = nil,
            document: DocumentProps? = nil
        ) {
            self.fileExtension = fileExtension
            self.size = size
            self.image = image
            self.document = document
        }

        enum CodingKeys: String, CodingKey {
            case fileExtension = "extension"
            case size
            case image
            case document
        }
    }

    public struct ImageProps: Codable, Equatable, Hashable {
        public let width: Int
        public let height: Int
        public let zoomLevels: [ZoomLevel]?

        public init(width: Int, height: Int, zoomLevels: [ZoomLevel]? = nil) {
            self.width = width
            self.height = height
            self.zoomLevels = zoomLevels
        }
    }

    public struct DocumentProps: Codable, Equatable, Hashable {
        public let pages: PagesProps?
        public let thumbnails: ThumbnailsProps?

        public init(pages: PagesProps? = nil, thumbnails: ThumbnailsProps? = nil) {
            self.pages = pages
            self.thumbnails = thumbnails
        }
    }

    public struct PagesProps: Codable, Equatable, Hashable {
        public let count: Int
        public let fileExtension: String

        public init(count: Int, fileExtension: String) {
            self.count = count
            self.fileExtension = fileExtension
        }

        enum CodingKeys: String, CodingKey {
            case count
            case fileExtension = "extension"
        }
    }

    public struct ThumbnailsProps: Codable, Equatable, Hashable {
        public let fileExtension: String

        public init(fileExtension: String) {
            self.fileExtension = fileExtension
        }

        enum CodingKeys: String, CodingKey {
            case fileExtension = "extension"
        }
    }

    public struct Tile: Codable, Equatable, Hashable {
        public let width: Int
        public let height: Int
        public let lastColWidth: Int
        public let lastRowHeight: Int

        public init(width: Int, height: Int, lastColWidth: Int, lastRowHeight: Int) {
            self.width = width
            self.height = height
            self.lastColWidth = lastColWidth
            self.lastRowHeight = lastRowHeight
        }
    }

    public struct ZoomLevel: Codable, Equatable, Hashable {
        public let index: Int
        public let width: Int
        public let height: Int
        public let rows: Int
        public let cols: Int
        public let scaleDownPercentage: Float
        public let tile: Tile

        public init(
            index: Int,
            width: Int,
            height: Int,
            rows: Int,
            cols: Int,
            scaleDownPercentage: Float,
            tile: Tile
        ) {
            self.index = index
            self.width = width
            self.height = height
            self.rows = rows
            self.cols = cols
            self.scaleDownPercentage = scaleDownPercentage
            self.tile = tile
        }
    }
}
