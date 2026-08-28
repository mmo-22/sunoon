//
//  AddIncomeSourceSheet.swift
//  نافذة إضافة مصدر دخل جديد: راتب شخصي (اسم + تقويم لتحديد يوم الصرف)
//  أو دعم حكومي (اختيار من قائمة جاهزة بمواعيد رسمية).
//

import SwiftUI

struct AddIncomeSourceSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    private var theme: ThemePalette { Theme.palette(for: colorScheme) }
    @Bindable var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var mode: Mode = .choose
    @State private var customName: String = ""
    @State private var pickedDate: Date = Date()

    private enum Mode {
        case choose
        case customSalary
        case governmentList
    }

    private var alreadyAddedNames: Set<String> {
        Set(settings.incomeSources.map { $0.name })
    }

    var body: some View {
        NavigationStack {
            Group {
                switch mode {
                case .choose: chooseView
                case .customSalary: customSalaryView
                case .governmentList: governmentListView
                }
            }
            .background(theme.backgroundGradient)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(mode == .choose ? "إلغاء" : "رجوع") {
                        if mode == .choose {
                            dismiss()
                        } else {
                            mode = .choose
                        }
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var title: String {
        switch mode {
        case .choose: return "إضافة مصدر"
        case .customSalary: return "راتب شخصي"
        case .governmentList: return "الدعم الحكومي"
        }
    }

    private var chooseView: some View {
        VStack(spacing: 14) {
            Button {
                pickedDate = Date()
                mode = .customSalary
            } label: {
                choiceRow(
                    icon: "briefcase.fill",
                    title: "راتب شخصي",
                    subtitle: "وظيفة، دوام جزئي، أو أي دخل تحدد يومه بنفسك عبر التقويم"
                )
            }
            .buttonStyle(.plain)

            Button {
                mode = .governmentList
            } label: {
                choiceRow(
                    icon: "building.columns.fill",
                    title: "دعم حكومي",
                    subtitle: "اختر من قائمة جاهزة بمواعيد الصرف الرسمية (حساب المواطن، الضمان، ساند...)"
                )
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(20)
    }

    private func choiceRow(icon: String, title: String, subtitle: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(theme.gold)
                .frame(width: 34)
            VStack(alignment: .trailing, spacing: 3) {
                Text(title)
                    .font(Theme.body(14, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
                Text(subtitle)
                    .font(Theme.body(11.5))
                    .foregroundStyle(theme.textMuted)
                    .multilineTextAlignment(.trailing)
            }
            Spacer()
            Image(systemName: "chevron.left")
                .foregroundStyle(theme.textMuted)
                .font(.system(size: 12))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(theme.panelGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(theme.divider, lineWidth: 1)
                )
        )
    }

    private var customSalaryView: some View {
        VStack(spacing: 18) {
            TextField("اسم المصدر (مثل: راتب الوظيفة)", text: $customName)
                .font(Theme.body(14))
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(theme.textPrimary.opacity(0.06)))
                .multilineTextAlignment(.trailing)
                .foregroundStyle(theme.textPrimary)

            DatePicker("يوم الصرف", selection: $pickedDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .tint(theme.gold)

            Button(action: saveCustomSalary) {
                Text("إضافة")
                    .font(Theme.body(14, weight: .bold))
                    .foregroundStyle(Color(hex: 0x1A1206))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(theme.gold))
            }
            .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(customName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)

            Spacer()
        }
        .padding(20)
    }

    private var governmentListView: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(GovernmentSupportCatalog.all) { template in
                    let added = alreadyAddedNames.contains(template.name)
                    Button {
                        guard !added else { return }
                        addGovernmentSource(template)
                    } label: {
                        VStack(alignment: .trailing, spacing: 6) {
                            HStack {
                                Image(systemName: added ? "checkmark.circle.fill" : "plus.circle")
                                    .foregroundStyle(added ? theme.tealBright : theme.gold)
                                Spacer()
                                Text(template.name)
                                    .font(Theme.body(13.5, weight: .semibold))
                                    .foregroundStyle(theme.textPrimary)
                                Image(systemName: template.systemIcon)
                                    .foregroundStyle(theme.tealBright)
                                    .frame(width: 24)
                            }
                            Text("يوم \(template.dayOfMonth) من كل شهر ميلادي")
                                .font(Theme.body(11.5))
                                .foregroundStyle(theme.gold)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            Text(template.sourceNote)
                                .font(Theme.body(10.5))
                                .foregroundStyle(theme.textMuted)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(theme.panelGradient)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(theme.divider, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(added)
                    .opacity(added ? 0.55 : 1)
                }

                Text("المواعيد مبنية على أحدث الإعلانات الرسمية (وزارة المالية، وزارة الموارد البشرية والتنمية الاجتماعية، التأمينات الاجتماعية) وقد تُقدَّم أو تُؤخَّر يومًا لعطلة نهاية الأسبوع — راجع القنوات الرسمية للتأكد كل شهر")
                    .font(Theme.body(10.5))
                    .foregroundStyle(theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
            }
            .padding(16)
        }
    }

    private func saveCustomSalary() {
        let day = Calendar.current.component(.day, from: pickedDate)
        let name = customName.trimmingCharacters(in: .whitespaces)
        settings.addIncomeSource(
            IncomeSource(name: name, dayOfMonth: day, kind: .personalSalary, sourceNote: nil, systemIcon: "briefcase.fill")
        )
        dismiss()
    }

    private func addGovernmentSource(_ template: GovernmentSupportTemplate) {
        settings.addIncomeSource(
            IncomeSource(
                name: template.name,
                dayOfMonth: template.dayOfMonth,
                kind: .governmentSupport,
                sourceNote: template.sourceNote,
                systemIcon: template.systemIcon
            )
        )
    }
}
