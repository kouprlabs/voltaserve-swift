// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import VoltaserveCore

class TokenFactory {
    private let config = Config()
    private(set) var value: VOToken.Value

    var accessToken: String {
        value.accessToken
    }

    init(_ credentials: Config.Credentials) async throws {
        value = try await VOToken(baseURL: config.idpURL).exchange(.init(
            grantType: .password,
            username: credentials.username,
            password: credentials.password,
            refreshToken: nil,
            locale: nil
        ))
    }
}
