// Copyright 2024 Anass Bouassaba.
//
// This software is licensed under the MIT License.
// You can find a copy of the license in the LICENSE file
// included in the root of this repository or at
// https://opensource.org/licenses/MIT.

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
