//
//  AlertProvider.swift
//  MxNetworking_Example
//
//  Created by Uriel Hernandez Gonzalez on 06/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class AlertProvider {
    
    static let shared = AlertProvider()
    
    private init() {}
    
    func showSuccessAlert(data: Any, in viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Request Success"
        alert.message = "The request completed with the following data: \(data)"
        let acceptAction = UIAlertAction(title: "Accept", style: .default)
        alert.addAction(acceptAction)
        viewController.present(alert, animated: true)
    }

    func showErrorAlert(with error: Error, in viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Request Failure"
        alert.message = "The request completed with the following error: \(error)"
        let acceptAction = UIAlertAction(title: "Accept", style: .default)
        alert.addAction(acceptAction)
        viewController.present(alert, animated: true)
    }
    
}
