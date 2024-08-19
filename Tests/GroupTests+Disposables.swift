// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve

extension GroupTests {
    func createDisposableOrganization(_ client: VOOrganization) async throws -> VOOrganization.Entity {
        let organization = try await client.create(.init(name: "Test Organization"))
        disposableOrganizations.append(organization)
        return organization
    }

    func createDisposableGroup(_ client: VOGroup, options: VOGroup.CreateOptions) async throws -> VOGroup.Entity {
        let group = try await client.create(options)
        disposableGroups.append(group)
        return group
    }

    func disposeOrganizations(_ client: VOOrganization) async throws {
        for disposable in disposableOrganizations {
            try? await client.delete(disposable.id)
        }
    }

    func disposeGroups(_ client: VOGroup) async throws {
        for disposable in disposableGroups {
            try? await client.delete(disposable.id)
        }
    }
}
