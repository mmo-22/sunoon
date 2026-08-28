//
//  SalaryCardView.swift
//  بطاقة الرواتب والدعم: أقرب موعد صرف قادم بارزًا أعلى البطاقة،
//  وتحتها كل مصادر الدخل مقسّمة إلى رواتب شخصية ودعم حكومي.
//  فيها أيضًا زر مشاركة يُصدّر البطاقة كصورة تحمل شعار سنون واسمه.
//

import SwiftUI

struct SalaryCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    private var theme: ThemePalette { Theme.palette(for: colorScheme) }
    @Bindable var settings: SettingsStore
    @State private var isAddSheetPresented = false
    @State private var shareImage: Image?

    private var salarySources: [IncomeSource] {
        settings.incomeSources.filter { $0.kind == .personalSalary }
    }

    private var supportSources: [IncomeSource] {
        settings.incomeSources.filter { $0.kind == .governmentSupport }
    }

    private var nearest: (source: IncomeSource, status: SalaryStatus)? {
        settings.incomeSources
            .map { ($0, SalaryScheduler.status(paydayOfMonth: $0.dayOfMonth)) }
            .min { $0.1.daysLeft < $1.1.daysLeft }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if let nearest {
                heroSection(nearest)
                Divider().background(theme.divider).padding(.vertical, 14)
            }

            if settings.incomeSources.isEmpty {
                emptyState
            } else {
                if !salarySources.isEmpty {
                    sectionLabel("رواتبي")
                    sourcesView(salarySources)
                }
                if !supportSources.isEmpty {
                    sectionLabel("الدعم الحكومي")
                    sourcesView(supportSources)
                }
            }
        }
        .cardStyle()
        .sheet(isPresented: $isAddSheetPresented) {
            AddIncomeSourceSheet(settings: settings)
        }
        .task(id: settings.incomeSources) {
            generateShareImage()
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                displayStyleToggle

                Button(action: { isAddSheetPresented = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.gold)
                        .padding(7)
                        .background(Circle().fill(theme.goldSoft))
                }
                .buttonStyle(.plain)

                if let shareImage {
                    ShareLink(
                        item: shareImage,
                        preview: SharePreview("بطاقة الرواتب والدعم — سنون", image: shareImage)
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12.5))
                            .foregroundStyle(theme.textMuted)
                            .padding(7)
                            .background(Circle().fill(theme.textPrimary.opacity(0.06)))
                    }
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text("الرواتب والدعم")
                    .font(Theme.display(15))
                    .foregroundStyle(theme.textPrimary)
                Text(settings.incomeSources.isEmpty ? "لا يوجد مصادر بعد" : "\(settings.incomeSources.count) مصدر")
                    .font(Theme.body(12))
                    .foregroundStyle(theme.textMuted)
            }
        }
        .padding(.bottom, 16)
    }

    private func heroSection(_ nearest: (source: IncomeSource, status: SalaryStatus)) -> some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("القادم: \(nearest.source.name)")
                    .font(Theme.body(12.5))
                    .foregroundStyle(theme.textMuted)
                Text(formattedPayday(nearest.status.nextPayday))
                    .font(Theme.display(15))
                    .foregroundStyle(theme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .stroke(theme.divider, lineWidth: 9)
                Circle()
                    .trim(from: 0, to: nearest.status.progress)
                    .stroke(theme.gold, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: nearest.status.progress)
                VStack(spacing: 2) {
                    Text("\(nearest.status.daysLeft)")
                        .font(Theme.mono(24))
                        .foregroundStyle(theme.textPrimary)
                    Text("يوم")
                        .font(Theme.body(10.5))
                        .foregroundStyle(theme.textMuted)
                }
            }
            .frame(width: 100, height: 100)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        HStack(spacing: 6) {
            Rectangle().fill(theme.divider).frame(height: 1)
            Text(text)
                .font(Theme.body(11.5))
                .foregroundStyle(theme.textMuted)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private func sourceRow(_ source: IncomeSource) -> some View {
        let status = SalaryScheduler.status(paydayOfMonth: source.dayOfMonth)
        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 1) {
                Text("\(status.daysLeft)")
                    .font(Theme.mono(15, weight: .bold))
                    .foregroundStyle(theme.gold)
                Text("يوم")
                    .font(Theme.body(9.5))
                    .foregroundStyle(theme.textMuted)
            }
            .frame(width: 42, alignment: .leading)

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(source.name)
                    .font(Theme.body(13, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
                Text("يوم \(source.dayOfMonth) من كل شهر")
                    .font(Theme.body(10.5))
                    .foregroundStyle(theme.textMuted)
            }

            Image(systemName: source.systemIcon)
                .foregroundStyle(source.kind == .governmentSupport ? theme.tealBright : theme.gold)
                .frame(width: 24)
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 10)
        .background(RoundedRectangle(cornerRadius: 12).fill(theme.textPrimary.opacity(0.04)))
        .padding(.bottom, 6)
        .contextMenu {
            Button(role: .destructive) {
                settings.removeIncomeSource(source)
            } label: {
                Label("حذف", systemImage: "trash")
            }
        }
    }

    private var displayStyleToggle: some View {
        HStack(spacing: 4) {
            ForEach(IncomeDisplayStyle.allCases, id: \.self) { style in
                Button {
                    settings.incomeDisplayStyle = style
                } label: {
                    Image(systemName: style.systemIcon)
                        .font(.system(size: 12))
                        .foregroundStyle(settings.incomeDisplayStyle == style ? theme.gold : theme.textMuted)
                        .padding(7)
                        .background(
                            Circle().fill(settings.incomeDisplayStyle == style ? theme.goldSoft : theme.textPrimary.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func sourcesView(_ items: [IncomeSource]) -> some View {
        switch settings.incomeDisplayStyle {
        case .list:
            ForEach(items) { sourceRow($0) }
        case .grid:
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible())], spacing: 8) {
                ForEach(items) { gridCell($0) }
            }
            .padding(.bottom, 6)
        }
    }

    private func gridCell(_ source: IncomeSource) -> some View {
        let status = SalaryScheduler.status(paydayOfMonth: source.dayOfMonth)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: source.systemIcon)
                    .foregroundStyle(source.kind == .governmentSupport ? theme.tealBright : theme.gold)
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(status.daysLeft)")
                        .font(Theme.mono(16, weight: .bold))
                        .foregroundStyle(theme.gold)
                    Text("يوم")
                        .font(Theme.body(9))
                        .foregroundStyle(theme.textMuted)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(source.name)
                    .font(Theme.body(12, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text("يوم \(source.dayOfMonth)")
                    .font(Theme.body(10))
                    .foregroundStyle(theme.textMuted)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(theme.textPrimary.opacity(0.04)))
        .contextMenu {
            Button(role: .destructive) {
                settings.removeIncomeSource(source)
            } label: {
                Label("حذف", systemImage: "trash")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "banknote")
                .font(.system(size: 26))
                .foregroundStyle(theme.textMuted)
            Text("ما أضفت أي راتب أو دعم بعد")
                .font(Theme.body(13))
                .foregroundStyle(theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private func generateShareImage() {
        let renderer = ImageRenderer(content:
            SalaryShareCardView(sources: settings.incomeSources)
                .environment(\.layoutDirection, .rightToLeft)
        )
        renderer.scale = 3
        if let cgImage = renderer.cgImage {
            shareImage = Image(decorative: cgImage, scale: 3, orientation: .up)
        }
    }

    private func formattedPayday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
}
