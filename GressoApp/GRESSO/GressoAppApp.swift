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
        
        DispatchQueue.main.async {
            let defaults = UserDefaults.standard
            if defaults.object(forKey: UserDefaultsKey.firstLaunchDate.rawValue) as? Date == nil {
                defaults.set(Date(), forKey: UserDefaultsKey.firstLaunchDate.rawValue)
            }
            let appLaunchCounter = defaults.integer(forKey: UserDefaultsKey.appLaunchCounter.rawValue)
            defaults.set(appLaunchCounter + 1, forKey: UserDefaultsKey.appLaunchCounter.rawValue)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
