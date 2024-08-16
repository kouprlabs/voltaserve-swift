// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Alamofire
import Foundation

func handleJSONResponse<T: Decodable>(
    continuation: CheckedContinuation<T, any Error>,
    response: AFDataResponse<Data>, type _: T.Type
) {
    switch response.result {
    case let .success(data):
        if let statusCode = response.response?.statusCode, (200 ... 299).contains(statusCode) {
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        } else {
            handleErrorResponse(continuation: continuation, data: data)
        }
    case let .failure(error):
        continuation.resume(throwing: error)
    }
}

func handleDataResponse(continuation: CheckedContinuation<Data, any Error>, response: AFDataResponse<Data>) {
    switch response.result {
    case let .success(data):
        if let statusCode = response.response?.statusCode, (200 ... 299).contains(statusCode) {
            continuation.resume(returning: data)
        } else {
            handleErrorResponse(continuation: continuation, data: data)
        }
    case let .failure(error):
        continuation.resume(throwing: error)
    }
}

func handleEmptyResponse(continuation: CheckedContinuation<Void, any Error>, response: AFDataResponse<Data>) {
    switch response.result {
    case .success:
        if let statusCode = response.response?.statusCode, (200 ... 299).contains(statusCode) {
            continuation.resume()
        } else {
            handleErrorResponse(continuation: continuation, data: response.data!)
        }
    case let .failure(error):
        continuation.resume(throwing: error)
    }
}

func handleErrorResponse(continuation: CheckedContinuation<some Any, any Error>, data: Data) {
    do {
        let result = try JSONDecoder().decode(VOErrorResponse.self, from: data)
        continuation.resume(throwing: result)
    } catch {
        continuation.resume(throwing: error)
    }
}
