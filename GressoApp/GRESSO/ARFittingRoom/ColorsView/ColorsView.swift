//
//  ColorsView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 25.06.2023.
//

import SwiftUI

struct ColorsView: UIViewRepresentable {
    
    @Binding var models: [LoadingModel]
    var completion: (Int) -> Void
    
    func makeUIView(context: Context) -> PagingColorsView {
        PagingColorsView(models: models) { index in
            completion(index)
        }
    }
    
    func updateUIView(_ uiView: PagingColorsView, context: Context) {
        uiView.models = models
        uiView.reloadData()
    }
}
