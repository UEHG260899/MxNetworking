//
//  ClosureNetworking.swift
//  MxNetworkingDemo
//
//  Created by Uriel Hernandez Gonzalez on 20/07/24.
//

import Foundation
import MxNetworking

struct ClosureNetworking: NetworkingStrategy {
    private let networker: MxNetworker
    
    init(networker: MxNetworker) {
        self.networker = networker
    }
    
    func executeRequest<T>(endpoint: MxNetworking.EndpointType) async -> Result<T, MxNetworking.APIError> where T : Decodable {
        await withCheckedContinuation { continuation in
            networker.fetch(endpoint: endpoint, decodingType: T.self) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func executeRequest(endpoint: MxNetworking.EndpointType, body: Encodable) async -> Result<Void, MxNetworking.APIError> {
        await withCheckedContinuation { continuation in
            networker.post(endpoint: endpoint, body: body) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
