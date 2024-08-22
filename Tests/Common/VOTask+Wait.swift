// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
import Voltaserve

extension VOTask {
    func wait(_ id: String) async throws {
        var entity: VOTask.Entity
        repeat {
            do {
                entity = try await fetch(id)
            } catch let error as VOErrorResponse {
                if error.code == "task_not_found" {
                    return
                } else {
                    throw error
                }
            }
            sleep(1)
        } while entity.status == .waiting || entity.status == .running
    }
}
