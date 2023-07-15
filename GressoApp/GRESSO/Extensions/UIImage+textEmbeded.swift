//
//  UIImage+textEmbeded.swift
//  GRESSO
//
//  Created by Dmitry Koshelev on 13.07.2023.
//

import UIKit

extension UIImage {
    static func textEmbeded(image: UIImage,
                           string: String,
                isImageBeforeText: Bool,
                          segFont: UIFont? = nil) -> UIImage {
        let font = segFont ?? UIFont.systemFont(ofSize: 16)
        let expectedTextSize = (string as NSString).size(withAttributes: [.font: font])
        let width = expectedTextSize.width + image.size.width + 10
        let height = max(expectedTextSize.height, image.size.width)
        let size = CGSize(width: width, height: height)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let fontTopPosition: CGFloat = (height - expectedTextSize.height) / 2
            let textOrigin: CGFloat = isImageBeforeText
                ? image.size.width + 10
                : 0
            let textPoint: CGPoint = CGPoint.init(x: textOrigin, y: fontTopPosition)
            string.draw(at: textPoint, withAttributes: [.font: font])
            let alignment: CGFloat = isImageBeforeText
                ? 0
                : expectedTextSize.width + 10
            let rect = CGRect(x: alignment,
                              y: (height - image.size.height) / 2,
                          width: image.size.width,
                         height: image.size.height)
            image.draw(in: rect)
        }
    }
}
