//
//  AnalyticsService.swift
//  GRESSO
//
//  Created by Dmitry Koshelev on 19/11/2023.
//

import Adjust
import FirebaseAnalytics

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    func menuTap() {
        Analytics.logEvent("menu_tap", parameters: nil)
        
        let event = ADJEvent(eventToken: "g7dboe")
        Adjust.trackEvent(event)
    }
    
    func tryOnTap() {
        Analytics.logEvent("try_on_tap", parameters: nil)
        
        let event = ADJEvent(eventToken: "q3ojsw")
        Adjust.trackEvent(event)
    }
    
    func photoTap() {
        Analytics.logEvent("take_photo_tap", parameters: nil)
        
        let event = ADJEvent(eventToken: "t24ull")
        Adjust.trackEvent(event)
    }
    
    func shareTap() {
        Analytics.logEvent("share_tap", parameters: nil)
        
        let event = ADJEvent(eventToken: "glhdma")
        Adjust.trackEvent(event)
    }
    
    func sharePhotoTap() {
        Analytics.logEvent("share_photo_tap", parameters: nil)
        
        let event = ADJEvent(eventToken: "tqg6aw")
        Adjust.trackEvent(event)
    }
}
