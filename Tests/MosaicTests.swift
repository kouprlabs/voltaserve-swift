// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

@testable import VoltaserveCore
import XCTest

final class MosaicTests: XCTestCase {
    var factory: DisposableFactory?

    func testCreateForJPEG() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.mosaic

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))
        let file = try await factory.file(.init(
            workspaceID: workspace.id,
            name: "image.jpg",
            data: Data(contentsOf: getResourceURL(forResource: "image", withExtension: "jpg")!)
        ))
        _ = try await factory.client.file.wait(file.id)

        let task = try await client.create(file.id)
        _ = try await factory.client.task.wait(task.id)

        let info = try await client.fetchInfo(file.id)
        checkMetadata(info, fileExtension: ".jpg")
    }

    func testCreateForPNG() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.mosaic

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))
        let file = try await factory.file(.init(
            workspaceID: workspace.id,
            name: "image.png",
            data: Data(contentsOf: getResourceURL(forResource: "image", withExtension: "png")!)
        ))
        _ = try await factory.client.file.wait(file.id)

        let task = try await client.create(file.id)
        _ = try await factory.client.task.wait(task.id)

        let info = try await client.fetchInfo(file.id)
        checkMetadata(info, fileExtension: ".png")
    }

    func testCreateForTIFF() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.mosaic

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))
        let file = try await factory.file(.init(
            workspaceID: workspace.id,
            name: "image.tiff",
            data: Data(contentsOf: getResourceURL(forResource: "image", withExtension: "tiff")!)
        ))
        _ = try await factory.client.file.wait(file.id)

        let task = try await client.create(file.id)
        _ = try await factory.client.task.wait(task.id)

        let info = try await client.fetchInfo(file.id)
        checkMetadata(info, fileExtension: ".jpg")
    }

    func testCreateForWebP() async throws {
        guard let factory = try? await DisposableFactory.withCredentials() else {
            failedToCreateFactory()
            return
        }
        self.factory = factory
        let client = factory.client.mosaic

        let organization = try await factory.organization(.init(name: "Test Organization"))
        let workspace = try await factory.workspace(.init(
            name: "Test Workspace",
            organizationID: organization.id,
            storageCapacity: 100_000_000
        ))
        let file = try await factory.file(.init(
            workspaceID: workspace.id,
            name: "image.webp",
            data: Data(contentsOf: getResourceURL(forResource: "image", withExtension: "webp")!)
        ))
        _ = try await factory.client.file.wait(file.id)

        let task = try await client.create(file.id)
        _ = try await factory.client.task.wait(task.id)

        let info = try await client.fetchInfo(file.id)
        checkMetadata(info, fileExtension: ".jpg")
    }

    func checkMetadata(_ info: VOMosaic.Info, fileExtension: String) {
        XCTAssertEqual(info.metadata.fileExtension, fileExtension)
        XCTAssertEqual(info.metadata.width, 1920)
        XCTAssertEqual(info.metadata.height, 1192)
        XCTAssertEqual(info.metadata.zoomLevels.count, 3)

        let zoomLevel0 = info.metadata.zoomLevels[0]
        XCTAssertEqual(zoomLevel0.index, 0)
        XCTAssertEqual(zoomLevel0.width, 1920)
        XCTAssertEqual(zoomLevel0.height, 1192)
        XCTAssertEqual(zoomLevel0.rows, 4)
        XCTAssertEqual(zoomLevel0.cols, 7)
        XCTAssertEqual(zoomLevel0.scaleDownPercentage, 100)
        XCTAssertEqual(zoomLevel0.tile.width, 300)
        XCTAssertEqual(zoomLevel0.tile.height, 300)
        XCTAssertEqual(zoomLevel0.tile.lastColWidth, 120)
        XCTAssertEqual(zoomLevel0.tile.lastRowHeight, 292)

        let zoomLevel1 = info.metadata.zoomLevels[1]
        XCTAssertEqual(zoomLevel1.index, 1)
        XCTAssertEqual(zoomLevel1.width, 1344)
        XCTAssertEqual(zoomLevel1.height, 834)
        XCTAssertEqual(zoomLevel1.rows, 3)
        XCTAssertEqual(zoomLevel1.cols, 5)
        XCTAssertEqual(zoomLevel1.scaleDownPercentage, 70)
        XCTAssertEqual(zoomLevel1.tile.width, 300)
        XCTAssertEqual(zoomLevel1.tile.height, 300)
        XCTAssertEqual(zoomLevel1.tile.lastColWidth, 144)
        XCTAssertEqual(zoomLevel1.tile.lastRowHeight, 234)

        let zoomLevel2 = info.metadata.zoomLevels[2]
        XCTAssertEqual(zoomLevel2.index, 2)
        XCTAssertEqual(zoomLevel2.width, 940)
        XCTAssertEqual(zoomLevel2.height, 583)
        XCTAssertEqual(zoomLevel2.rows, 2)
        XCTAssertEqual(zoomLevel2.cols, 4)
        XCTAssertEqual(zoomLevel2.scaleDownPercentage, 49)
        XCTAssertEqual(zoomLevel2.tile.width, 300)
        XCTAssertEqual(zoomLevel2.tile.height, 300)
        XCTAssertEqual(zoomLevel2.tile.lastColWidth, 40)
        XCTAssertEqual(zoomLevel2.tile.lastRowHeight, 283)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }
}
