//
//  GressoAppApp.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 07.06.2023.
//

import SwiftUI
import AWSCore

let RFont = R.font
let RImage = R.image
let Localizable = R.string.localizable

@main
struct GressoAppApp: App {
    
    init() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast2, identityPoolId: "us-east-2:8b7fcad8-4407-4d04-a0bd-2e134d84e98d")
        let configuration = AWSServiceConfiguration(region: .USEast2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
