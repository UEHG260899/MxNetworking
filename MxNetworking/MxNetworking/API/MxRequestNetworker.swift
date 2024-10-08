//
//  MxRequestNetworker.swift
//  MxNetworking
//
//  Created by Uriel Hernandez Gonzalez on 14/08/24.
//

import Foundation

/// Network client provided by MxNetworking
public struct MxRequestNetworker: Sendable {
    private let session: URLSessionProtocol
    
    /// Creates a network client
    /// - Parameter session: The `URLSession` object from which network requests will be made.
    /// `URLSession.shared` by default
    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    /// Executes a network request and completes with `Data` in order to perform custom decodings
    /// or any other custom logic with it
    /// - Parameters:
    ///   - request: Object containing the request information
    ///   - completion: Handler to be called once the request completes. Runs on `MainActor`
    public func data(for request: Request, completion: @MainActor @Sendable @escaping (Result<Data, APIError>) -> Void) {
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
                result = .failure(.unknown(description: "No data received"))
                return
            }
            
            result = .success(data)
            
        }.resume()
    }

    /// Executes a network request and returns with `Data` in order to perform custom decodings
    /// or any other custom logic with it
    /// - Parameter request: Object containing the request information
    /// - Returns: The `Data` received from the request
    /// - Throws: ``APIError`` or generic `Error` if `URLSession` throws
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
    
    /// Executes a network request and tries to decode the received data into a given model conforming to `Decodable`
    ///
    ///Usage example:
    /// ```swift
    ///networker.model(from: request) { (request: Result<YourCustomDecodableType, APIError>) in
    ///    // Your code here
    ///}
    /// ```
    /// - Parameters:
    ///   - request: Object containing the request information
    ///   - completion: Handler to be called once the request completes. Runs on `MainActor`
    public func model<T: Decodable & Sendable>(from request: Request, completion: @MainActor @Sendable @escaping (Result<T,APIError>) -> Void) {
        guard let urlRequest = request.httpRequest() else {
            Task {
                await completion(.failure(.invalidRequest))
            }
            return
        }
        
        session.dataTask(with: urlRequest) { data, response, error in
            let result: Result<T, APIError>

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
                result = .failure(.unknown(description: "No data received"))
                return
            }
            
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                result = .success(model)
            } catch {
                result = .failure(.failedDeserialization(type: String(describing: T.self)))
            }
        }.resume()
    }

    
    /// Executes a network request and tries to decode the received `Data` into a given model conforming to `Decodable`
    /// and returns it
    ///
    /// Usage example:
    /// ```swift
    ///struct MyModel: Decodable {
    ///    let title: String
    ///}
    ///
    ///let request = Request(url: "www.example.com")
    ///let model: MyModel = try await networker.model(from: request)
    /// ```
    /// - Parameter request: Object containing the request information
    /// - Returns: Model decoded form data
    /// - Throws: ``APIError`` or generic `Error` if `URLSession` throws
    public func model<T: Decodable>(from request: Request) async throws -> T {
        guard let httpRequest = request.httpRequest() else {
            throw APIError.invalidRequest
        }
        
        let (data, response) = try await session.data(for: httpRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(response: response)
        }
        
        guard (200...300) ~= httpResponse.statusCode else {
            throw APIError.requestFailed(errorCode: httpResponse.statusCode)
        }
        
        guard let model = try? JSONDecoder().decode(T.self, from: data) else {
            throw APIError.failedDeserialization(type: String(describing: T.self))
        }
        
        return model
    }
}
