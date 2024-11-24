// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the MIT License
// included in the file LICENSE in the root of this repository.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct VONoDataError: Error {}
public struct VOInvalidResponseError: Error {}

func handleJSONResponse<T: Decodable>(
    continuation: CheckedContinuation<T, any Error>,
    response: URLResponse?,
    data: Data?,
    error: (any Error)?,
    type _: T.Type
) {
    if let error {
        continuation.resume(throwing: error)
    } else {
        guard let data else {
            continuation.resume(throwing: VONoDataError())
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            continuation.resume(throwing: VONoDataError())
            return
        }
        let stringData = String(data: data, encoding: .utf8)
        if (200...299).contains(httpResponse.statusCode) {
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                continuation.resume(returning: result)
            } catch {
                if let stringData {
                    print("Failed to decode JSON: \(stringData), error: \(error.localizedDescription)")
                } else {
                    print("Failed to decode JSON with error: \(error.localizedDescription)")
                }
                continuation.resume(throwing: error)
            }
        } else {
            if let stringData {
                // swiftlint:disable:next line_length
                print(
                    "Request to URL: \(httpResponse.url!), failed with status code: \(httpResponse.statusCode), data: \(stringData)"
                )
            } else {
                print("Request to URL: \(httpResponse.url!), failed with status code: \(httpResponse.statusCode)")
            }
            handleErrorResponse(continuation: continuation, data: data)
        }
    }
}

func handleDataResponse(
    continuation: CheckedContinuation<Data, any Error>,
    response: URLResponse?,
    data: Data?,
    error: (any Error)?
) {
    if let error {
        continuation.resume(throwing: error)
    } else {
        guard let data else {
            continuation.resume(throwing: VONoDataError())
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            continuation.resume(throwing: VONoDataError())
            return
        }
        if (200...299).contains(httpResponse.statusCode) {
            continuation.resume(returning: data)
        } else {
            handleErrorResponse(continuation: continuation, data: data)
        }
    }
}

func handleEmptyResponse(
    continuation: CheckedContinuation<Void, any Error>,
    response: URLResponse?,
    data: Data?,
    error: (any Error)?
) {
    if let error {
        continuation.resume(throwing: error)
    } else {
        guard let data else {
            continuation.resume(throwing: VONoDataError())
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            continuation.resume(throwing: VONoDataError())
            return
        }
        if (200...299).contains(httpResponse.statusCode) {
            continuation.resume()
        } else {
            handleErrorResponse(continuation: continuation, data: data)
        }
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
