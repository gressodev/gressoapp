//
//  Collection+SafeGetter.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 30.06.2023.
//

import Foundation

extension Collection {

    func item(at index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}
