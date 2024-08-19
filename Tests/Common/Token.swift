// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
import Voltaserve

struct Token {
    private(set) var value: VOToken.Value?
    let config = Config()

    mutating func fetch() async throws -> VOToken.Value? {
        if let value {
            return value
        } else {
            value = try await VOToken(baseURL: config.idpURL).exchange(VOToken.ExchangeOptions(
                grantType: .password,
                username: config.username,
                password: config.password,
                refreshToken: nil,
                locale: nil
            ))
            return value
        }
    }
}
