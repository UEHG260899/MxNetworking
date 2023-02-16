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

        if #available(iOS 15, *) {
            fetchWithAsync()
            postWithAsync()
        } else {
            fetchWithClosures()
        }
    }
}

extension ViewController {
    @available(iOS 15, *)
    func fetchWithAsync() {
        Task {
            do {
                let pokemonData = try await API.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self)
                print("Async fetch: \(pokemonData)")
            } catch {
                print(error)
            }
        }
    }
    
    @available(iOS 15, *)
    func postWithAsync() {
        Task {
            do {
                let product = Product(id: nil, title: "Hola", price: 300.0, description: "Prueba", image: "dohowho", category: "dhodhapod")
                let response = try await API.post(endpoint: FakeStoreEndpoint.createProduct, returnType: Product.self, body: product)
                print("Product: \(response)")
            } catch {
                print(error)
            }
        }
    }
    
    func fetchWithClosures() {
        API.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self) { result in
            switch result {
            case .success(let pokemons):
                print("Closure fetch: \(pokemons)")
            case .failure(let failure):
                print(failure)
            }
        }
    }
}
