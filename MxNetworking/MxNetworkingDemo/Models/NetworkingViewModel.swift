//
//  NetworkingViewModel.swift
//  MxNetworkingDemo
//
//  Created by Uriel Hernandez Gonzalez on 20/07/24.
//

import Foundation

struct NetworkingViewModel {
    let state: NetworkingView.State
    let responseStatusLabel: String
    
    
    init(state: NetworkingView.State) {
        self.state = state
        
        switch state {
        case .none, .loading:
            self.responseStatusLabel = ""
        case .success:
            self.responseStatusLabel = "Status: Success"
        case .failure:
            self.responseStatusLabel = "Status Failure"
        }
    }
}
