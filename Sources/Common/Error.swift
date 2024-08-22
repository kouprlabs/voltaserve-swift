// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

public struct VOErrorResponse: Decodable, Error {
    public let code: String
    public let status: Int
    public let message: String
    public let userMessage: String
    public let moreInfo: String
}
