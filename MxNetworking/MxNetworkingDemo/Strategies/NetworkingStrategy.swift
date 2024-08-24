//
//  NetworkingStrategy.swift
//  MxNetworkingDemo
//
//  Created by Uriel Hernandez Gonzalez on 20/07/24.
//

import Foundation
import MxNetworking

protocol NetworkingStrategy {
    func executeRequest<T: Decodable>(endpoint: EndpointType) async -> Result<T, APIError>
    func executeRequest(endpoint: EndpointType, body: Encodable) async -> Result<Void, APIError>
}
