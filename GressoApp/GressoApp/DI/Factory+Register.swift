//
//  Factory+Register.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 14.06.2023.
//

import Factory

extension Container {
    
    var loadGlassesService: Factory<LoadGlassesServiceInterface> {
        Factory(self) { LoadGlassesService() }
    }
    
}
