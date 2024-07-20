//
//  NetworkingView.swift
//  MxNetworkingDemo
//
//  Created by Uriel Hernandez Gonzalez on 13/07/24.
//

import SwiftUI

protocol NetworkingViewDelegate: AnyObject {
    func handleExecuteButtonTap()
}

class NetworkingView: UIView {
    
    enum State {
        case none
        case loading
        case success
        case failure
    }

    private let httpMethods = [
        "GET",
        "POST"
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Select a HTTPMethod to perform the request with"
        return label
    }()
    
    private lazy var httpMethodPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private let executeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Execute", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .large)
        activity.translatesAutoresizingMaskIntoConstraints = false
        return activity
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status:"
        label.numberOfLines = 0
        label.textAlignment = .justified
        return label
    }()

    private let responseTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        return textView
    }()

    private let responseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    var model: NetworkingViewModel? {
        didSet {
            guard let model else { return }
            self.configure(with: model)
        }
    }

    weak var delegate: NetworkingViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(httpMethodPicker)
        titleStackView.addArrangedSubview(executeButton)
        responseStackView.addArrangedSubview(statusLabel)
        responseStackView.addArrangedSubview(responseTextView)
        addSubview(titleStackView)
        addSubview(activityIndicator)
        addSubview(responseStackView)
        
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            titleStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            executeButton.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.12)
        ])
        
        NSLayoutConstraint.activate([
            responseStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 16),
            responseStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            responseStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            responseStackView.bottomAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        executeButton.addTarget(self, action: #selector(onExecuteTapped), for: .touchUpInside)
    }
    
    #if DEBUG
    convenience init(state: NetworkingView.State) {
        self.init(frame: .zero)
        if state == .loading {
            activityIndicator.startAnimating()
        }
    }
    #endif
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let availableHeight = self.frame.height - titleStackView.frame.height - 16
        let indicatorTopSpacing = availableHeight / 2
        
        // TODO: Fix This
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: indicatorTopSpacing)
        ])
    }

    @objc private func onExecuteTapped() {
        delegate?.handleExecuteButtonTap()
    }

    private func configure(with model: NetworkingViewModel) {
        responseStackView.isHidden = model.state == .loading || model.state == .none
        model.state == .loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        statusLabel.text = model.responseStatusLabel
    }
}


extension NetworkingView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return httpMethods.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return httpMethods[row]
    }
}

struct ClosureNetworkingView_Previews: PreviewProvider {
    static var previews: some View {
        ViewPreview {
            NetworkingView(state: .none)
        }
    }
}


