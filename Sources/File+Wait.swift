// Copyright (c) 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// See the LICENSE file in the root of this repository for details,
// or visit <https://opensource.org/licenses/MIT>.

import Foundation

public extension VOFile {
    func wait(_ id: String, sleepSeconds: UInt32 = 1) async throws -> Entity {
        var file: Entity
        repeat {
            file = try await fetch(id)
            if file.snapshot!.status == .error {
                return file
            }
            sleep(sleepSeconds)
        } while file.snapshot!.task != nil
        return file
    }
}
