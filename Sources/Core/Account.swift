// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

public struct VOAccount {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetchPasswordRequirements() async throws -> PasswordRequirements {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(urlForPasswordRequirements()).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: PasswordRequirements.self)
            }
        }
    }

    public func create(_ options: CreateOptions) async throws -> VOAuthUser.Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleJSONResponse(continuation: continuation, response: response, type: VOAuthUser.Entity.self)
            }
        }
    }

    public func sendResetPasswordEmail(_ options: SendResetPasswordEmailOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForSendPasswordEmail(),
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func resetPassword(_ options: ResetPasswordOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForResetPassword(),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default,
                headers: headersWithAuthorization(accessToken)
            ).responseData { response in
                handleEmptyResponse(continuation: continuation, response: response)
            }
        }
    }

    public func confirmEmail(_ options: ConfirmEmailOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForConfirmEmail(),
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
        URL(string: "\(baseURL)/accounts")!
    }

    public func urlForSendPasswordEmail() -> URL {
        URL(string: "\(baseURL)/accounts/send_reset_password_email")!
    }

    public func urlForResetPassword() -> URL {
        URL(string: "\(baseURL)/accounts/reset_password")!
    }

    public func urlForConfirmEmail() -> URL {
        URL(string: "\(baseURL)/accounts/confirm_email")!
    }

    public func urlForPasswordRequirements() -> URL {
        URL(string: "\(baseURL)/accounts/password_requirements")!
    }

    // MARK: - Payloads

    public struct CreateOptions: Codable {
        public let email: String
        public let password: String
        public let fullName: String
        public let picture: String?
    }

    public struct SendResetPasswordEmailOptions: Codable {
        public let email: String
    }

    public struct ResetPasswordOptions: Codable {
        public let token: String
        public let newPassword: String
    }

    public struct ConfirmEmailOptions: Codable {
        public let token: String
    }

    public struct PasswordRequirements: Codable {
        public let minLength: Int
        public let minLowercase: Int
        public let minUppercase: Int
        public let minNumbers: Int
        public let minSymbols: Int
    }
}
