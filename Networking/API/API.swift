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
    
    
    @available(iOS 15, *)
    /// Makes a GET request to a certain endpoint using async sintax
    /// - Parameters:
    ///   - endpoint: The endpoint used for the request
    ///   - decodingType: The data type that is expected to decode (Must conform to Decodable protocol)
    /// - Returns: An object of the decoding type
    public static func fetch<T: Decodable>(endpoint: EndpointType, decodingType: T.Type) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        return try await start(request)
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
    
    @available(iOS 15, *)
    /// Makes a GET request to a certain url
    /// - Parameters:
    ///   - url: The url used for the request
    ///   - decodingType: The data type that is expected to decode (Must conform to Decodable protocol)
    /// - Returns: An object of the decoding type
    public static func fetch<T: Decodable>(url: URL, decodingType: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        return try await start(request)
    }

    private static func start<T: Decodable>(_ request: URLRequest, completion: @escaping (Result<T, APIError>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            
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

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.unknown(description: "No data received")))
                }
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.failedDeserialization(type: String(describing: T.self))))
                }
            }
        }.resume()
    }

    private static func start<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) =  try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(response: response)
        }
        
        guard 200...300 ~= httpResponse.statusCode else {
            throw APIError.requestFailed(errorCode: httpResponse.statusCode)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw APIError.failedDeserialization(type: String(describing: T.self))
        }
    }
}


public class MxNetworker {
    let session: URLSessionProtocol
    
    /// Initializer for the MxNetworker class
    /// - Parameter session: The **URLSession** object from which network requests will be made
    public init(session: URLSessionProtocol) {
        self.session = session
    }

    /// Makes a GET request to a certain endpoint
    /// - Parameters:
    ///   - endpoint: The endpoint used for the request
    ///   - decodingType: The data type that is expected to decode (Must conform to Decodable protocol)
    ///   - completion: Completion handler
    public func fetch<T: Decodable>(endpoint: EndpointType, decodingType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = HTTPMethod.get.rawValue

        startFetchRequest(request: request, decodingType: decodingType, completion: completion)
    }

    /// Makes a GET request to a certain url
    /// - Parameters:
    ///   - url: The url used for the request
    ///   - decodingType: The data type that is expected to decode (Must conform to Decodable protocol)
    ///   - completion: Completion handler
    public func fetch<T: Decodable>(url: URL, decodingType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        startFetchRequest(request: request, decodingType: decodingType, completion: completion)
    }

    private func startFetchRequest<T: Decodable>(request: URLRequest, decodingType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(.unknown(description: "\(error)")))
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

            guard let data else {
                completion(.failure(.unknown(description: "No data received")))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(decodingType, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.failedDeserialization(type: String(describing: decodingType))))
            }
        }.resume()
    }
}
