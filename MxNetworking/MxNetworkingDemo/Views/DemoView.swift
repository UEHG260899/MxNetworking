//
//  DemoView.swift
//  MxNetworking_Example
//
//  Created by Uriel Hernandez Gonzalez on 06/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class DemoView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Select a method to perform the request"
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    
    lazy var closureFetchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Closure Fetch", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 12
        return button
    }()
    
    lazy var closurePostButton: UIButton = {
        let button = UIButton()
        button.setTitle("Closure Post", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 12
        return button
    }()
    
    lazy var asyncFetchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Async Fetch", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 12
        return button
    }()
    
    lazy var asyncPostButton: UIButton = {
        let button = UIButton()
        button.setTitle("Async Post", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 12
        return button
    }()

    lazy var footNoteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = "Fetch requests are made to PokeApi and Post requests are made to a dummy api"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.addArrangedSubview(closureFetchButton)
        stackView.addArrangedSubview(closurePostButton)
        stackView.addArrangedSubview(asyncFetchButton)
        stackView.addArrangedSubview(asyncPostButton)

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
            footNoteLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            footNoteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            footNoteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
