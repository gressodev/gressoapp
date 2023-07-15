//
//  UIView+Screenshot.swift
//  GRESSO
//
//  Created by Dmitry Koshelev on 15.07.2023.
//

import UIKit

extension UIView {

    func takeScreenshot() -> UIImage? {

        // Begin context
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

}
