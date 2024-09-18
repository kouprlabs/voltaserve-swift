// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct VOAccount {
    let baseURL: String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - Requests

    public func fetchPasswordRequirements() async throws -> PasswordRequirements {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForPasswordRequirements())
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: PasswordRequirements.self
                )
            }
            task.resume()
        }
    }

    public func create(_ options: CreateOptions) async throws -> VOIdentityUser.Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: url())
            request.httpMethod = "POST"
            request.setJSONBody(options, continuation: continuation)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: data,
                    error: error,
                    type: VOIdentityUser.Entity.self
                )
            }
            task.resume()
        }
    }

    public func sendResetPasswordEmail(_ options: SendResetPasswordEmailOptions) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            var request = URLRequest(url: urlForSendPasswordEmail())
            request.httpMethod = "POST"
            request.setJSONBody(options, continuation: continuation)
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

    public func resetPassword(_ options: ResetPasswordOptions) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            var request = URLRequest(url: urlForResetPassword())
            request.httpMethod = "POST"
            request.setJSONBody(options, continuation: continuation)
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

    public func confirmEmail(_ options: ConfirmEmailOptions) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            var request = URLRequest(url: urlForConfirmEmail())
            request.httpMethod = "POST"
            request.setJSONBody(options, continuation: continuation)
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
        URL(string: "\(baseURL)/accounts")!
    }

    public func urlForSendPasswordEmail() -> URL {
        URL(string: "\(url())/send_reset_password_email")!
    }

    public func urlForResetPassword() -> URL {
        URL(string: "\(url())/reset_password")!
    }

    public func urlForConfirmEmail() -> URL {
        URL(string: "\(url())/confirm_email")!
    }

    public func urlForPasswordRequirements() -> URL {
        URL(string: "\(url())/password_requirements")!
    }

    // MARK: - Payloads

    public struct CreateOptions: Codable {
        public let email: String
        public let password: String
        public let fullName: String
        public let picture: String?

        public init(email: String, password: String, fullName: String, picture: String? = nil) {
            self.email = email
            self.password = password
            self.fullName = fullName
            self.picture = picture
        }
    }

    public struct SendResetPasswordEmailOptions: Codable {
        public let email: String

        public init(email: String) {
            self.email = email
        }
    }

    public struct ResetPasswordOptions: Codable {
        public let token: String
        public let newPassword: String

        public init(token: String, newPassword: String) {
            self.token = token
            self.newPassword = newPassword
        }
    }

    public struct ConfirmEmailOptions: Codable {
        public let token: String

        public init(token: String) {
            self.token = token
        }
    }

    public struct PasswordRequirements: Codable {
        public let minLength: Int
        public let minLowercase: Int
        public let minUppercase: Int
        public let minNumbers: Int
        public let minSymbols: Int

        public init(minLength: Int, minLowercase: Int, minUppercase: Int, minNumbers: Int, minSymbols: Int) {
            self.minLength = minLength
            self.minLowercase = minLowercase
            self.minUppercase = minUppercase
            self.minNumbers = minNumbers
            self.minSymbols = minSymbols
        }
    }
}
