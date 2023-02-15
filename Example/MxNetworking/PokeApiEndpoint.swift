//
//  PokeApiEndpoint.swift
//  MxNetworking_Example
//
//  Created by Uriel Hernandez Gonzalez on 15/02/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import MxNetworking

enum PokeApiEndpoint: EndpointType {
    
    case pokemonList(limit: Int, offset: Int = 0)
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "pokeapi.co"
        
        switch self {
        case .pokemonList(let limit, let offset):
            components.path = "/api/v2/pokemon"
            components.queryItems = [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ]
        }
        
        return components.url!
    }
}
