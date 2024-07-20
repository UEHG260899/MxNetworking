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
    }

}
