//
//  ClassIdentifiable.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 25.06.2023.
//

protocol ClassIdentifiable {
    static var reuseId: String { get }
}

extension ClassIdentifiable {

    static var reuseId: String {
        String(describing: self)
    }

}
