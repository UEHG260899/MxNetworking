//
//  AsyncNetworking.swift
//  MxNetworkingDemo
//
//  Created by Uriel Hernandez Gonzalez on 20/07/24.
//

import Foundation
import MxNetworking

struct AsyncNetworking: NetworkingStrategy {
    private let networker: MxNetworker
    
    init(networker: MxNetworker) {
        self.networker = networker
    }
    
    func executeRequest<T>(endpoint: MxNetworking.EndpointType) async -> Result<T, MxNetworking.APIError> where T : Decodable {
        do {
            let results = try await networker.fetch(endpoint: endpoint, decodingType: T.self)
            return .success(results)
        } catch {
            return.failure(error as! APIError)
        }
    }
    
    func executeRequest(endpoint: MxNetworking.EndpointType, body: Encodable) async -> Result<Void, MxNetworking.APIError> {
        do {
            try await networker.post(endpoint: endpoint, body: body)
            return .success(())
        } catch {
            return .failure(error as! APIError)
        }
    }
}
