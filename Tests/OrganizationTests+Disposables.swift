// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve

extension OrganizationTests {
    func createDisposableOrganization(
        _ client: VOOrganization,
        options: VOOrganization.CreateOptions
    ) async throws -> VOOrganization.Entity {
        let organization = try await client.create(options)
        disposableOrganizations.append(organization)
        return organization
    }

    func disposeOrganizations(_ client: VOOrganization) async throws {
        for disposable in disposableOrganizations {
            try? await client.delete(disposable.id)
        }
    }
}
