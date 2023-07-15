//
//  Assets.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 24.06.2023.
//

import UIKit

enum Assets {
    enum Images {
        
        enum TabBar {
            static let tabItemHome: String = "tabBar.home"
            static let tabItemGlasses: String = "tabBar.glasses"
            static let tabItemBag: String = "tabBar.bag"
        }
        
        static let menuButtonIcon: String = "menuButtonIcon"
        static let chevronBackward: String = "chevron.backward"
        static let virtualTryOnIcon: String = "virtualTryOnIcon"
        static let xmarkCircleFill: String = "xmark.circle.fill"
        static let photoСircle: String = "photo.circle"
        static let shareImage: String = "arrowshape.turn.up.right.fill"
        static let downloadImage: String = "square.and.arrow.down"
        static let heart: String = "heart"
        
        static let sun = RImage.sun() ?? UIImage()
        static let home = RImage.home() ?? UIImage()
    }
}
