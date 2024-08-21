// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Voltaserve

class ClientFactory {
    private let config = Config()
    private let token: TokenFactory
    private var _organization: VOOrganization?
    private var _workspace: VOWorkspace?
    private var _file: VOFile?
    private var _snapshot: VOSnapshot?
    private var _task: VOTask?
    private var _group: VOGroup?
    private var _invitation: VOInvitation?
    private var _storage: VOStorage?
    private var _user: VOUser?
    private var _authUser: VOAuthUser?
    private var _account: VOAccount?

    init(_ token: TokenFactory) async throws {
        self.token = token
    }

    var organization: VOOrganization {
        if _organization == nil {
            _organization = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _organization!
    }

    var workspace: VOWorkspace {
        if _workspace == nil {
            _workspace = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _workspace!
    }

    var file: VOFile {
        if _file == nil {
            _file = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _file!
    }

    var snapshot: VOSnapshot {
        if _snapshot == nil {
            _snapshot = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _snapshot!
    }

    var task: VOTask {
        if _task == nil {
            _task = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _task!
    }

    var group: VOGroup {
        if _group == nil {
            _group = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _group!
    }

    var invitation: VOInvitation {
        if _invitation == nil {
            _invitation = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _invitation!
    }

    var storage: VOStorage {
        if _storage == nil {
            _storage = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _storage!
    }

    var user: VOUser {
        if _user == nil {
            _user = .init(
                baseURL: config.apiURL,
                accessToken: token.accessToken
            )
        }
        return _user!
    }

    var authUser: VOAuthUser {
        if _authUser == nil {
            _authUser = .init(
                baseURL: config.idpURL,
                accessToken: token.accessToken
            )
        }
        return _authUser!
    }

    var account: VOAccount {
        if _account == nil {
            _account = .init(
                baseURL: config.idpURL,
                accessToken: token.accessToken
            )
        }
        return _account!
    }
}
