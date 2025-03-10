// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public enum VOPermission {
    public enum Value: String, Codable {
        case none
        case viewer
        case editor
        case owner

        public func weight() -> Int {
            switch self {
            case .none:
                0
            case .viewer:
                1
            case .editor:
                2
            case .owner:
                3
            }
        }

        public func gt(_ permission: Value) -> Bool {
            weight() > permission.weight()
        }

        public func ge(_ permission: Value) -> Bool {
            weight() >= permission.weight()
        }

        public func lt(_ permission: Value) -> Bool {
            weight() < permission.weight()
        }

        public func le(_ permission: Value) -> Bool {
            weight() <= permission.weight()
        }

        public func eq(_ permission: Value) -> Bool {
            weight() == permission.weight()
        }
    }
}
