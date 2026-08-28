//
//  DateTicketCard.swift
//  بطاقة تاريخ صغيرة بشكل "تذكرة": اسم اليوم بخط زخرفي أعلاها، وتحته
//  التاريخ الميلادي والهجري في عمودين يفصل بينهما خط متقطع.
//  تظهر بجانب نص الترحيب أعلى الشاشة مباشرة (وليست بطاقة مستقلة).
//

import SwiftUI

struct DateTicketCard: View {
    @Environment(\.colorScheme) private var colorScheme
    private var theme: ThemePalette { Theme.palette(for: colorScheme) }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let now = context.date
            let calendar = Calendar.current
            let g = calendar.dateComponents([.day, .month, .year], from: now)
            let h = HijriCalendarService.toHijri(now)

            VStack(spacing: 10) {
                Text(HijriCalendarService.weekdayName(for: now))
                    .font(.custom("Mishafi", size: 36))
                    .foregroundStyle(theme.tealBright)

                HStack(spacing: 8) {
                    stub(
                        label: "ميلادي",
                        day: g.day ?? 1,
                        sub: HijriCalendarService.gregorianMonthNames[(g.month ?? 1) - 1]
                    )

                    dashedDivider

                    stub(
                        label: "هجري",
                        day: h.day,
                        sub: HijriCalendarService.hijriMonthNames[h.month - 1]
                    )
                }
            }
            .padding(14)
            .frame(width: 152)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(theme.panelGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(theme.divider, lineWidth: 1)
                    )
            )
        }
    }

    private var dashedDivider: some View {
        VStack(spacing: 3) {
            ForEach(0..<8, id: \.self) { _ in
                Rectangle().fill(theme.divider).frame(width: 1, height: 4)
            }
        }
    }

    private func stub(label: String, day: Int, sub: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(Theme.body(9))
                .foregroundStyle(theme.textMuted)
            Text("\(day)")
                .font(Theme.mono(20, weight: .bold))
                .foregroundStyle(theme.textPrimary)
            Text(sub)
                .font(Theme.body(9))
                .foregroundStyle(theme.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity)
    }
}
