//
//  IncomeSource.swift
//  نموذج مصدر دخل واحد (راتب شخصي أو دعم حكومي) — اسم، يوم الصرف الشهري، ونوعه.
//

import Foundation

enum IncomeKind: String, Codable, Equatable, Hashable {
    case personalSalary
    case governmentSupport
}

struct IncomeSource: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var dayOfMonth: Int          // يوم الصرف من كل شهر ميلادي (1...31)
    var kind: IncomeKind
    var sourceNote: String?      // مصدر رسمي/ملاحظة — تُعرض فقط لعناصر الدعم الحكومي
    var systemIcon: String = "banknote"
}
