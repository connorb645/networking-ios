//
//  NetworkClient.swift
//  Networking
//
//  Created by Connor Black on 04/07/2024.
//

import Foundation
import Dependencies
import Logging

public enum NetworkClientError: Error {
    case invalidUrl
    case badResponse(Int, String)
    case badResponse(Int)
}

struct ResponseDetails {
    let httpResponse: HTTPURLResponse
    let data: Data
}

extension ResponseDetails {
    func checkOKStatus() throws {
        guard (200...299) ~= self.httpResponse.statusCode else {
            struct ErrorResponseContract: Decodable {
                let code: Int
                let message: String
            }
            do {
                let errorBody = try JSONDecoder().decode(ErrorResponseContract.self, from: self.data)
                throw NetworkClientError.badResponse(errorBody.code, errorBody.message)
            } catch {
                throw NetworkClientError.badResponse(self.httpResponse.statusCode)
            }
        }
    }
}

public struct NetworkClient: Sendable {
    @Dependency(\.jsonDecoder) var jsonDecoder
    @Dependency(\.jsonEncoder) var jsonEncoder

    let urlSession: LoggerURLSessionProtocol

    init() {
        urlSession = URLSessionProvider.session
    }

    public func GET<T: Decodable>(
        url: String,
        headers: [String: String]? = nil,
        queryParameters: [String: String]? = nil
    ) async throws -> T {
        guard let url = URL(string: url).withQueryParameters(queryParameters) else { throw NetworkClientError.invalidUrl }
        let urlRequest = URLRequest(url: url).withHeaders(headers)
        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLSessionError.failedHTTPResponseCast
        }
        try ResponseDetails(httpResponse: httpResponse, data: data).checkOKStatus()
        return try jsonDecoder.decode(T.self, from: data)
    }

    public func POST<T: Decodable, B: Encodable>(
        url: String,
        body: B,
        headers: [String: String]? = nil,
        queryParameters: [String: String]? = nil
    ) async throws -> T {
        guard let url = URL(string: url).withQueryParameters(queryParameters) else { throw NetworkClientError.invalidUrl }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest = urlRequest.withHeaders(headers)

        let encodedData = try jsonEncoder.encode(body)
        urlRequest.httpBody = encodedData

        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLSessionError.failedHTTPResponseCast
        }
        try ResponseDetails(httpResponse: httpResponse, data: data).checkOKStatus()
        return try jsonDecoder.decode(T.self, from: data)
    }

    public func PUT<T: Decodable, B: Encodable>(
        url: String,
        body: B,
        headers: [String: String]? = nil,
        queryParameters: [String: String]? = nil
    ) async throws -> T {
        guard let url = URL(string: url).withQueryParameters(queryParameters) else { throw NetworkClientError.invalidUrl }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest = urlRequest.withHeaders(headers)

        let encodedData = try jsonEncoder.encode(body)
        urlRequest.httpBody = encodedData

        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLSessionError.failedHTTPResponseCast
        }
        try ResponseDetails(httpResponse: httpResponse, data: data).checkOKStatus()
        return try jsonDecoder.decode(T.self, from: data)
    }

    public func DELETE<T: Decodable>(
        url: String,
        headers: [String: String]? = nil,
        queryParameters: [String: String]? = nil
    ) async throws -> T {
        guard let url = URL(string: url).withQueryParameters(queryParameters) else { throw NetworkClientError.invalidUrl }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest = urlRequest.withHeaders(headers)

        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLSessionError.failedHTTPResponseCast
        }
        try ResponseDetails(httpResponse: httpResponse, data: data).checkOKStatus()
        return try jsonDecoder.decode(T.self, from: data)
    }
}

public enum NetworkClientKey: DependencyKey, Sendable {
    public static let liveValue: NetworkClient = NetworkClient()
}

public extension DependencyValues {
    var networkClient: NetworkClient {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }
}


extension URL? {
    func withQueryParameters(_ parameters: [String: String]?) -> URL? {
        guard let self else { return nil }
        guard let parameters else { return self }
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return urlComponents?.url ?? self
    }
}

extension URLRequest {
    func withHeaders(_ headers: [String: String]?) -> URLRequest {
        guard let headers else { return self }
        var mutableSelf = self
        for (key, value) in headers {
            mutableSelf.setValue(value, forHTTPHeaderField: key)
        }
        return mutableSelf
    }
}
