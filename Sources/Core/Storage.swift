// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct VOStorage {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetchAccountUsage() async throws -> Usage {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForAccountUsage(),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Usage.self)
            }
        }
    }

    public func fetchWorkspaceUsage(_ id: String) async throws -> Usage {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForWokrspaceUsage(id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Usage.self)
            }
        }
    }

    public func fetchFileUsage(_ id: String) async throws -> Usage {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForFileUsage(id),
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Usage.self)
            }
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/storage")!
    }

    public func urlForAccountUsage() -> URL {
        URL(string: "\(url())/account_usage")!
    }

    public func urlForWokrspaceUsage(_ id: String) -> URL {
        var components = URLComponents(string: "\(url())/workspace_usage")
        components?.queryItems = [URLQueryItem(name: "id", value: id)]
        return components!.url!
    }

    public func urlForFileUsage(_ id: String) -> URL {
        var components = URLComponents(string: "\(url())/file_usage")
        components?.queryItems = [URLQueryItem(name: "id", value: id)]
        return components!.url!
    }

    // MARK: - Types

    public struct Usage: Codable {
        public let bytes: Int
        public let maxBytes: Int
        public let percentage: Int

        public init(bytes: Int, maxBytes: Int, percentage: Int) {
            self.bytes = bytes
            self.maxBytes = maxBytes
            self.percentage = percentage
        }
    }
}
