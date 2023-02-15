//
//  API.swift
//  Networking
//
//  Created by Uriel Hernandez Gonzalez on 25/11/22.
//

import Foundation

public struct API {

    /// Makes a GET request to a certain endpoint
    /// - Parameters:
    ///   - endpoint: The endpoint used for the request
    ///   - decodingType: The data type that is expected to decode (Must conform to Decodable protocol)
    ///   - completion: Completion handler
    public static func fetch<T: Decodable>(endpoint: EndpointType, decodingType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        self.start(request, completion: completion)
    }

    /// Makes a GET request to a certain url
    /// - Parameters:
    ///   - url: The url used for the request
    ///   - decodingType: The data type that is expected to decode (Must conform to Decodable protocol)
    ///   - completion: Completion handler
    public static func fetch<T: Decodable>(url: URL, decodingType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        self.start(request, completion: completion)
    }

    /// Makes a POST request to a certain endpoint
    /// - Parameters:
    ///   - endpoint: The endpoint used for the request
    ///   - returnType: The data type of the expected response (Must conform to Decodable protocol)
    ///   - body: The request body
    ///   - headers: Headers for the request, nil by default
    ///   - completion: Completion handler
    public static func post<T: Decodable>(endpoint: EndpointType, returnType: T.Type, body: Encodable, headers: [String: String]? = nil, completion: @escaping (Result<T, APIError>) -> Void) {
        var request = URLRequest(url: endpoint.url)
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
    ///   - returnType: The data type of the expected response (Must conform to Decodable protocol)
    ///   - body: The request body
    ///   - headers: Headers for the request, nil by default
    ///   - completion: Completion handler
    public static func post<T: Decodable>(url: URL, returnType: T.Type, body: Encodable, headers: [String: String]? = nil, completion: @escaping (Result<T, APIError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = try? JSONEncoder().encode(body)
        
        if let headers = headers {
            headers.forEach { request.setValue($0, forHTTPHeaderField: $1) }
        }
        
        self.start(request, completion: completion)
    }

    private static func start<T: Decodable>(_ request: URLRequest, completion: @escaping (Result<T, APIError>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error != nil {
                completion(.failure(.unknown(description: "\(error!)")))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse(response: response)))
                return
            }

            guard 200...300 ~= httpResponse.statusCode else {
                completion(.failure(.requestFailed(errorCode: httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(.unknown(description: "No data received")))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.failedDeserialization(type: String(describing: T.self))))
            }
        }.resume()
    }
}
