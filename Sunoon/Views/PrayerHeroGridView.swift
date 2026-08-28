//
//  PrayerHeroGridView.swift
//  عرض مواقيت الصلاة: بطاقة كبيرة بارزة للصلاة القادمة مع عداد تنازلي
//  حي بجانبها، وتحتها شبكة مربعات صغيرة لباقي المواقيت الخمسة.
//

import SwiftUI

struct PrayerHeroGridView: View {
    @Environment(\.colorScheme) private var colorScheme
    private var theme: ThemePalette { Theme.palette(for: colorScheme) }
    let times: PrayerTimes
    let now: Date
    let nextKey: PrayerKey
    let countdownText: String

    private var remainingKeys: [PrayerKey] {
        PrayerKey.allCases.filter { $0 != nextKey }
    }

    private var nowHours: Double {
        PrayerTimesCalculator.decimalHours(from: now, calendar: Calendar.current)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            heroCard

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                spacing: 8
            ) {
                ForEach(remainingKeys, id: \.self) { key in
                    smallTile(for: key)
                }
            }
        }
    }

    private var heroCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: icon(for: nextKey))
                        .font(.system(size: 13, weight: .medium))
                    Text("الصلاة القادمة")
                        .font(Theme.body(12.5, weight: .medium))
                }
                .foregroundStyle(theme.tealBright)

                Text(countdownText)
                    .font(Theme.mono(27, weight: .bold))
                    .foregroundStyle(theme.textPrimary)
                    .monospacedDigit()

                HStack(spacing: 8) {
                    Text(nextKey.arabicLabel)
                        .font(Theme.display(16))
                        .foregroundStyle(theme.gold)
                    Text(PrayerTimesCalculator.timeString(times[nextKey]))
                        .font(Theme.mono(13, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.tealBright.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(theme.tealBright.opacity(0.35), lineWidth: 1)
                )
        )
    }

    private func smallTile(for key: PrayerKey) -> some View {
        let isDone = times[key] <= nowHours
        return VStack(spacing: 6) {
            Image(systemName: icon(for: key))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(theme.gold)
            Text(key.arabicLabel)
                .font(Theme.body(12, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
            Text(PrayerTimesCalculator.timeString(times[key]))
                .font(Theme.mono(10.5, weight: .medium))
                .foregroundStyle(theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(theme.textPrimary.opacity(0.025))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(theme.divider, lineWidth: 1)
                )
        )
        .opacity(isDone ? 0.5 : 1)
    }

    private func icon(for key: PrayerKey) -> String {
        switch key {
        case .fajr: return "moon.stars.fill"
        case .sunrise: return "sunrise.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.min.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.fill"
        }
    }
}
