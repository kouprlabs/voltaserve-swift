// Copyright (c) 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// You can find a copy of the license in the LICENSE file
// included in the root of this repository or at
// https://opensource.org/licenses/MIT.

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
