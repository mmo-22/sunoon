//
//  AppSettingsView.swift
//  شاشة الإعدادات: حول التطبيق ووضع المظهر (تلقائي/فاتح/داكن).
//

import SwiftUI

struct AppSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    private var theme: ThemePalette { Theme.palette(for: colorScheme) }
    @Bindable var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "الإصدار \(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    appearanceSection
                    locationSection
                    aboutSection
                }
                .padding(20)
            }
            .background(theme.backgroundGradient)
            .navigationTitle("الإعدادات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("تم") { dismiss() }
                        .tint(theme.gold)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var locationSection: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("الموقع")
                .font(Theme.display(14))
                .foregroundStyle(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Menu {
                ForEach(SaudiCityCatalog.all) { city in
                    Button(city.name) {
                        settings.updateLocation(latitude: city.latitude, longitude: city.longitude, label: city.name)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11))
                        .foregroundStyle(theme.textMuted)
                    Spacer()
                    Text(settings.locationLabel)
                        .font(Theme.body(13.5, weight: .semibold))
                        .foregroundStyle(theme.textPrimary)
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(theme.gold)
                        .frame(width: 22)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.textPrimary.opacity(0.04))
                )
            }
            .buttonStyle(.plain)

            Text("تُستخدم مدينتك لحساب مواقيت الصلاة بدقة. تقدر أيضًا تحدد موقعك تلقائيًا عبر GPS من زر 📍 في بطاقة الصلاة بالشاشة الرئيسية.")
                .font(Theme.body(10.5))
                .foregroundStyle(theme.textMuted)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(theme.panelGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(theme.divider, lineWidth: 1)
                )
        )
    }

    private var aboutSection: some View {
        VStack(spacing: 14) {
            SunoonLogoMark(size: 60)
                .padding(18)
                .background(
                    Circle()
                        .fill(theme.panelGradient)
                        .overlay(Circle().stroke(theme.divider, lineWidth: 1))
                )

            VStack(spacing: 4) {
                Text("سنون")
                    .font(Theme.display(20, weight: .black))
                    .foregroundStyle(theme.textPrimary)
                Text("التاريخ، الراتب، والصلاة — في تطبيق واحد")
                    .font(Theme.body(12.5))
                    .foregroundStyle(theme.textMuted)
                    .multilineTextAlignment(.center)
                Text(appVersion)
                    .font(Theme.body(11))
                    .foregroundStyle(theme.textMuted)
                    .padding(.top, 4)
            }

            Text("مواقيت الصلاة محسوبة فلكيًا وقد تختلف دقائق قليلة عن مسجد حيّك، والتقويم الهجري باعتماد أم القرى، ومواعيد الرواتب والدعم الحكومي مبنية على أحدث الإعلانات الرسمية وقد تتغيّر.")
                .font(Theme.body(11))
                .foregroundStyle(theme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(theme.panelGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(theme.divider, lineWidth: 1)
                )
        )
    }

    private var appearanceSection: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("وضع التطبيق")
                .font(Theme.display(14))
                .foregroundStyle(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(spacing: 8) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Button {
                        settings.appearanceMode = mode
                    } label: {
                        HStack {
                            Image(systemName: settings.appearanceMode == mode ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(settings.appearanceMode == mode ? theme.tealBright : theme.textMuted)
                            Spacer()
                            Text(mode.label)
                                .font(Theme.body(13.5, weight: settings.appearanceMode == mode ? .semibold : .regular))
                                .foregroundStyle(theme.textPrimary)
                            Image(systemName: mode.systemIcon)
                                .foregroundStyle(theme.gold)
                                .frame(width: 22)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(settings.appearanceMode == mode ? theme.goldSoft : theme.textPrimary.opacity(0.04))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("يغيّر هذا الخيار مظهر التطبيق بالكامل — بطاقاته وعناصر النظام معًا. اختر «تلقائي» ليتبع إعدادات جهازك.")
                .font(Theme.body(10.5))
                .foregroundStyle(theme.textMuted)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
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
