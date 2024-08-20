// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension URLRequest {
    mutating func setJSONBody(_ body: Encodable, continuation: CheckedContinuation<some Any, any Error>) {
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            httpBody = try JSONEncoder().encode(body)
        } catch {
            continuation.resume(throwing: error)
        }
    }
}
