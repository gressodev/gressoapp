//
//  TryOnButton.swift
//  GRESSO
//
//  Created by Dmitry Koshelev on 15.07.2023.
//

import SwiftUI

struct TryOnButton: View {
    
    private enum LocalConstants {
        static let height: CGFloat = 44
        static let cornerRadius: CGFloat = 4
        static let verticalPadding: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 11) {
            Image(uiImage: Images.stars)
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
            Text(Localizable.tryOn())
                .font(Fonts.jostRegular16)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: LocalConstants.height,
            idealHeight: LocalConstants.height,
            maxHeight: LocalConstants.height,
            alignment: .center
        )
        .cornerRadius(LocalConstants.cornerRadius)
        .overlay(
            RoundedRectangle(
                cornerRadius: LocalConstants.cornerRadius
            )
            .inset(by: 0.75)
            .stroke(.white.opacity(0.5), lineWidth: 1.5)
        )
        .padding(.vertical, LocalConstants.verticalPadding)
        .padding(.horizontal, LocalConstants.horizontalPadding)
    }
    
}


struct TryOnButton_Previews: PreviewProvider {
    static var previews: some View {
        TryOnButton()
    }
}
