// Copyright (c) 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// You can find a copy of the license in the LICENSE file
// included in the root of this repository or at
// https://opensource.org/licenses/MIT.

import Foundation

public struct VOIdentityUser {
    let baseURL: String
    let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = URL(string: baseURL)!.appendingPathComponent("v3").absoluteString
        self.accessToken = accessToken
    }

    // MARK: - Requests

    public func fetch() async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForMe())
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

    public func delete(_: DeleteOptions) async throws {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: url())
            request.httpMethod = "DELETE"
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

    public func updateFullName(_ options: UpdateFullNameOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForPatchFullName())
            request.httpMethod = "POST"
            request.appendAuthorizationHeader(accessToken)
            request.setJSONBody(options, continuation: continuation)
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

    public func updateEmailRequest(_ options: UpdateEmailRequestOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForUpdateEmailRequest())
            request.httpMethod = "POST"
            request.appendAuthorizationHeader(accessToken)
            request.setJSONBody(options, continuation: continuation)
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

    public func updateEmailConfirmation(_ options: UpdateEmailConfirmationOptions) async throws
        -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForUpdateEmailConfirmation())
            request.httpMethod = "POST"
            request.appendAuthorizationHeader(accessToken)
            request.setJSONBody(options, continuation: continuation)
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

    public func updatePassword(_ options: UpdatePasswordOptions) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForUpdatePassword())
            request.httpMethod = "POST"
            request.appendAuthorizationHeader(accessToken)
            request.setJSONBody(options, continuation: continuation)
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

    public func updatePicture(data: Data, onProgress: ((Double) -> Void)? = nil) async throws
        -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForUpdatePicture())
            request.httpMethod = "POST"
            request.appendAuthorizationHeader(accessToken)

            let boundary = UUID().uuidString
            request.setValue(
                "multipart/form-data; boundary=\(boundary)",
                forHTTPHeaderField: "Content-Type"
            )

            var httpBody = Data()
            httpBody.append(Data("--\(boundary)\r\n".utf8))
            httpBody.append(
                Data("Content-Disposition: form-data; name=\"file\"; filename=\"file\"\r\n".utf8))
            httpBody.append(Data("Content-Type: application/octet-stream\r\n\r\n".utf8))

            httpBody.append(data)
            httpBody.append(Data("\r\n--\(boundary)--\r\n".utf8))

            let task = URLSession.shared.uploadTask(with: request, from: httpBody) {
                responseData, response, error in
                handleJSONResponse(
                    continuation: continuation,
                    response: response,
                    data: responseData,
                    error: error,
                    type: Entity.self
                )
            }
            task.resume()

            if let onProgress {
                let progressHandler = {
                    onProgress(task.progress.fractionCompleted * 100)
                }
                let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    progressHandler()
                    if task.progress.isFinished {
                        timer.invalidate()
                    }
                }
                RunLoop.main.add(timer, forMode: .default)
            }
        }
    }

    public func deletePicture() async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            var request = URLRequest(url: urlForDeletePicture())
            request.httpMethod = "POST"
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

    // MARK: - URLs

    public func url() -> URL {
        URL(string: "\(baseURL)/users")!
    }

    public func urlForMe() -> URL {
        URL(string: "\(url())/me")!
    }

    public func urlForPatchFullName() -> URL {
        URL(string: "\(urlForMe())/update_full_name")!
    }

    public func urlForUpdateEmailRequest() -> URL {
        URL(string: "\(urlForMe())/update_email_request")!
    }

    public func urlForUpdateEmailConfirmation() -> URL {
        URL(string: "\(urlForMe())/update_email_confirmation")!
    }

    public func urlForUpdatePassword() -> URL {
        URL(string: "\(urlForMe())/update_password")!
    }

    public func urlForUpdatePicture() -> URL {
        URL(string: "\(urlForMe())/update_picture")!
    }

    public func urlForDeletePicture() -> URL {
        URL(string: "\(urlForMe())/delete_picture")!
    }

    public func urlForPicture(_: String, fileExtension: String) -> URL {
        URL(string: "\(urlForMe())/picture\(fileExtension)?access_token=\(accessToken)")!
    }

    // MARK: - Payloads

    public struct UpdateFullNameOptions: Codable {
        public let fullName: String

        public init(fullName: String) {
            self.fullName = fullName
        }
    }

    public struct UpdateEmailRequestOptions: Codable {
        public let email: String

        public init(email: String) {
            self.email = email
        }
    }

    public struct UpdateEmailConfirmationOptions: Codable {
        public let token: String

        public init(token: String) {
            self.token = token
        }
    }

    public struct UpdatePasswordOptions: Codable {
        public let currentPassword: String
        public let newPassword: String

        public init(currentPassword: String, newPassword: String) {
            self.currentPassword = currentPassword
            self.newPassword = newPassword
        }
    }

    public struct DeleteOptions: Codable {
        public let password: String

        public init(password: String) {
            self.password = password
        }
    }

    // MARK: - Types

    public struct Entity: Codable, Equatable, Hashable {
        public let id: String
        public let username: String
        public let email: String
        public let fullName: String
        public let picture: Picture?
        public let pendingEmail: String?

        public init(
            id: String,
            username: String,
            email: String,
            fullName: String,
            picture: Picture? = nil,
            pendingEmail: String? = nil
        ) {
            self.id = id
            self.username = username
            self.email = email
            self.fullName = fullName
            self.picture = picture
            self.pendingEmail = pendingEmail
        }
    }

    public struct Picture: Codable, Equatable, Hashable {
        public let fileExtension: String

        public init(fileExtension: String) {
            self.fileExtension = fileExtension
        }

        enum CodingKeys: String, CodingKey {
            case fileExtension = "extension"
        }
    }
}
