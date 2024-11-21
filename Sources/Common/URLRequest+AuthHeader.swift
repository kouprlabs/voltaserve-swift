// Copyright (c) 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// You can find a copy of the license in the LICENSE file
// included in the root of this repository or at
// https://opensource.org/licenses/MIT.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension URLRequest {
    mutating func appendAuthorizationHeader(_ accessToken: String) {
        setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
}
