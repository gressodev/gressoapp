//
//  LoadingModel.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 30.06.2023.
//

import UIKit

struct LoadingModel: Hashable {
    let id: Int
    var url: URL?
    var isLoading: Bool
    var colorImage: UIImage?
}
