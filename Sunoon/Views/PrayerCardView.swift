//
//  PrayerCardView.swift
//  بطاقة مواقيت الصلاة: تعرض القوس + عداد تنازلي حي للصلاة القادمة.
//

import SwiftUI
import CoreLocation

struct PrayerCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    private var theme: ThemePalette { Theme.palette(for: colorScheme) }
    @Bindable var settings: SettingsStore
    @State private var locationService = LocationService()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: requestLocation) {
                    HStack(spacing: 5) {
                        Text(locationService.isRequesting ? "جارٍ التحديد..." : settings.locationLabel)
                        Text("📍")
                    }
                    .font(Theme.body(12))
                    .foregroundStyle(theme.textMuted)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(theme.textPrimary.opacity(0.06)))
                }
                Spacer()
                Text("مواقيت الصلاة")
                    .font(Theme.display(15))
                    .foregroundStyle(theme.textPrimary)
            }
            .padding(.bottom, 16)

            TimelineView(.periodic(from: .now, by: 1)) { context in
                let now = context.date
                let calendar = Calendar.current
                let comps = calendar.dateComponents([.year, .month, .day], from: now)
                let times = PrayerTimesCalculator.calculate(
                    year: comps.year ?? 2026, month: comps.month ?? 1, day: comps.day ?? 1,
                    latitude: settings.latitude, longitude: settings.longitude,
                    timeZoneOffsetHours: Double(TimeZone.current.secondsFromGMT(for: now)) / 3600
                )

                let nextKey = nextPrayerKey(times: times, now: now, calendar: calendar)
                let countdown = countdownString(to: nextKey, times: times, now: now, calendar: calendar,
                                                  latitude: settings.latitude, longitude: settings.longitude)

                PrayerHeroGridView(times: times, now: now, nextKey: nextKey, countdownText: countdown)
            }
        }
        .cardStyle()
        .onAppear {
            locationService.onLocationResolved = { coord in
                settings.updateLocation(latitude: coord.latitude, longitude: coord.longitude, label: "موقعي الحالي")
            }
        }
    }

    private func requestLocation() {
        locationService.requestOnce()
    }

    private func nextPrayerKey(times: PrayerTimes, now: Date, calendar: Calendar) -> PrayerKey {
        let nowH = PrayerTimesCalculator.decimalHours(from: now, calendar: calendar)
        for key in PrayerKey.nextPrayerCandidates where times[key] > nowH {
            return key
        }
        return .fajr
    }

    private func countdownString(to key: PrayerKey, times: PrayerTimes, now: Date, calendar: Calendar,
                                   latitude: Double, longitude: Double) -> String {
        let nowH = PrayerTimesCalculator.decimalHours(from: now, calendar: calendar)
        var target = times[key]
        if target <= nowH {
            // فجر الغد: نحسبه بنفس الإحداثيات ليوم الغد
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
            let tc = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            let tt = PrayerTimesCalculator.calculate(
                year: tc.year ?? 2026, month: tc.month ?? 1, day: tc.day ?? 1,
                latitude: latitude, longitude: longitude,
                timeZoneOffsetHours: Double(TimeZone.current.secondsFromGMT(for: tomorrow)) / 3600
            )
            target = tt.fajr + 24
        }
        var diff = target - nowH
        if diff < 0 { diff += 24 }
        let totalSeconds = Int((diff * 3600).rounded())
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
