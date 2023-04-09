//
//  URLSessionProtocol.swift
//  MxNetworking
//
//  Created by Uriel Hernandez Gonzalez on 08/04/23.
//

import Foundation


/// **URLSession** conforms to this protocol by default
public protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}


extension URLSession: URLSessionProtocol {}
