//
//  ColorsView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 25.06.2023.
//

import SwiftUI

struct ColorsView: UIViewRepresentable {
    
    let modelsCount: Int
    var completion: (Int) -> Void
    
    func makeUIView(context: Context) -> PagingColorsView {
        PagingColorsView(modelsCount: modelsCount) { index in
            completion(index)
        }
    }
    
    func updateUIView(_ uiView: PagingColorsView, context: Context) { }
}
