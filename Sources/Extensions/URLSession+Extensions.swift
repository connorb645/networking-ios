//
//  URLSession+Extensions.swift
//  Networking
//
//  Created by Connor Black on 04/07/2024.
//

import Foundation

public enum URLSessionError: Error {
    case failedHTTPResponseCast
}

extension URLSession {
    func dataAndHttpResponse(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await self.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLSessionError.failedHTTPResponseCast
        }
        return (data, httpResponse)
    }
}
