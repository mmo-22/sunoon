//
//  DateConverterView.swift
//  محوّل التاريخ بين الميلادي والهجري.
//

import SwiftUI

private enum ConverterMode {
    case gregorianToHijri
    case hijriToGregorian
}

struct DateConverterView: View {
    @Environment(\.colorScheme) private var colorScheme
    private var theme: ThemePalette { Theme.palette(for: colorScheme) }
    @State private var mode: ConverterMode = .gregorianToHijri
    @State private var day: Int
    @State private var month: Int
    @State private var year: Int

    init() {
        let g = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        _day = State(initialValue: g.day ?? 1)
        _month = State(initialValue: g.month ?? 1)
        _year = State(initialValue: g.year ?? 2026)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("محوّل التاريخ")
                .font(Theme.display(15))
                .foregroundStyle(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 3) {
                segmentButton("هجري ← ميلادي", isOn: mode == .hijriToGregorian) {
                    switchMode(to: .hijriToGregorian)
                }
                segmentButton("ميلادي ← هجري", isOn: mode == .gregorianToHijri) {
                    switchMode(to: .gregorianToHijri)
                }
            }
            .padding(3)
            .background(Capsule().fill(theme.textPrimary.opacity(0.06)))

            HStack(spacing: 8) {
                Picker("يوم", selection: $day) {
                    ForEach(1...30, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.menu).tint(theme.textPrimary)

                Picker("شهر", selection: $month) {
                    ForEach(1...12, id: \.self) { m in
                        Text(monthNames[m - 1]).tag(m)
                    }
                }
                .pickerStyle(.menu).tint(theme.textPrimary)

                Picker("سنة", selection: $year) {
                    ForEach((year - 3)...(year + 3), id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.menu).tint(theme.textPrimary)
            }
            .font(Theme.mono(13))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 12).fill(theme.textPrimary.opacity(0.06)))

            resultView
        }
        .cardStyle()
    }

    private var monthNames: [String] {
        mode == .gregorianToHijri ? HijriCalendarService.gregorianMonthNames : HijriCalendarService.hijriMonthNames
    }

    private func switchMode(to newMode: ConverterMode) {
        mode = newMode
        let today = Date()
        if newMode == .gregorianToHijri {
            let g = Calendar.current.dateComponents([.day, .month, .year], from: today)
            day = g.day ?? 1; month = g.month ?? 1; year = g.year ?? 2026
        } else {
            let h = HijriCalendarService.toHijri(today)
            day = h.day; month = h.month; year = h.year
        }
    }

    @ViewBuilder
    private var resultView: some View {
        Group {
            switch mode {
            case .gregorianToHijri:
                if let date = gregorianDate(day: day, month: month, year: year) {
                    let h = HijriCalendarService.toHijri(date)
                    resultBox(
                        main: HijriCalendarService.hijriString(h),
                        sub: "يوافقه \(HijriCalendarService.weekdayName(for: date))، \(day) \(HijriCalendarService.gregorianMonthNames[month - 1]) \(year)م"
                    )
                } else {
                    resultBox(main: "تاريخ غير صحيح", sub: nil)
                }
            case .hijriToGregorian:
                if let date = HijriCalendarService.toGregorian(day: day, month: month, year: year) {
                    resultBox(
                        main: HijriCalendarService.gregorianString(date),
                        sub: "يوافقه \(HijriCalendarService.weekdayName(for: date)) — \(day) \(HijriCalendarService.hijriMonthNames[month - 1]) \(year)هـ"
                    )
                } else {
                    resultBox(main: "تعذّر التحويل، جرّب تاريخًا آخر", sub: nil)
                }
            }
        }
    }

    private func gregorianDate(day: Int, month: Int, year: Int) -> Date? {
        var comps = DateComponents()
        comps.day = day; comps.month = month; comps.year = year
        let cal = Calendar(identifier: .gregorian)
        guard let date = cal.date(from: comps) else { return nil }
        // تحقق أن اليوم صالح فعليًا لهذا الشهر (مثل رفض 31 فبراير)
        let check = cal.dateComponents([.day, .month, .year], from: date)
        guard check.day == day, check.month == month, check.year == year else { return nil }
        return date
    }

    private func resultBox(main: String, sub: String?) -> some View {
        VStack(spacing: 4) {
            Text(main)
                .font(Theme.display(16))
                .foregroundStyle(theme.gold)
            if let sub {
                Text(sub)
                    .font(Theme.body(12))
                    .foregroundStyle(theme.textMuted)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(theme.goldSoft)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(theme.gold, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                )
        )
    }

    private func segmentButton(_ title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.body(13, weight: isOn ? .bold : .medium))
                .foregroundStyle(isOn ? Color(hex: 0x1A1206) : theme.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .fill(isOn ? theme.gold : .clear)
                )
        }
    }
}
