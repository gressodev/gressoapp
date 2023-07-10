//
//  SliderView.swift
//  GRESSO
//
//  Created by Dmitry Koshelev on 10.07.2023.
//

import SwiftUI

struct SliderView: UIViewRepresentable {
    
    @Binding var isSliderGoingDown: Bool
    
    func makeUIView(context: Context) -> UISlider {
        let view = UISlider()
        view.maximumValue = 10
        view.minimumValue = 0
        
        return view
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        if isSliderGoingDown {
            UIView.animate(withDuration: 2) {
                uiView.setValue(0, animated: true)
            }
        } else {
            UIView.animate(withDuration: 2) {
                uiView.setValue(10, animated: true)
            }
        }
    }
    
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
        SliderView(isSliderGoingDown: .constant(false))
    }
}
