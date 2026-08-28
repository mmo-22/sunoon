//
//  SalaryShareCardView.swift
//  نسخة مخصّصة للمشاركة من بطاقة الرواتب والدعم — نفس المحتوى والتصميم،
//  لكن بتذييل يحمل شعار سنون واسم التطبيق، لاستخدامها كصورة تُشارَك.
//  تُصيَّر عبر ImageRenderer داخل SalaryCardView ولا تُعرض مباشرة في الشاشة.
//

import SwiftUI

struct SalaryShareCardView: View {
    let sources: [IncomeSource]
    var generatedDate: Date = Date()
    // بطاقة المشاركة تبقى دائمًا بالمظهر الداكن الأساسي بغض النظر عن
    // "وضع التطبيق" الذي اختاره المستخدم — لأن الصورة تُشارَك مع آخرين
    // ويجب أن تبدو متسقة بعلامة سنون التجارية دائمًا.
    private let theme = ThemePalette.dark

    private var salarySources: [IncomeSource] { sources.filter { $0.kind == .personalSalary } }
    private var supportSources: [IncomeSource] { sources.filter { $0.kind == .governmentSupport } }

    private var nearest: (source: IncomeSource, status: SalaryStatus)? {
        sources
            .map { ($0, SalaryScheduler.status(paydayOfMonth: $0.dayOfMonth)) }
            .min { $0.1.daysLeft < $1.1.daysLeft }
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 14) {
            Text("الرواتب والدعم")
                .font(Theme.display(16))
                .foregroundStyle(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)

            if let nearest {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("القادم: \(nearest.source.name)")
                        .font(Theme.body(12.5))
                        .foregroundStyle(theme.textMuted)
                    Text(formattedPayday(nearest.status.nextPayday))
                        .font(Theme.display(19))
                        .foregroundStyle(theme.gold)
                    Text("باقي \(nearest.status.daysLeft) يوم")
                        .font(Theme.mono(15, weight: .semibold))
                        .foregroundStyle(theme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                Divider().background(theme.divider)
            }

            if !salarySources.isEmpty {
                sectionLabel("رواتبي")
                ForEach(salarySources) { row($0) }
            }
            if !supportSources.isEmpty {
                sectionLabel("الدعم الحكومي")
                ForEach(supportSources) { row($0) }
            }

            Divider().background(theme.divider)

            HStack {
                Text(formattedGeneratedDate)
                    .font(Theme.body(9.5))
                    .foregroundStyle(theme.textMuted)
                Spacer()
                HStack(spacing: 6) {
                    Text("سنون")
                        .font(Theme.display(13, weight: .black))
                        .foregroundStyle(theme.gold)
                        .tracking(1.5)
                    SunoonLogoMark(size: 20, trunkColor: theme.gold, frondColor: theme.textPrimary)
                }
            }
        }
        .padding(20)
        .frame(width: 360)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(theme.panelGradient)
        )
        .background(
            ZStack {
                theme.bgDeep
                RadialGradient(colors: [theme.tealBright.opacity(0.10), .clear],
                                center: UnitPoint(x: 0.15, y: -0.05), startRadius: 10, endRadius: 420)
                RadialGradient(colors: [theme.gold.opacity(0.10), .clear],
                                center: UnitPoint(x: 1.0, y: 0.0), startRadius: 10, endRadius: 360)
            }
        )
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.body(11))
            .foregroundStyle(theme.textMuted)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func row(_ source: IncomeSource) -> some View {
        let status = SalaryScheduler.status(paydayOfMonth: source.dayOfMonth)
        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(status.daysLeft)")
                    .font(Theme.mono(14, weight: .bold))
                    .foregroundStyle(theme.gold)
                Text("يوم")
                    .font(Theme.body(9))
                    .foregroundStyle(theme.textMuted)
            }
            .frame(width: 36, alignment: .leading)

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text(source.name)
                    .font(Theme.body(12.5, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
                Text("يوم \(source.dayOfMonth) من كل شهر")
                    .font(Theme.body(10))
                    .foregroundStyle(theme.textMuted)
            }

            Image(systemName: source.systemIcon)
                .foregroundStyle(source.kind == .governmentSupport ? theme.tealBright : theme.gold)
                .frame(width: 18)
        }
    }

    private func formattedPayday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }

    private var formattedGeneratedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: generatedDate)
    }
}
