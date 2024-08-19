// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve

extension FileTests {
    struct Clients {
        let organization: VOOrganization
        let workspace: VOWorkspace
        let file: VOFile
        let group: VOGroup
        let authUser: VOAuthUser

        init(_ token: VOToken.Value) async throws {
            let config = Config()
            organization = VOOrganization(baseURL: config.apiURL, accessToken: token.accessToken)
            workspace = VOWorkspace(baseURL: config.apiURL, accessToken: token.accessToken)
            file = VOFile(baseURL: config.apiURL, accessToken: token.accessToken)
            group = VOGroup(baseURL: config.apiURL, accessToken: token.accessToken)
            authUser = VOAuthUser(baseURL: config.idpURL, accessToken: token.accessToken)
        }
    }
}
