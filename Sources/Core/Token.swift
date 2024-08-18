// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct VOToken {
    let baseURL: String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - Requests

    public func exchange(options: ExchangeOptions) async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url(),
                method: .post,
                parameters: options.urlParameters,
                encoding: URLEncoding.default
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: Value.self)
            }
        }
    }

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/token")!
    }

    // MARK: - Payloads

    public struct ExchangeOptions {
        public let grantType: GrantType
        public let username: String?
        public let password: String?
        public let refreshToken: String?
        public let locale: String?

        public init(grantType: GrantType, username: String?, password: String?, refreshToken: String?, locale: String?) {
            self.grantType = grantType
            self.username = username
            self.password = password
            self.refreshToken = refreshToken
            self.locale = locale
        }

        var urlParameters: [String: String] {
            var params: [String: String] = ["grant_type": grantType.rawValue]
            if let username {
                params["username"] = username
            }
            if let password {
                params["password"] = password
            }
            if let refreshToken {
                params["refresh_token"] = refreshToken
            }
            if let locale {
                params["locale"] = locale
            }
            return params
        }
    }

    public enum GrantType: String {
        case password
        case refreshToken = "refresh_token"
    }

    // MARK: - Types

    public struct Value: Codable {
        public var accessToken: String
        public var expiresIn: Int
        public var tokenType: String
        public var refreshToken: String

        public init(accessToken: String, expiresIn: Int, tokenType: String, refreshToken: String) {
            self.accessToken = accessToken
            self.expiresIn = expiresIn
            self.tokenType = tokenType
            self.refreshToken = refreshToken
        }

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
            case tokenType = "token_type"
            case refreshToken = "refresh_token"
        }
    }
}
