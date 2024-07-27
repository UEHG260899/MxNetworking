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
    let responseText: String
    
    
    init(state: NetworkingView.State) {
        self.state = state
        self.responseText = ""
        
        switch state {
        case .none, .loading:
            self.responseStatusLabel = ""
        case .success:
            self.responseStatusLabel = "Status: Success"
        case .failure:
            self.responseStatusLabel = "Status Failure"
        }
    }

    init(state: NetworkingView.State, responseText: String) {
        self.state = state
        self.responseText = responseText
        
        switch state {
        case .none, .loading:
            self.responseStatusLabel = ""
        case .success:
            self.responseStatusLabel = "Status: Success"
        case .failure:
            self.responseStatusLabel = "Status Failure"
        }
    }
    
    init(state: NetworkingView.State, content: [Pokemon]) {
        self.state = state
        
        var textToShow = ""
        for pokemon in content {
            textToShow += "\(pokemon.name.capitalized) \n"
        }
        
        self.responseText = textToShow
        
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
