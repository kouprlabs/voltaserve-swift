// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct VOStorage {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = URL(string: baseURL)!.appendingPathComponent("v3").absoluteString
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetchAccountUsage() async throws -> Usage {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForAccountUsage())
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: Usage.self
                )
            }
            task.resume()
        }
    }

    public func fetchWorkspaceUsage(_ id: String) async throws -> Usage {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForWokrspaceUsage(id))
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: Usage.self
                )
            }
            task.resume()
        }
    }

    public func fetchFileUsage(_ id: String) async throws -> Usage {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForFileUsage(id))
            request.httpMethod = "GET"
            request.appendAuthorizationHeader(accessToken)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: Usage.self
                )
            }
            task.resume()
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

    public struct Usage: Codable, Equatable, Hashable {
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
