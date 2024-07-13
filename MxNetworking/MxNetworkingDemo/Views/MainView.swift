//
//  MainView.swift
//  MxNetworking_Example
//
//  Created by Uriel Hernandez Gonzalez on 06/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

protocol MainViewDelegate: AnyObject {
    func closureButtonTapped()
    func asyncButtonTapped()
}

class MainView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = """
            MxNetworking is capable of making network request both with closures and async/await, select an option bellow to continue
        """
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    
    lazy var closureBasedNetworkingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Closure based Networking", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        return button
    }()
    
    lazy var asyncBasedNetworkingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Async based Networking", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        return button
    }()

    lazy var footNoteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.text = "Fetch requests are made to PokeApi and Post requests are made to a dummy api"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    weak var delegate: MainViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        stackView.addArrangedSubview(closureBasedNetworkingButton)
        stackView.addArrangedSubview(asyncBasedNetworkingButton)
        
        addSubview(titleLabel)
        addSubview(stackView)
        addSubview(footNoteLabel)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            footNoteLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            footNoteLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            footNoteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            footNoteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            closureBasedNetworkingButton.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.12),
            asyncBasedNetworkingButton.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.12)
        ])
    
        closureBasedNetworkingButton.addTarget(self, action: #selector(closureButtonSelected), for: .touchUpInside)
        asyncBasedNetworkingButton.addTarget(self, action: #selector(asyncButtonSelected), for: .touchUpInside)
    }

    @objc private func closureButtonSelected() {
        delegate?.closureButtonTapped()
    }

    @objc private func asyncButtonSelected() {
        delegate?.asyncButtonTapped()
    }
}
