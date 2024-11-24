// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

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
