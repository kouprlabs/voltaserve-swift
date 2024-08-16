// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

struct Mosaic {
    var baseURL: String
    var accessToken: String

    // MARK: - Requests

    func createForFile(_ id: String) async throws {
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

    func deleteForFile(_ id: String) async throws {
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

    func fetchInfoForFile(id: String) async throws -> Info {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForFile(id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Info.self)
            }
        }
    }

    func fetchDataForFile(
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

    func urlForFile(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/mosaics/\(id)")!
    }

    func urlForInfo(_ id: String) -> URL {
        URL(string: "\(baseURL)/v2/mosaics/\(id)/info")!
    }

    func urlForTile(
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

    struct Info: Codable {
        var metadata: Metadata
    }

    struct Metadata: Codable {
        var width: Int
        var height: Int
        var fileExtension: String
        var zoomLevels: [ZoomLevel]

        enum CodingKeys: String, CodingKey {
            case width
            case height
            case fileExtension = "extension"
            case zoomLevels
        }
    }

    struct ZoomLevel: Codable {
        var index: Int
        var width: Int
        var height: Int
        var rows: Int
        var cols: Int
        var scaleDownPercentage: Float
        var tile: Tile
    }

    struct Tile: Codable {
        var width: Int
        var height: Int
        var lastColWidth: Int
        var lastRowHeight: Int
    }
}
