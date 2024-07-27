//
//  ViewPreview.swift
//  MxNetworking
//
//  Created by Uriel Hernandez Gonzalez on 13/07/24.
//

import SwiftUI

struct ViewPreview: UIViewRepresentable {
    
    let viewBuilder: (() -> UIView)
    
    init(viewBuilder: @escaping (() -> UIView)) {
        self.viewBuilder = viewBuilder
    }

    func makeUIView(context: Context) -> some UIView {
        return viewBuilder()
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
