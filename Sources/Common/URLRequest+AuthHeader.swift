// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension URLRequest {
    mutating func appendAuthorizationHeader(_ accessToken: String) {
        setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
}
