// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve

extension WorkspaceTests {
    override func tearDown() async throws {
        let token = try await fetchTokenOrFail()
        let clients = try await Clients(token)

        try await disposeWorkspaces(clients.workspace)
        try await disposeOrganizations(clients.organization)
    }
}
