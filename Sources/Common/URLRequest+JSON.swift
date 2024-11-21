// Copyright (c) 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// See the LICENSE file in the root of this repository for details,
// or visit <https://opensource.org/licenses/MIT>.

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
