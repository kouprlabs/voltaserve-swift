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

    struct Clients {
        let organization: VOOrganization
        let group: VOGroup

        init(_ token: VOToken.Value) async throws {
            let config = Config()
            organization = VOOrganization(baseURL: config.apiURL, accessToken: token.accessToken)
            group = VOGroup(baseURL: config.apiURL, accessToken: token.accessToken)
        }
    }
}
