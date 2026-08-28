//
//  SunoonApp.swift
//  سنون — التاريخ والراتب والصلاة
//
//  الشاشة الرئيسية للتطبيق. يفرض اتجاه الكتابة من اليمين لليسار
//  لأن كل محتوى التطبيق عربي بغض النظر عن لغة نظام الجهاز.
//  وضع النظام (فاتح/داكن/تلقائي) يُقرأ من إعدادات المستخدم المحفوظة.
//

import SwiftUI

@main
struct SunoonApp: App {
    @State private var settings = SettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView(settings: settings)
                .environment(\.layoutDirection, .rightToLeft)
                .preferredColorScheme(settings.appearanceMode.colorScheme)
        }
    }
}
