// Copyright (c) 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// You can find a copy of the license in the LICENSE file
// included in the root of this repository or at
// https://opensource.org/licenses/MIT.

import VoltaserveCore

class DisposableFactory {
    let client: ClientFactory
    private var organizations: [VOOrganization.Entity] = []
    private var groups: [VOGroup.Entity] = []
    private var workspaces: [VOWorkspace.Entity] = []
    private var files: [VOFile.Entity] = []

    static func withCredentials() async throws -> DisposableFactory {
        try await DisposableFactory(.init(.init(Config().credentials)))
    }

    static func withOtherCredentials() async throws -> DisposableFactory {
        try await DisposableFactory(.init(.init(Config().otherCredentials)))
    }

    init(_ client: ClientFactory) {
        self.client = client
    }

    func organization(_ options: VOOrganization.CreateOptions) async throws -> VOOrganization.Entity {
        let organization = try await client.organization.create(options)
        organizations.append(organization)
        return organization
    }

    func workspace(_ options: VOWorkspace.CreateOptions) async throws -> VOWorkspace.Entity {
        let workspace = try await client.workspace.create(options)
        workspaces.append(workspace)
        return workspace
    }

    func group(_ options: VOGroup.CreateOptions) async throws -> VOGroup.Entity {
        let group = try await client.group.create(options)
        groups.append(group)
        return group
    }

    func file(_ options: VOFile.CreateFileOptions) async throws -> VOFile.Entity {
        let file = try await client.file.createFile(options)
        files.append(file)
        return file
    }

    func folder(_ options: VOFile.CreateFolderOptions) async throws -> VOFile.Entity {
        let folder = try await client.file.createFolder(options)
        files.append(folder)
        return folder
    }

    func dispose() async {
        for disposable in files {
            try? await client.file.delete(disposable.id)
        }
        for disposable in workspaces {
            try? await client.workspace.delete(disposable.id)
        }
        for disposable in groups {
            try? await client.group.delete(disposable.id)
        }
        for disposable in organizations {
            try? await client.organization.delete(disposable.id)
        }
    }
}
