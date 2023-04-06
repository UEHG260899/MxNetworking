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

    private lazy var demoView: DemoView = {
       let view = DemoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(demoView)
        
        NSLayoutConstraint.activate([
            demoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            demoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            demoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            demoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        
        if #available(iOS 15, *) {
            demoView.stackView.addArrangedSubview(demoView.asyncFetchButton)
            demoView.stackView.addArrangedSubview(demoView.asyncPostButton)
            demoView.asyncFetchButton.addTarget(self, action: #selector(performAsyncFetch), for: .touchUpInside)
            demoView.asyncPostButton.addTarget(self, action: #selector(performAsyncPost), for: .touchUpInside)
        }
        configureTargets()
    }
}

private extension ViewController {
    func configureTargets() {
        demoView.closureFetchButton.addTarget(self, action: #selector(performClosureFetchRequest), for: .touchUpInside)
        demoView.closurePostButton.addTarget(self, action: #selector(performClosurePostRequest), for: .touchUpInside)
    }

    @objc
    func performClosureFetchRequest() {
        API.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self) { result in
            switch result {
            case .success(let pokemons):
                AlertProvider.shared.showSuccessAlert(data: pokemons, in: self)
            case .failure(let failure):
                AlertProvider.shared.showErrorAlert(with: failure, in: self)
            }
        }
    }

    @objc
    func performClosurePostRequest() {
        let product = Product(id: nil, title: "Hola", price: 300.0, description: "Prueba", image: "dohowho", category: "dhodhapod")
        API.post(endpoint: FakeStoreEndpoint.createProduct, body: product) { result in
            switch result {
            case .success:
                AlertProvider.shared.showSuccessAlert(data: "Post requests are not supposed to return data", in: self)
            case .failure(let failure):
                AlertProvider.shared.showErrorAlert(with: failure, in: self)
            }
        }
    }

    @available(iOS 15, *)
    @objc
    func performAsyncFetch() {
        Task {
            do {
                let pokemonData = try await API.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self)
                AlertProvider.shared.showSuccessAlert(data: pokemonData, in: self)
            } catch {
                AlertProvider.shared.showErrorAlert(with: error, in: self)
            }
        }
    }

    @available(iOS 15, *)
    @objc
    func performAsyncPost() {
        Task {
            do {
                let product = Product(id: nil, title: "Hola", price: 300.0, description: "Prueba", image: "dohowho", category: "dhodhapod")
                try await API.post(endpoint: FakeStoreEndpoint.createProduct, body: product)
                AlertProvider.shared.showSuccessAlert(data: "Post requests are not supposed to return data", in: self)
            } catch {
                AlertProvider.shared.showErrorAlert(with: error, in: self)
            }
        }
    }
}
