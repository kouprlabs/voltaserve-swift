// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct Mosaic {
    public var baseURL: String
    public var accessToken: String

    // MARK: - Requests

    public func createForFile(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForFile(id),
                method: .post,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func deleteForFile(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForFile(id),
                method: .delete,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func fetchInfoForFile(id: String) async throws -> Info {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForFile(id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Info.self)
            }
        }
    }

    public func fetchDataForFile(
        _ id: String,
        zoomLevel: ZoomLevel,
        forCellAtRow row: Int, col: Int,
        fileExtension: String
    ) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForTile(id, zoomLevel: zoomLevel, row: row, col: col, fileExtension: fileExtension),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleDataResponse(continuation: continuation, response: response)
            }
        }
    }

    // MARK: - URLs

    public func urlForFile(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/mosaics/\(id)")!
    }

    public func urlForInfo(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/mosaics/\(id)/info")!
    }

    public func urlForTile(
        _ id: String,
        zoomLevel: ZoomLevel,
        row: Int,
        col: Int,
        fileExtension: String
    ) -> URL {
        URL(string: "\(baseURL)/v2/mosaics/\(id)/zoom_level/\(zoomLevel.index)" +
            "/row/\(row)/col/\(col)/ext/\(fileExtension)?" +
            "access_token=\(accessToken)")!
    }

    // MARK: - Types

    public struct Info: Codable {
        public var metadata: Metadata
    }

    public struct Metadata: Codable {
        public let width: Int
        public let height: Int
        public let fileExtension: String
        public let zoomLevels: [ZoomLevel]

        enum CodingKeys: String, CodingKey {
            case width
            case height
            case fileExtension = "extension"
            case zoomLevels
        }
    }

    public struct ZoomLevel: Codable {
        public let index: Int
        public let width: Int
        public let height: Int
        public let rows: Int
        public let cols: Int
        public let scaleDownPercentage: Float
        public let tile: Tile
    }

    public struct Tile: Codable {
        public let width: Int
        public let height: Int
        public let lastColWidth: Int
        public let lastRowHeight: Int
    }
}
