// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

import VoltaserveCore

class TokenFactory {
    private let config = Config()
    private(set) var value: VOToken.Value

    var accessToken: String {
        value.accessToken
    }

    init(_ credentials: Config.Credentials) async throws {
        value = try await VOToken(baseURL: config.idpURL).exchange(
            .init(
                grantType: .password,
                username: credentials.username,
                password: credentials.password,
                refreshToken: nil,
                locale: nil
            ))
    }
}
