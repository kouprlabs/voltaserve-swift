// Copyright 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// You can find a copy of the license in the LICENSE file
// included in the root of this repository or at
// https://opensource.org/licenses/MIT.

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
                if error.code == .taskNotFound {
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
