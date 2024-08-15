//
//  MxNetworker.swift
//  Networking
//
//  Created by Uriel Hernandez Gonzalez on 25/11/22.
//

import Foundation

public class MxNetworker {
    let session: URLSessionProtocol
    
    /// Initializer for the MxNetworker class
    /// - Parameter session: The **URLSession** object from which network requests will be made
    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    /// Makes a GET request to a certain endpoint
    /// - Parameters:
    ///   - endpoint: The endpoint used for the request
    ///   - decodingType: The data type that is expected to decode (Must conform to Decodable protocol)
    ///   - completion: Completion handler
    public func fetch<T: Decodable>(endpoint: EndpointType, decodingType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = HTTPMethod.GET.rawValue

        startFetchRequest(request: request, decodingType: decodingType, completion: completion)
    }

    /// Makes a GET request to a certain url
    /// - Parameters:
    ///   - url: The url used for the request
    ///   - decodingType: The data type that is expected to decode (Must conform to Decodable protocol)
    ///   - completion: Completion handler
    public func fetch<T: Decodable>(url: URL, decodingType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        startFetchRequest(request: request, decodingType: decodingType, completion: completion)
    }

    private func startFetchRequest<T: Decodable>(request: URLRequest, decodingType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        session.dataTask(with: request) { data, response, error in
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

            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(.unknown(description: "No data received")))
                }
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(decodingType, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.failedDeserialization(type: String(describing: decodingType))))
                }
            }
        }.resume()
    }

    /// Makes a GET request to a certain endpoint using async sintax
    /// - Parameters:
    ///   - endpoint: The endpoint used for the request
    ///   - decodingType: The data type that is expected to decode (Must conform to Decodable protocol)
    /// - Returns: An object of the decoding type
    public func fetch<T: Decodable>(endpoint: EndpointType, decodingType: T.Type) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        return try await startAsyncFetchRequest(request, decodingType: decodingType)
    }

    /// Makes a GET request to a certain url
    /// - Parameters:
    ///   - url: The url used for the request
    ///   - decodingType: The data type that is expected to decode (Must conform to Decodable protocol)
    /// - Returns: An object of the decoding type
    public func fetch<T: Decodable>(url: URL, decodingType: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue

        return try await startAsyncFetchRequest(request, decodingType: decodingType)
    }

    private func startAsyncFetchRequest<T: Decodable>(_ request: URLRequest, decodingType: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(response: response)
        }

        guard 200...300 ~= httpResponse.statusCode else {
            throw APIError.requestFailed(errorCode: httpResponse.statusCode)
        }

        do {
            let decodedData = try JSONDecoder().decode(decodingType, from: data)
            return decodedData
        } catch {
            throw APIError.failedDeserialization(type: String(describing: decodingType))
        }
    }

    
    /// Executes a network request and completes with `Data` in order to perform custom decodings
    /// or any other custom logic with it
    /// - Parameters:
    ///   - request: Object containing the request information
    ///   - completion: Handler to be called once the request completes
    public func data(for request: Request, completion: @MainActor @escaping (Result<Data, APIError>) -> Void) {
        guard let urlRequest = request.httpRequest() else {
            Task {
                await completion(.failure(.invalidRequest))
            }
            return
        }
        
        session.dataTask(with: urlRequest) { data, response, error in
            let result: Result<Data, APIError>
            
            defer {
                Task {
                    await completion(result)
                }
            }
            
            if let error {
                result = .failure(.unknown(description: error.localizedDescription))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                result = .failure(.invalidResponse(response: response))
                return
            }

            guard (200...300) ~= httpResponse.statusCode else {
                result = .failure(.requestFailed(errorCode: httpResponse.statusCode))
                return
            }
            
            guard let data else {
                result = .failure(.unknown(description: "No data recieved"))
                return
            }
            
            result = .success(data)
            
        }.resume()
    }

    /// Executes a network request and returns with `Data` in order to perform custom decodings
    /// or any other custom logic with it
    /// - Parameter request: Object containing the request information
    /// - Returns: The `Data` received from the request
    public func data(for request: Request) async throws -> Data {
        guard let urlRequest = request.httpRequest() else {
            throw APIError.invalidRequest
        }

        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(response: response)
        }
    
        guard (200...300) ~= httpResponse.statusCode else {
            throw APIError.requestFailed(errorCode: httpResponse.statusCode)
        }
        
        return data
    }
}
