//
//  ContentView.swift
//  الشاشة الرئيسية — تجميع كل البطاقات.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    private var theme: ThemePalette { Theme.palette(for: colorScheme) }
    @Bindable var settings: SettingsStore
    @State private var isSettingsPresented = false

    var body: some View {
        ZStack {
            theme.backgroundGradient
            ScrollView {
                VStack(spacing: 16) {
                    HeaderView(isSettingsPresented: $isSettingsPresented)
                        .padding(.top, 6)
                        .padding(.bottom, 8)

                    PrayerCardView(settings: settings)
                    SalaryCardView(settings: settings)
                    DateConverterView()

                    Text("مواقيت الصلاة محسوبة فلكيًا وقد تختلف دقائق قليلة عن مسجد حيّك · التقويم الهجري باعتماد أم القرى")
                        .font(Theme.body(11))
                        .foregroundStyle(theme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            AppSettingsView(settings: settings)
        }
    }
}

#Preview {
    ContentView(settings: SettingsStore())
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}
