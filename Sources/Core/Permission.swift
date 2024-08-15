// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

enum Permission {
    enum Value: String, Codable {
        case viewer
        case editor
        case owner

        func weight() -> Int {
            switch self {
            case .viewer:
                1
            case .editor:
                2
            case .owner:
                3
            }
        }

        func gt(_ permission: Value) -> Bool {
            weight() > permission.weight()
        }

        func ge(_ permission: Value) -> Bool {
            weight() >= permission.weight()
        }

        func lt(_ permission: Value) -> Bool {
            weight() < permission.weight()
        }

        func le(_ permission: Value) -> Bool {
            weight() <= permission.weight()
        }

        func eq(_ permission: Value) -> Bool {
            weight() == permission.weight()
        }
    }
}
