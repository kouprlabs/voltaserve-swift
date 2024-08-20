// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve

extension SnapshotsTests {
    struct Clients {
        let organization: VOOrganization
        let workspace: VOWorkspace
        let file: VOFile
        let snapshot: VOSnapshot

        init(_ token: VOToken.Value) {
            let config = Config()
            organization = VOOrganization(baseURL: config.apiURL, accessToken: token.accessToken)
            workspace = VOWorkspace(baseURL: config.apiURL, accessToken: token.accessToken)
            file = VOFile(baseURL: config.apiURL, accessToken: token.accessToken)
            snapshot = VOSnapshot(baseURL: config.apiURL, accessToken: token.accessToken)
        }
    }
}
