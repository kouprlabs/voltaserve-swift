// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

func headersWithAuthorization(_ accessToken: String) -> HTTPHeaders {
    ["Authorization": "Bearer \(accessToken)"]
}
