//
//  GovernmentSupportCatalog.swift
//  قائمة جاهزة بجهات الدعم الحكومي والرواتب الرسمية السعودية الشائعة،
//  مع يوم الصرف المعتمد من كل جهة استنادًا لأحدث الإعلانات الرسمية
//  (وزارة المالية، وزارة الموارد البشرية والتنمية الاجتماعية، التأمينات
//  الاجتماعية GOSI). آخر مراجعة: أغسطس 2026.
//
//  ملاحظة: بعض الجهات تُقدّم أو تؤخّر الصرف يومًا أو يومين إذا صادف
//  يوم الصرف عطلة نهاية الأسبوع (الجمعة/السبت) — موضّح في sourceNote لكل جهة.
//

import Foundation

struct GovernmentSupportTemplate: Identifiable {
    var id: String { name }
    var name: String
    var dayOfMonth: Int
    var systemIcon: String
    var sourceNote: String
}

enum GovernmentSupportCatalog {
    static let all: [GovernmentSupportTemplate] = [
        GovernmentSupportTemplate(
            name: "حساب المواطن",
            dayOfMonth: 10,
            systemIcon: "person.crop.circle.badge.checkmark",
            sourceNote: "يُصرف في اليوم العاشر من كل شهر ميلادي، وقد يُقدَّم يومًا إذا صادف عطلة نهاية الأسبوع — حسب منصة حساب المواطن الرسمية"
        ),
        GovernmentSupportTemplate(
            name: "رواتب موظفي الدولة",
            dayOfMonth: 27,
            systemIcon: "building.columns",
            sourceNote: "تُصرف في اليوم 27 من الشهر الميلادي حسب جدول وزارة المالية الرسمي لعام 2026 — يُقدَّم للخميس إن وافق جمعة، ويُؤخَّر للأحد إن وافق سبتًا"
        ),
        GovernmentSupportTemplate(
            name: "رواتب المتقاعدين (التأمينات)",
            dayOfMonth: 1,
            systemIcon: "figure.and.child.holdinghands",
            sourceNote: "وحّدت المؤسسة العامة للتأمينات الاجتماعية (GOSI) صرف معاشات التقاعد في اليوم الأول من كل شهر ميلادي مقدّمًا، ابتداءً من مايو 2024"
        ),
        GovernmentSupportTemplate(
            name: "ساند (التأمين ضد التعطل)",
            dayOfMonth: 1,
            systemIcon: "briefcase",
            sourceNote: "تصرفه التأمينات الاجتماعية (GOSI) في بداية كل شهر ميلادي"
        ),
        GovernmentSupportTemplate(
            name: "الضمان الاجتماعي المطور",
            dayOfMonth: 1,
            systemIcon: "hands.sparkles",
            sourceNote: "يُصرف عادةً في بداية كل شهر ميلادي وفق آخر دفعات وزارة الموارد البشرية — تابع إعلاناتها الشهرية للتأكد من التاريخ الدقيق"
        ),
        GovernmentSupportTemplate(
            name: "التأهيل الشامل",
            dayOfMonth: 26,
            systemIcon: "heart.text.square",
            sourceNote: "تصرفه وزارة الموارد البشرية والتنمية الاجتماعية في اليوم 26 من كل شهر ميلادي"
        ),
    ]
}
