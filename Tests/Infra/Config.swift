// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
import VoltaserveCore

struct Config {
    let apiURL = "http://\(ProcessInfo.processInfo.environment["API_HOST"] ?? "localhost"):8080"
    let idpURL = "http://\(ProcessInfo.processInfo.environment["IDP_HOST"] ?? "localhost"):8081"
    let username = ProcessInfo.processInfo.environment["USERNAME"] ?? "test@koupr.com"
    let password = ProcessInfo.processInfo.environment["PASSWORD"] ?? "Passw0rd!"
    let otherUsername = ProcessInfo.processInfo.environment["OTHER_USERNAME"] ?? "test+1@koupr.com"
    let otherPassword = ProcessInfo.processInfo.environment["OTHER_PASSWORD"] ?? "Passw0rd!"

    var credentials: Credentials {
        .init(username: username, password: password)
    }

    var otherCredentials: Credentials {
        .init(username: otherUsername, password: otherPassword)
    }

    struct Credentials {
        let username: String
        let password: String
    }
}
