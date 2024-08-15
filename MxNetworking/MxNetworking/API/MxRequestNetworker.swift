//
//  MxRequestNetworker.swift
//  MxNetworking
//
//  Created by Uriel Hernandez Gonzalez on 14/08/24.
//

import Foundation

struct MxRequestNetworker {
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
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

    public func model<T: Decodable>(from request: Request, completion: @MainActor @escaping (Result<T,APIError>) -> Void) {
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
            
            result = .failure(.invalidRequest)
        }.resume()
    }
}