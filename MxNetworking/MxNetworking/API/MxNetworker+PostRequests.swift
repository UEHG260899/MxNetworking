//
//  MxNetworker+PostRequests.swift
//  MxNetworking
//
//  Created by Uriel Hernandez Gonzalez on 06/04/23.
//

import Foundation

public extension MxNetworker {
    
    /// Makes a POST request to a certain endpoint
    /// - Parameters:
    ///   - endpoint: The endpoint used for the request
    ///   - body: The request body
    ///   - headers: Headers for the request, nil by default
    ///   - completion: Completion handler
    func post(
        endpoint: EndpointType,
        body: Encodable,
        headers: [String: String]? = nil,
        completion: @Sendable @escaping (Result<Void, APIError>) -> Void
    ) {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.httpBody = try? JSONEncoder().encode(body)

        if let headers {
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        }
        
        startPostRequest(request, completion: completion)
    }

    /// Makes a POST request to a certain url
    /// - Parameters:
    ///   - url: The url used for the request
    ///   - body: The request body
    ///   - headers: Headers for the request, nil by default
    ///   - completion: Completion handler
    func post(
        url: URL,
        body: Encodable,
        headers: [String: String]? = nil,
        completion: @Sendable @escaping (Result<Void, APIError>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.httpBody = try? JSONEncoder().encode(body)

        if let headers {
            headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        }

        startPostRequest(request, completion: completion)
    }

    private func startPostRequest(_ request: URLRequest, completion: @Sendable @escaping (Result<Void, APIError>) -> Void) {
        session.dataTask(with: request) { _, response, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(.unknown(description: "\(error)")))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse(response: response)))
                }
                return
            }

            guard 200...300 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(errorCode: httpResponse.statusCode)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }.resume()
    }

    /// Makes a POST request to a certain endpoint
    /// - Parameters:
    ///   - endpoint: The endpoint used for the request
    ///   - returnType: The data type of the expected response (Must conform to Decodable protocol)
    ///   - body: The request body
    ///   - headers:  Headers for the request, nil by default
    func post(endpoint: EndpointType, body: Encodable, headers: [String: String]? = nil) async throws {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.httpBody = try? JSONEncoder().encode(body)

        if let headers {
            headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        }

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(response: response)
        }

        guard 200...300 ~= httpResponse.statusCode else {
            throw APIError.requestFailed(errorCode: httpResponse.statusCode)
        }
    }

    /// Makes a POST request to a certain url
    /// - Parameters:
    ///   - url: The url used for the request
    ///   - body: The request body
    ///   - headers: Headers for the request, nil by default
    func post(url: URL, body: Encodable, headers: [String: String]? = nil) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.httpBody = try? JSONEncoder().encode(body)

        if let headers {
            headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        }

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(response: response)
        }

        guard 200...300 ~= httpResponse.statusCode else {
            throw APIError.requestFailed(errorCode: httpResponse.statusCode)
        }
    }
    
}
