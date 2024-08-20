// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve

struct Clients {
    let account: VOAccount

    init(_ token: VOToken.Value) {
        let config = Config()
        account = VOAccount(baseURL: config.idpURL, accessToken: token.accessToken)
    }
}
