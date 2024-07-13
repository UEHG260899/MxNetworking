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

    private lazy var demoView: MainView = {
        let view = MainView()
        view.delegate = self
        return view
    }()
    
    override func loadView() {
        view = demoView
    }
}

extension MainViewController: MainViewDelegate {
    func closureButtonTapped() {
    }
    
    func asyncButtonTapped() {
    }
}
