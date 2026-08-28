//
//  SalaryScheduler.swift
//  حساب تاريخ الصرف القادم والأيام المتبقية ونسبة تقدّم الشهر.
//

import Foundation

struct SalaryStatus {
    var nextPayday: Date
    var daysLeft: Int
    var progress: Double // 0...1، نسبة الأيام المنقضية من الدورة الحالية
}

enum SalaryScheduler {

    private static var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        return cal
    }

    private static func daysInMonth(year: Int, month: Int) -> Int {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        let date = calendar.date(from: comps)!
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }

    private static func clampedPayday(day: Int, year: Int, month: Int) -> Date {
        let clampedDay = min(day, daysInMonth(year: year, month: month))
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = clampedDay
        return calendar.date(from: comps)!
    }

    static func status(paydayOfMonth: Int, today: Date = Date()) -> SalaryStatus {
        let todayStart = calendar.startOfDay(for: today)
        let y = calendar.component(.year, from: todayStart)
        let m = calendar.component(.month, from: todayStart)

        var payDate = clampedPayday(day: paydayOfMonth, year: y, month: m)

        if payDate < todayStart {
            let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: payDate)!
            let ny = calendar.component(.year, from: nextMonthDate)
            let nm = calendar.component(.month, from: nextMonthDate)
            payDate = clampedPayday(day: paydayOfMonth, year: ny, month: nm)
        }

        let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: payDate)!
        let py = calendar.component(.year, from: prevMonthDate)
        let pm = calendar.component(.month, from: prevMonthDate)
        let prevPay = clampedPayday(day: paydayOfMonth, year: py, month: pm)

        let totalCycle = calendar.dateComponents([.day], from: prevPay, to: payDate).day ?? 30
        let elapsed = calendar.dateComponents([.day], from: prevPay, to: todayStart).day ?? 0
        let daysLeft = calendar.dateComponents([.day], from: todayStart, to: payDate).day ?? 0

        let progress = totalCycle > 0 ? max(0, min(1, Double(elapsed) / Double(totalCycle))) : 0

        return SalaryStatus(nextPayday: payDate, daysLeft: daysLeft, progress: progress)
    }
}
