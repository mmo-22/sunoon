//
//  HeaderView.swift
//  زر الإعدادات أعلى الشاشة، ثم التحية والتاريخ اليوم (هجري وميلادي).
//

import SwiftUI

struct HeaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    private var theme: ThemePalette { Theme.palette(for: colorScheme) }
    @Binding var isSettingsPresented: Bool

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let now = context.date

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Button(action: { isSettingsPresented = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(theme.textMuted)
                            .padding(8)
                            .background(Circle().fill(theme.textPrimary.opacity(0.06)))
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .overlay(
                    Text("سنون")
                        .font(Theme.display(13, weight: .black))
                        .foregroundStyle(theme.gold)
                        .tracking(2)
                )

                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(greeting(for: now))
                            .font(Theme.display(23, weight: .black))
                            .foregroundStyle(theme.textPrimary)

                        Text(AdhkarProvider.text(for: now))
                            .font(Theme.body(11.5))
                            .foregroundStyle(theme.gold)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(theme.goldSoft))
                    }
                    .frame(maxWidth: 190, alignment: .leading)

                    Spacer(minLength: 0)

                    DateTicketCard()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func greeting(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        if hour < 12 { return "صباح الخير ☀️" }
        if hour < 17 { return "مساء الخير 🌤️" }
        return "مساء النور 🌙"
    }
}
