//
//  MainViewController.swift
//  MxNetworking
//
//  Created by UEHG260899 on 02/15/2023.
//  Copyright (c) 2023 UEHG260899. All rights reserved.
//

import UIKit
import MxNetworking

class MainViewController: UIViewController {

    private let networker = MxNetworker()

    private lazy var demoView: DemoView = {
       let view = DemoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(demoView)
        
        NSLayoutConstraint.activate([
            demoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            demoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            demoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            demoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        configureTargets()
    }
}

private extension MainViewController {
    func configureTargets() {
        demoView.closureFetchButton.addTarget(self, action: #selector(performClosureFetchRequest), for: .touchUpInside)
        demoView.closurePostButton.addTarget(self, action: #selector(performClosurePostRequest), for: .touchUpInside)
        demoView.asyncFetchButton.addTarget(self, action: #selector(performAsyncFetch), for: .touchUpInside)
        demoView.asyncPostButton.addTarget(self, action: #selector(performAsyncPost), for: .touchUpInside)
    }

    @objc
    func performClosureFetchRequest() {
        networker.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self) { result in
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
        networker.post(endpoint: FakeStoreEndpoint.createProduct, body: Product.mock) { result in
            switch result {
            case .success:
                AlertProvider.shared.showSuccessAlert(data: "Post requests are not supposed to return data", in: self)
            case .failure(let failure):
                AlertProvider.shared.showErrorAlert(with: failure, in: self)
            }
        }
    }

    @objc
    func performAsyncFetch() {
        Task {
            do {
                let pokemonData = try await networker.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 50), decodingType: PokemonList.self)
                AlertProvider.shared.showSuccessAlert(data: pokemonData, in: self)
            } catch {
                AlertProvider.shared.showErrorAlert(with: error, in: self)
            }
        }
    }

    @objc
    func performAsyncPost() {
        Task {
            do {
                try await networker.post(endpoint: FakeStoreEndpoint.createProduct, body: Product.mock)
                AlertProvider.shared.showSuccessAlert(data: "Post requests are not supposed to return data", in: self)
            } catch {
                AlertProvider.shared.showErrorAlert(with: error, in: self)
            }
        }
    }
}
