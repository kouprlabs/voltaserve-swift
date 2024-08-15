// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

struct Mosaic {
    var baseURL: String
    var accessToken: String

    func fetchInfoForFile(id: String) async throws -> Info {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                "\(baseURL)/v2/mosaics/\(id)/info",
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                if let data = response.data {
                    do {
                        let result = try JSONDecoder().decode(Info.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    func fetchDataForFile(id: String,
                          zoomLevel: ZoomLevel,
                          forCellAtRow row: Int, col: Int,
                          fileExtension: String) async throws -> Data
    {
        try await withCheckedThrowingContinuation { continuation in
            let url = "\(baseURL)/v2/mosaics/\(id)/zoom_level/\(zoomLevel.index)" +
                "/row/\(row)/col/\(col)/ext/\(fileExtension)?" +
                "access_token=\(accessToken)"
            AF.request(url).responseData { response in
                if let data = response.data {
                    continuation.resume(returning: data)
                } else if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: MosaicError.unknown)
                }
            }
        }
    }

    enum MosaicError: Error {
        case unknown
    }

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
