// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

@testable import Voltaserve
import XCTest

final class StorageTests: XCTestCase {
    var factory: DisposableFactory?

    override func tearDown() async throws {
        try await super.tearDown()
        await factory?.dispose()
    }
}
