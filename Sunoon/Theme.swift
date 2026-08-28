//
//  Theme.swift
//  ألوان وأنماط الخط المستخدمة في كل التطبيق — بنسختين (داكن وفاتح)
//  يُختار بينهما حسب "وضع التطبيق" في الإعدادات (أو حسب النظام تلقائيًا).
//

import SwiftUI

extension Color {
    /// إنشاء لون من قيمة hex مثل 0x0B1E22
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, opacity: opacity)
    }
}

/// مجموعة الألوان الكاملة لمظهر واحد (داكن أو فاتح).
struct ThemePalette {
    let bgDeep: Color
    let bgPanel: Color
    let bgPanel2: Color
    let gold: Color
    let goldSoft: Color
    let tealBright: Color
    let textPrimary: Color
    let textMuted: Color
    let divider: Color

    var panelGradient: LinearGradient {
        LinearGradient(colors: [bgPanel, bgPanel2], startPoint: .top, endPoint: .bottom)
    }

    var backgroundGradient: some View {
        ZStack {
            bgDeep
            RadialGradient(colors: [tealBright.opacity(0.10), .clear],
                            center: UnitPoint(x: 0.15, y: -0.05), startRadius: 10, endRadius: 420)
            RadialGradient(colors: [gold.opacity(0.10), .clear],
                            center: UnitPoint(x: 1.0, y: 0.0), startRadius: 10, endRadius: 360)
        }
        .ignoresSafeArea()
    }

    static let dark = ThemePalette(
        bgDeep: Color(hex: 0x0B1E22),
        bgPanel: Color(hex: 0x122F34),
        bgPanel2: Color(hex: 0x183940),
        gold: Color(hex: 0xC9A25E),
        goldSoft: Color(hex: 0xC9A25E, opacity: 0.16),
        tealBright: Color(hex: 0x57D9C7),
        textPrimary: Color(hex: 0xF4EEDD),
        textMuted: Color(hex: 0x8FB0AC),
        divider: Color(hex: 0xF4EEDD, opacity: 0.09)
    )

    static let light = ThemePalette(
        bgDeep: Color(hex: 0xF6F1E6),
        bgPanel: Color(hex: 0xFFFFFF),
        bgPanel2: Color(hex: 0xF1E8D6),
        gold: Color(hex: 0xA9762B),
        goldSoft: Color(hex: 0xA9762B, opacity: 0.14),
        tealBright: Color(hex: 0x11897B),
        textPrimary: Color(hex: 0x1D2B29),
        textMuted: Color(hex: 0x5E706C),
        divider: Color(hex: 0x1D2B29, opacity: 0.08)
    )
}

enum Theme {
    /// يُرجع لوحة الألوان المناسبة حسب مظهر النظام الحالي (فاتح/داكن).
    static func palette(for colorScheme: ColorScheme) -> ThemePalette {
        colorScheme == .light ? .light : .dark
    }

    // خطوط بتصميم دائري (rounded) تعطي طابعًا مميزًا يشبه Cairo/Tajawal في النسخة الأصلية
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func mono(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

/// نمط بطاقة موحّد لكل أقسام التطبيق — يتكيّف تلقائيًا مع وضع النظام الحالي.
struct CardBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let theme = Theme.palette(for: colorScheme)
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(theme.panelGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(theme.divider, lineWidth: 1)
                    )
            )
    }
}
extension View {
    func cardStyle() -> some View { modifier(CardBackground()) }
}
