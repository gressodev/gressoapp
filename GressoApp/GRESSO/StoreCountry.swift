//
//  StoreCountry.swift
//  GRESSO
//
//  Created by Dmitrii on 24.11.2024.
//

import Foundation

enum StoreCountry {
    case worldwide
    case russia
    case kazakhstan
    
    var countryName: String {
        switch self {
        case .worldwide:
            return Localizable.worldwide()
        case .russia:
            return Localizable.russia()
        case .kazakhstan:
            return Localizable.kazakhstan()
        }
    }
    
    var countryRegionCode: String {
        switch self {
        case .worldwide:
            return "US"
        case .russia:
            return "RU"
        case .kazakhstan:
            return "KZ"
        }
    }

}
