// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve

extension FileTests {
    override func tearDown() async throws {
        let token = try await fetchTokenOrFail()
        let clients = try await Clients(token)

        try await disposeFiles(clients.file)
        try await disposeWorkspaces(clients.workspace)
        try await disposeOrganizations(clients.organization)
    }

    func disposeOrganizations(_ client: VOOrganization) async throws {
        for disposable in disposableOrganizations {
            try? await client.delete(disposable.id)
        }
    }

    func disposeWorkspaces(_ client: VOWorkspace) async throws {
        for disposable in disposableWorkspaces {
            try? await client.delete(disposable.id)
        }
    }

    func disposeFiles(_ client: VOFile) async throws {
        for disposable in disposableFiles {
            try? await client.delete(disposable.id)
        }
    }
}
