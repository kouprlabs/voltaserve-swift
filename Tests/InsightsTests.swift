// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

import XCTest

@testable import VoltaserveCore

final class InsightsTests: XCTestCase {
    var factory: DisposableFactory?

    func testFetchInfo() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.insights

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))

        let file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File.txt",
                data: Data(Constants.text.utf8)
            ))
        _ = try await factory.client.file.wait(file.id)

        let task = try await client.create(file.id, options: .init(languageID: "eng"))
        _ = try await factory.client.task.wait(task.id)

        let info = try await client.fetchInfo(file.id)
        XCTAssertTrue(info.isAvailable)
        XCTAssertFalse(info.isOutdated)
    }

    func testEntityList() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.insights

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))

        let file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File.txt",
                data: Data(Constants.text.utf8)
            ))
        _ = try await factory.client.file.wait(file.id)

        let task = try await client.create(file.id, options: .init(languageID: "eng"))
        _ = try await factory.client.task.wait(task.id)

        let entityList = try await client.fetchEntityList(file.id, options: .init(size: 3))
        XCTAssertEqual(entityList.page, 1)
        XCTAssertLessThanOrEqual(entityList.size, 3)
        XCTAssertFalse(entityList.data.isEmpty)
        XCTAssertGreaterThanOrEqual(entityList.totalElements, 0)
    }

    func testFetchLanguages() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.insights

        let languages = try await client.fetchLanguages()
        XCTAssertFalse(languages.isEmpty)
    }

    func testPatch() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.insights

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))

        let file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File.txt",
                data: Data(Constants.text.utf8)
            ))
        _ = try await factory.client.file.wait(file.id)

        var task = try await client.create(file.id, options: .init(languageID: "eng"))
        _ = try await factory.client.task.wait(task.id)

        var info = try await client.fetchInfo(file.id)
        XCTAssertFalse(info.isOutdated)

        // Patch file to get a new snapshot and make the insights "outdated"
        _ = try await factory.client.file.patch(
            file.id,
            options: .init(data: Data(Constants.text.utf8), name: file.name)
        )
        _ = try await factory.client.file.wait(file.id)

        info = try await client.fetchInfo(file.id)
        XCTAssertTrue(info.isOutdated)

        // Patch insights
        task = try await client.patch(file.id)
        _ = try await factory.client.task.wait(task.id)

        // Check if no longer "outdated"
        info = try await client.fetchInfo(file.id)
        XCTAssertFalse(info.isOutdated)
    }

    func testDelete() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.insights

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(
            .init(
                name: "Test Workspace",
                organizationID: organization.id,
                storageCapacity: 100_000_000
            ))
        let file = try await factory.file(
            .init(
                workspaceID: workspace.id,
                name: "Test File.txt",
                data: Data(Constants.text.utf8)
            ))
        _ = try await factory.client.file.wait(file.id)

        var task = try await client.create(file.id, options: .init(languageID: "eng"))
        _ = try await factory.client.task.wait(task.id)

        var info = try await client.fetchInfo(file.id)
        XCTAssertTrue(info.isAvailable)

        task = try await client.delete(file.id)
        _ = try await factory.client.task.wait(task.id)

        info = try await client.fetchInfo(file.id)
        XCTAssertFalse(info.isAvailable)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }

    enum Constants {
        // swiftlint:disable line_length
        static let text = """
            William Shakespeare was an English playwright, poet and actor. He is widely regarded as the greatest writer in the English language and the world's pre-eminent dramatist. He is often called England's national poet and the "Bard of Avon" (or simply "the Bard"). His extant works, including collaborations, consist of some 39 plays, 154 sonnets, three long narrative poems and a few other verses, some of uncertain authorship. His plays have been translated into every major living language and are performed more often than those of any other playwright. Shakespeare remains arguably the most influential writer in the English language, and his works continue to be studied and reinterpreted.
            """
        // swiftlint:enable line_length
    }
}
