//
//  API+PostRequests.swift
//  MxNetworking
//
//  Created by Uriel Hernandez Gonzalez on 06/04/23.
//

import Foundation

public extension API {
    /// Makes a POST request to a certain endpoint
    /// - Parameters:
    ///   - endpoint: The endpoint used for the request
    ///   - body: The request body
    ///   - headers: Headers for the request, nil by default
    ///   - completion: Completion handler
    static func post(endpoint: EndpointType, body: Encodable, headers: [String: String]? = nil, completion: @escaping (Result<Void, APIError>) -> Void) {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = try? JSONEncoder().encode(body)
        
        if let headers = headers {
            headers.forEach { request.setValue($0, forHTTPHeaderField: $1) }
        }
        
        self.start(request, completion: completion)
    }

    /// Makes a POST request to a certain endpoint
    /// - Parameters:
    ///   - endpoint: The endpoint used for the request
    ///   - returnType: The data type of the expected response (Must conform to Decodable protocol)
    ///   - body: The request body
    ///   - headers:  Headers for the request, nil by default
    /// - Returns: An object of the decoding type
    @available(iOS 15, *)
    static func post(endpoint: EndpointType, body: Encodable, headers: [String: String]? = nil) async throws{
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = try? JSONEncoder().encode(body)
        
        if let headers = headers {
            headers.forEach { request.setValue($0, forHTTPHeaderField: $1) }
        }
        
        try await start(request)
    }

    /// Makes a POST request to a certain url
    /// - Parameters:
    ///   - url: The url used for the request
    ///   - body: The request body
    ///   - headers: Headers for the request, nil by default
    ///   - completion: Completion handler
    static func post(url: URL, body: Encodable, headers: [String: String]? = nil, completion: @escaping (Result<Void, APIError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = try? JSONEncoder().encode(body)
        
        if let headers = headers {
            headers.forEach { request.setValue($0, forHTTPHeaderField: $1) }
        }
        
        self.start(request, completion: completion)
    }
    
    /// Makes a POST request to a certain url
    /// - Parameters:
    ///   - url: The url used for the request
    ///   - body: The request body
    ///   - headers: Headers for the request, nil by default
    /// - Returns: An object of the decoding type
    @available(iOS 15, *)
    static func post(url: URL, body: Encodable, headers: [String: String]? = nil) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = try? JSONEncoder().encode(body)
        
        if let headers = headers {
            headers.forEach { request.setValue($0, forHTTPHeaderField: $1) }
        }
        
        try await start(request)
    }

    private static func start(_ request: URLRequest, completion: @escaping (Result<Void, APIError>) -> Void) {
        URLSession.shared.dataTask(with: request) { _, response, error in
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

    private static func start(_ request: URLRequest) async throws {
        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(response: response)
        }

        guard 200...300 ~= httpResponse.statusCode else {
            throw APIError.requestFailed(errorCode: httpResponse.statusCode)
        }
    }
}
