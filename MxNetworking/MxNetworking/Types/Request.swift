//
//  Request.swift
//  MxNetworking
//
//  Created by Uriel Hernandez Gonzalez on 27/07/24.
//

import Foundation


/// An HTTP URL request object
public struct Request {
    
    private let url: URL?
    private let requestMethod: HTTPMethod
    private var params: [String: String]?
    private var requestBody: Encodable?
    
    /// Creates a Request with the provided url string. Uses **GET** http method
    /// - Parameter url: String from which the request will be created
    public init(url: String) {
        self.init(url: url, method: .GET)
    }

    /// Creates a Request with the provided url string, method, query parameters and body
    /// - Parameters:
    ///   - url: String from which the request will be created
    ///   - method: HTTP method to be used in the request.
    ///   - parameters: Dictionary to be used as Query Parameters. Defaults to **nil**
    ///   - body: Request´s body. Defaults to **nil**
    public init(url: String, method: HTTPMethod, parameters: [String: String]? = nil, body: Encodable? = nil) {
        self.url = URL(string: url)
        self.requestMethod = method
        self.params = parameters
        self.requestBody = body
    }
    
    func httpRequest() -> URLRequest? {
        guard let url else {
            return nil
        }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        if let components {
            return handleRequestCreation(with: components)
        }

        return nil
    }

    private func handleRequestCreation(with components: URLComponents) -> URLRequest? {
        var components = components
        if let params {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = requestMethod.rawValue
        
        if let requestBody, let encodedData = try? JSONEncoder().encode(requestBody) {
            request.httpBody = encodedData
        }
        
       
        return request
    }
}

