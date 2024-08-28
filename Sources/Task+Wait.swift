// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

public extension VOTask {
    func wait(_ id: String, sleepSeconds: UInt32 = 1) async throws -> Entity? {
        var task: Entity?
        repeat {
            do {
                task = try await fetch(id)
                if task?.status == .error {
                    if let error = task?.error {
                        throw RuntimeError.message(error)
                    } else {
                        throw RuntimeError.message("Unknown error")
                    }
                }
            } catch let error as VOErrorResponse {
                if error.code == "task_not_found" {
                    return nil
                } else {
                    throw error
                }
            }
            sleep(sleepSeconds)
        } while task?.status == .waiting || task?.status == .running
        return task
    }

    enum RuntimeError: Error {
        case message(String)
    }
}
