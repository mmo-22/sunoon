//
//  SettingsStore.swift
//  حفظ إعدادات المستخدم (مصادر الدخل والدعم، الموقع، ووضع المظهر) محليًا عبر UserDefaults.
//

import Foundation
import Observation

@Observable
final class SettingsStore {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let payday = "sunoon.paydayOfMonth"          // مفتاح قديم، يُستخدم للترحيل فقط
        static let incomeSources = "sunoon.incomeSources"
        static let lat = "sunoon.savedLat"
        static let lon = "sunoon.savedLon"
        static let label = "sunoon.savedLabel"
        static let appearanceMode = "sunoon.appearanceMode"
        static let incomeDisplayStyle = "sunoon.incomeDisplayStyle"
    }

    var incomeSources: [IncomeSource] {
        didSet { saveIncomeSources() }
    }

    var locationLabel: String {
        didSet { defaults.set(locationLabel, forKey: Keys.label) }
    }

    var latitude: Double {
        didSet { defaults.set(latitude, forKey: Keys.lat) }
    }

    var longitude: Double {
        didSet { defaults.set(longitude, forKey: Keys.lon) }
    }

    var appearanceMode: AppearanceMode {
        didSet { defaults.set(appearanceMode.rawValue, forKey: Keys.appearanceMode) }
    }

    var incomeDisplayStyle: IncomeDisplayStyle {
        didSet { defaults.set(incomeDisplayStyle.rawValue, forKey: Keys.incomeDisplayStyle) }
    }

    // إحداثيات الدمّام كموقع افتراضي حتى يوافق المستخدم على مشاركة الموقع
    static let defaultLatitude = 26.4207
    static let defaultLongitude = 50.0888
    static let defaultLabel = "دمّام"

    init() {
        let savedLat = defaults.object(forKey: Keys.lat) as? Double
        let savedLon = defaults.object(forKey: Keys.lon) as? Double
        self.latitude = savedLat ?? Self.defaultLatitude
        self.longitude = savedLon ?? Self.defaultLongitude
        self.locationLabel = defaults.string(forKey: Keys.label) ?? Self.defaultLabel

        let savedMode = defaults.string(forKey: Keys.appearanceMode).flatMap { AppearanceMode(rawValue: $0) }
        self.appearanceMode = savedMode ?? .dark

        let savedDisplayStyle = defaults.string(forKey: Keys.incomeDisplayStyle).flatMap { IncomeDisplayStyle(rawValue: $0) }
        self.incomeDisplayStyle = savedDisplayStyle ?? .list

        if let data = defaults.data(forKey: Keys.incomeSources),
           let decoded = try? JSONDecoder().decode([IncomeSource].self, from: data) {
            self.incomeSources = decoded
        } else if let oldPayday = defaults.object(forKey: Keys.payday) as? Int {
            // ترحيل من النسخة القديمة (يوم صرف واحد فقط) إلى مصدر دخل باسم "راتبي"
            self.incomeSources = [
                IncomeSource(name: "راتبي", dayOfMonth: oldPayday, kind: .personalSalary, sourceNote: nil, systemIcon: "briefcase.fill")
            ]
        } else {
            self.incomeSources = [
                IncomeSource(name: "راتبي", dayOfMonth: 27, kind: .personalSalary, sourceNote: nil, systemIcon: "briefcase.fill")
            ]
        }
    }

    private func saveIncomeSources() {
        if let data = try? JSONEncoder().encode(incomeSources) {
            defaults.set(data, forKey: Keys.incomeSources)
        }
    }

    func addIncomeSource(_ source: IncomeSource) {
        incomeSources.append(source)
    }

    func removeIncomeSource(_ source: IncomeSource) {
        incomeSources.removeAll { $0.id == source.id }
    }

    func updateLocation(latitude: Double, longitude: Double, label: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.locationLabel = label
    }
}
