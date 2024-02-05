//
//  AppStoreReviewManager.swift
//  GRESSO
//
//  Created by Dmitry Koshelev on 07.08.2023.
//

import StoreKit

enum AppStoreReviewManager {
    
    static func requestReviewIfAppropriate() {
        let defaults = UserDefaults.standard
        let appLaunchCounter = defaults.integer(forKey: UserDefaultsKey.appLaunchCounter.rawValue)
        let shouldRequestReview = appLaunchCounter >= 4
        guard shouldRequestReview else { return }
        SKStoreReviewController.requestReviewInCurrentScene()
    }
    
}

extension SKStoreReviewController {
    
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                requestReview(in: scene)
            }
        }
    }
    
}
