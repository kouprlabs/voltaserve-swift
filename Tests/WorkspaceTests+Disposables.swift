// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve

extension WorkspaceTests {
    func createDisposableOrganization(_ client: VOOrganization) async throws -> VOOrganization.Entity {
        let organization = try await client.create(.init(name: "Test Organization"))
        disposableOrganizations.append(organization)
        return organization
    }

    func createDisposableWorkspace(
        _ client: VOWorkspace,
        options: VOWorkspace.CreateOptions
    ) async throws -> VOWorkspace.Entity {
        let workspace = try await client.create(options)
        disposableWorkspaces.append(workspace)
        return workspace
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
}