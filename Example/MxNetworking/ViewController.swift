//
//  ViewController.swift
//  MxNetworking
//
//  Created by UEHG260899 on 02/15/2023.
//  Copyright (c) 2023 UEHG260899. All rights reserved.
//

import UIKit
import MxNetworking

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self) { result in
            switch result {
            case .success(let pokemons):
                print(pokemons)
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

