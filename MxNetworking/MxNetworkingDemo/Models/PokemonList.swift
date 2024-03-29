//
//  PokemonList.swift
//  MxNetworking_Example
//
//  Created by Uriel Hernandez Gonzalez on 15/02/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

struct PokemonList: Decodable {
    let results: [Pokemon]
}

struct Pokemon: Decodable {
    let name: String
    let url: String
}
