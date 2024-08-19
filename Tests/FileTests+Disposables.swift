// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve

extension FileTests {
    func createDisposableOrganization(_ client: VOOrganization) async throws -> VOOrganization.Entity {
        let organization = try await client.create(.init(name: "Test Organization"))
        disposableOrganizations.append(organization)
        return organization
    }

    func createDisposableWorkspace(_ client: VOWorkspace, organizationID: String) async throws -> VOWorkspace.Entity {
        let workspace = try await client.create(.init(
            name: "Test Workspace",
            organizationId: organizationID,
            storageCapacity: 100_000_000
        ))
        disposableWorkspaces.append(workspace)
        return workspace
    }

    func createDisposableGroup(_ client: VOGroup, organizationID: String) async throws -> VOGroup.Entity {
        let group = try await client.create(.init(
            name: "Test Group",
            organizationID: organizationID
        ))
        disposableGroups.append(group)
        return group
    }

    func createDisposableFile(_ client: VOFile, options: VOFile.CreateFileOptions) async throws -> VOFile.Entity {
        let file = try await client.createFile(options)
        disposableFiles.append(file)
        return file
    }

    func createDisposableFolder(_ client: VOFile, options: VOFile.CreateFolderOptions) async throws -> VOFile.Entity {
        let folder = try await client.createFolder(options)
        disposableFiles.append(folder)
        return folder
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
