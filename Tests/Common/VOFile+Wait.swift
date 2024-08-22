// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
import Voltaserve

extension VOFile {
    func wait(_ id: String) async throws -> VOFile.Entity {
        var file: VOFile.Entity
        repeat {
            file = try await fetch(id)
            if file.snapshot!.status == .error {
                return file
            }
            sleep(1)
        } while file.snapshot!.task != nil
        return file
    }
}
