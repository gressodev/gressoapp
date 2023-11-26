//
//  AnalyticsService.swift
//  GRESSO
//
//  Created by Dmitry Koshelev on 19/11/2023.
//

import FirebaseAnalytics

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    func menuTap() {
        Analytics.logEvent("menu_tap", parameters: nil)
    }
    
    func tryOnTap() {
        Analytics.logEvent("try_on_tap", parameters: nil)
    }
    
    func photoTap() {
        Analytics.logEvent("take_photo_tap", parameters: nil)
    }
    
    func shareTap() {
        Analytics.logEvent("share_tap", parameters: nil)
    }
    
    func sharePhotoTap() {
        Analytics.logEvent("share_photo_tap", parameters: nil)
    }
}
