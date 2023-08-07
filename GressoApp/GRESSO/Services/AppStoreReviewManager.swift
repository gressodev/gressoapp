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
        guard let firstLaunchDate = defaults.object(forKey: UserDefaultsKey.firstLaunchDate.rawValue) as? Date else { return }
        guard let days = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day else { return }
        let appLaunchCounter = defaults.integer(forKey: UserDefaultsKey.appLaunchCounter.rawValue)
        let shouldRequestReview = appLaunchCounter > 7 && days > 2
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
