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

    struct Clients {
        let organization: VOOrganization

        init(_ token: VOToken.Value) async throws {
            let config = Config()
            organization = VOOrganization(baseURL: config.apiURL, accessToken: token.accessToken)
        }
    }
}
