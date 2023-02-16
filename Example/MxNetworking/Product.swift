//
//  Product.swift
//  MxNetworking_Example
//
//  Created by Uriel Hernandez Gonzalez on 15/02/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

struct Product: Codable {
    let id: Int?
    let title: String
    let price: Double
    let description: String
    let image: String
    let category: String
}
