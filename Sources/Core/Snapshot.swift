// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

public struct Snapshot {
    public var baseURL: String
    public var accessToken: String

    public enum SortBy: Codable, CustomStringConvertible {
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
