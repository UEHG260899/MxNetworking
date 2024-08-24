//
//  NetworkingViewController.swift
//  MxNetworkingDemo
//
//  Created by Uriel Hernandez Gonzalez on 13/07/24.
//

import MxNetworking
import UIKit

class NetworkingViewController: UIViewController {

    private let networkingStrategy: NetworkingStrategy
    
    private lazy var networkingView: NetworkingView = {
        let view = NetworkingView()
        view.delegate = self
        view.model = NetworkingViewModel(state: .none)
        return view
    }()
    
    override func loadView() {
        view = networkingView
    }

    init(networkingStrategy: NetworkingStrategy) {
        self.networkingStrategy = networkingStrategy
        super.init(nibName: nil, bundle: nil)
        title = "Closure Networking"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NetworkingViewController: NetworkingViewDelegate {
    func handleExecuteButtonTap(method: String) {
        networkingView.model = NetworkingViewModel(state: .loading)
        Task {
            
            let model: NetworkingViewModel
            
            if method == "GET" {
                let result: Result<PokemonList, APIError> = await networkingStrategy.executeRequest(endpoint: PokeApiEndpoint.pokemonList(limit: 50))
                
                switch result {
                case .success(let list):
                    model = NetworkingViewModel(state: .success, content: list.results)
                case .failure(let error):
                    model = NetworkingViewModel(state: .failure, responseText: error.localizedDescription)
                }
                
                networkingView.model = model
                return
            }
            
            let result = await networkingStrategy.executeRequest(endpoint: FakeStoreEndpoint.createProduct, body: Product.mock)
            
            switch result {
            case .success:
                model = NetworkingViewModel(state: .success, responseText: "Post requests usually don´t return anything")
            case .failure(let error):
                model = NetworkingViewModel(state: .failure, responseText: error.localizedDescription)
            }
            
            networkingView.model = model
        }
    }

}
