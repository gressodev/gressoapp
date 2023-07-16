//
//  Assets.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 24.06.2023.
//

import UIKit
import SwiftUI

enum Images {
    static let menuButtonIcon: String = "menuButtonIcon"
    static let chevronBackward: String = "chevron.backward"
    static let virtualTryOnIcon: String = "virtualTryOnIcon"
    static let xmarkCircleFill: String = "xmark.circle.fill"
    static let photoСircle: String = "photo.circle"
    static let shareImage: String = "arrowshape.turn.up.right.fill"
    static let downloadImage: String = "square.and.arrow.down"
    
    static let sun = RImage.sun() ?? UIImage()
    static let home = RImage.home() ?? UIImage()
    static let squares = RImage.squares() ?? UIImage()
    static let favorites = RImage.favorites() ?? UIImage()
    static let bag = RImage.bag() ?? UIImage()
    static let stars = RImage.stars() ?? UIImage()
    static let cross = RImage.cross() ?? UIImage()
    static let download = RImage.download() ?? UIImage()
    static let share = RImage.share() ?? UIImage()
}

enum Fonts {
    static let jostRegular16ui: UIFont = RFont.jostRegular(size: 16) ?? .systemFont(ofSize: 16)
    static let jostRegular16: Font = Font(Fonts.jostRegular16ui as CTFont)
    
    static let jostMedium30ui: UIFont = RFont.jostMedium(size: 30) ?? .systemFont(ofSize: 30)
    static let jostMedium30: Font = Font(Fonts.jostMedium30ui as CTFont)
    
    static let jostMedium40ui: UIFont = RFont.jostMedium(size: 40) ?? .systemFont(ofSize: 40)
    static let jostMedium40: Font = Font(Fonts.jostMedium40ui as CTFont)
}
