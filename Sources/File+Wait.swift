// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

import Foundation

extension VOFile {
    public func wait(_ id: String, sleepSeconds: UInt32 = 1) async throws -> Entity {
        var file: Entity
        repeat {
            file = try await fetch(id)
            if let task = file.snapshot?.task, task.status != .waiting, task.status != .running {
                return file
            }
            sleep(sleepSeconds)
        } while file.snapshot!.task != nil
        return file
    }
}
