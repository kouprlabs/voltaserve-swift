// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

struct ErrorResponse: Decodable, Error {
    let code: String
    let status: Int
    let message: String
    let userMessage: String
    let moreInfo: String
}
