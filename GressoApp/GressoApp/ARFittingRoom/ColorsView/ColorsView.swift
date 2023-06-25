//
//  ColorsView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 25.06.2023.
//

import SwiftUI

struct ColorsView: UIViewRepresentable {
    
    let dataSource: [String]
    var completion: (Int) -> Void
    
    func makeUIView(context: Context) -> PagingColorsView {
        PagingColorsView(items: dataSource) { index in
            completion(index)
        }
    }
    
    func updateUIView(_ uiView: PagingColorsView, context: Context) { }
}
