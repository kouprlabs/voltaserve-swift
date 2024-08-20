// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
@testable import Voltaserve
import XCTest

final class SnapshotsTests: XCTestCase {
    let config = Config()
    var disposableOrganizations: [VOOrganization.Entity] = []
    var disposableWorkspaces: [VOWorkspace.Entity] = []
    var disposableFiles: [VOFile.Entity] = []

    func testFetchList() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)
        let file = try await createDisposableFile(clients.file, options: .init(
            workspaceID: workspace.id,
            name: "Test File.txt",
            data: Data("Test Content".utf8)
        ))

        /* Create snapshots by patching the existing file */

        for index in 0 ..< 5 {
            _ = try await clients.file.patch(file.id, options: .init(data: Data("Another Test Content \(index)".utf8)))
        }

        /* Test we receive a snapshot list */

        for index in 1 ..< 3 {
            let page = try await clients.snapshot.fetchList(.init(fileID: file.id, page: index, size: 3))
            XCTAssertEqual(page.page, index)
            XCTAssertEqual(page.size, 3)
            XCTAssertEqual(page.totalElements, 6)
            XCTAssertEqual(page.totalPages, 2)
        }
    }

    func testTextFlow() async throws {
        try await checkDocumentFlow(forResource: "document", withExtension: "txt")
    }

    func testPDFFlow() async throws {
        try await checkDocumentFlow(forResource: "document", withExtension: "pdf")
    }

    func testOfficeFlow() async throws {
        try await checkDocumentFlow(forResource: "document", withExtension: "odt")
    }

    func testImageFlow() async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        let url = resourcesBundle.url(forResource: "image", withExtension: "jpg")!
        let data = try Data(contentsOf: url)
        var file = try await createDisposableFile(clients.file, options: .init(
            workspaceID: workspace.id,
            name: url.lastPathComponent,
            data: data
        ))

        /* Test original is valid */

        XCTAssertNotNil(file.snapshot)
        XCTAssertEqual(file.snapshot!.original.fileExtension, ".jpg")
        XCTAssertEqual(file.snapshot!.original.size, data.count)

        /* Test preview is valid */

        repeat {
            file = try await clients.file.fetch(file.id)
            sleep(1)
        } while file.snapshot!.task != nil

        XCTAssertNotNil(file.snapshot!.preview)
        XCTAssertNotNil(file.snapshot!.preview?.fileExtension, ".jpg")
        XCTAssertGreaterThan(file.snapshot!.preview!.size!, 0)
        XCTAssertNotNil(file.snapshot!.preview!.image)
        XCTAssertEqual(file.snapshot!.preview!.image!.width, 640)
        XCTAssertEqual(file.snapshot!.preview!.image!.height, 800)

        /* Test thumbnail is valid */

        XCTAssertNotNil(file.snapshot!.thumbnail)
        XCTAssertNotNil(file.snapshot!.thumbnail!.image)
        XCTAssertGreaterThan(file.snapshot!.thumbnail!.size!, 0)
        XCTAssertEqual(file.snapshot!.thumbnail!.fileExtension, ".jpg")
        XCTAssertTrue(
            file.snapshot!.thumbnail!.image!.width == 512 ||
                file.snapshot!.thumbnail!.image!.height == 512)
    }

    func checkDocumentFlow(forResource resource: String, withExtension fileExtension: String) async throws {
        let clients = try await Clients(fetchTokenOrFail())

        let organization = try await createDisposableOrganization(clients.organization)
        let workspace = try await createDisposableWorkspace(clients.workspace, organizationID: organization.id)

        let url = resourcesBundle.url(forResource: resource, withExtension: fileExtension)!
        let data = try Data(contentsOf: url)
        var file = try await createDisposableFile(clients.file, options: .init(
            workspaceID: workspace.id,
            name: url.lastPathComponent,
            data: data
        ))

        /* Test original is valid */

        XCTAssertNotNil(file.snapshot)
        XCTAssertEqual(file.snapshot!.original.fileExtension, ".\(fileExtension)")
        XCTAssertEqual(file.snapshot!.original.size, data.count)

        /* Test preview is valid */

        repeat {
            file = try await clients.file.fetch(file.id)
            sleep(1)
        } while file.snapshot!.task != nil

        XCTAssertNotNil(file.snapshot!.preview)
        XCTAssertNotNil(file.snapshot!.preview?.fileExtension, ".pdf")
        XCTAssertGreaterThan(file.snapshot!.preview!.size!, 0)
        XCTAssertNotNil(file.snapshot!.preview!.document)
        XCTAssertNotNil(file.snapshot!.preview!.document!.pages)
        XCTAssertEqual(file.snapshot!.preview!.document!.pages!.count, 1)
        XCTAssertEqual(
            file.snapshot!.preview!.document!.pages!.fileExtension,
            file.snapshot!.preview!.fileExtension
        )

        /* Test thumbnail is valid */

        XCTAssertNotNil(file.snapshot!.thumbnail)
        XCTAssertNotNil(file.snapshot!.thumbnail!.image)
        XCTAssertGreaterThan(file.snapshot!.thumbnail!.size!, 0)
        XCTAssertEqual(file.snapshot!.thumbnail!.fileExtension, ".png")
        XCTAssertTrue(
            file.snapshot!.thumbnail!.image!.width == 512 ||
                file.snapshot!.thumbnail!.image!.height == 512)
    }
}
