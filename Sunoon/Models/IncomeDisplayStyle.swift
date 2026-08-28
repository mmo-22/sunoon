//
//  IncomeDisplayStyle.swift
//  طريقة عرض مصادر الدخل في بطاقة الرواتب والدعم: قائمة أو شبكة.
//

import Foundation

enum IncomeDisplayStyle: String, CaseIterable, Codable, Equatable {
    case list
    case grid

    var systemIcon: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
}
