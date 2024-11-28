//
//  RegionService.swift
//  GRESSO
//
//  Created by Dmitrii on 24.11.2024.
//

import Foundation

final class RegionService {
    static let shared = RegionService()

    private let regionKey = "selectedRegionCode"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if getRegionCode() == nil {
            setRegionCodeToDeviceDefault()
        }
    }
    
    /// Возвращает текущий сохранённый код региона.
    func getRegionCode() -> String? {
        return userDefaults.string(forKey: regionKey)
    }
    
    /// Устанавливает код региона, выбранный пользователем.
    func setRegionCode(_ code: String) {
        userDefaults.set(code, forKey: regionKey)
    }
    
    /// Сбрасывает код региона на значение по умолчанию (код региона мобильного устройства).
    func resetRegionCodeToDefault() {
        setRegionCodeToDeviceDefault()
    }
    
    /// Получение и установка кода региона мобильного устройства как значение по умолчанию.
    private func setRegionCodeToDeviceDefault() {
        let regionCode = Locale.current.regionCode
        userDefaults.set(regionCode, forKey: regionKey)
    }
}
