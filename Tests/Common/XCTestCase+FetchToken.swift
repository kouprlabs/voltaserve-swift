// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve
import XCTest

extension XCTestCase {
    func fetchTokenOrFail() async throws -> VOToken.Value {
        if let value = try await fetchToken() {
            return value
        } else {
            throw FailedToFetchToken()
        }
    }

    func fetchOtherTokenOrFail() async throws -> VOToken.Value {
        if let value = try await fetchOtherToken() {
            return value
        } else {
            throw FailedToFetchToken()
        }
    }

    func fetchToken() async throws -> VOToken.Value? {
        let config = Config()
        return try await VOToken(baseURL: config.idpURL).exchange(VOToken.ExchangeOptions(
            grantType: .password,
            username: config.username,
            password: config.password,
            refreshToken: nil,
            locale: nil
        ))
    }

    func fetchOtherToken() async throws -> VOToken.Value? {
        let config = Config()
        return try await VOToken(baseURL: config.idpURL).exchange(VOToken.ExchangeOptions(
            grantType: .password,
            username: config.otherUsername,
            password: config.otherPassword,
            refreshToken: nil,
            locale: nil
        ))
    }

    struct FailedToFetchToken: Error {}
}
