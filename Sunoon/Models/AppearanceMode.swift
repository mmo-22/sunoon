//
//  AppearanceMode.swift
//  وضع مظهر النظام (تلقائي/فاتح/داكن) — يتحكم بعناصر النظام مثل التقويم
//  والقوائم وشريط الحالة. تصميم بطاقات سنون نفسه داكن ثابت دائمًا.
//

import SwiftUI

enum AppearanceMode: String, CaseIterable, Codable, Equatable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var label: String {
        switch self {
        case .system: return "تلقائي (حسب الجهاز)"
        case .light: return "فاتح"
        case .dark: return "داكن"
        }
    }

    var systemIcon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
