//
//  TryOnButton.swift
//  GRESSO
//
//  Created by Dmitry Koshelev on 15.07.2023.
//

import SwiftUI

struct GressoStyiledButton: View {
    
    let image: UIImage
    let text: String?
    
    let height: CGFloat
    let cornerRadius: CGFloat
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    
    init(
        image: UIImage,
        text: String? = nil,
        height: CGFloat = 44,
        cornerRadius: CGFloat = 4,
        verticalPadding: CGFloat = 8,
        horizontalPadding: CGFloat = 16
    ) {
        self.image = image
        self.text = text
        self.height = height
        self.cornerRadius = cornerRadius
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 11) {
            Image(uiImage: image)
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
            if let text {
                Text(text)
                    .font(Fonts.jostRegular16)
            }
        }
        .frame(
            maxWidth: .infinity,
            minHeight: height,
            idealHeight: height,
            maxHeight: height,
            alignment: .center
        )
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(
                cornerRadius: cornerRadius
            )
            .inset(by: 0.75)
            .stroke(.white.opacity(0.5), lineWidth: 1.5)
        )
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
    }
    
}
