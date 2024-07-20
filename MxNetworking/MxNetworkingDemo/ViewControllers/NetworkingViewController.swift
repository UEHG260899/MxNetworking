//
//  NetworkingViewController.swift
//  MxNetworkingDemo
//
//  Created by Uriel Hernandez Gonzalez on 13/07/24.
//

import MxNetworking
import UIKit

class NetworkingViewController: UIViewController {

    private let networker: MxNetworker
    
    private lazy var networkingView: NetworkingView = {
        let view = NetworkingView()
        view.delegate = self
        view.model = NetworkingViewModel(state: .none)
        return view
    }()
    
    override func loadView() {
        view = networkingView
    }

    init(networker: MxNetworker) {
        self.networker = networker
        super.init(nibName: nil, bundle: nil)
        title = "Closure Networking"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NetworkingViewController: NetworkingViewDelegate {
    func handleExecuteButtonTap() {
        networkingView.model = NetworkingViewModel(state: .loading)
    }

}
