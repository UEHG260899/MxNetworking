//
//  FakeStoreEnpoint.swift
//  MxNetworking_Example
//
//  Created by Uriel Hernandez Gonzalez on 15/02/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import MxNetworking

enum FakeStoreEndpoint: EndpointType {
    case createProduct
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "fakestoreapi.com"
        
        switch self {
        case .createProduct:
            components.path = "/products"
        }
        
        return components.url!
    }
}
