// Copyright 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// You can find a copy of the license in the LICENSE file
// included in the root of this repository or at
// https://opensource.org/licenses/MIT.

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
