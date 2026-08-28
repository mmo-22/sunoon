//
//  HijriDate.swift
//  تحويل التاريخ بين الميلادي والهجري.
//
//  نعتمد على تقويم iOS المدمج (Umm al-Qura) بدل أي حساب يدوي،
//  لأنه يطابق التقويم الرسمي المعتمد في السعودية بدقة كاملة.
//

import Foundation

struct HijriDateParts: Equatable {
    var day: Int
    var month: Int   // 1...12
    var year: Int
}

enum HijriCalendarService {

    static let hijriCalendar: Calendar = {
        var cal = Calendar(identifier: .islamicUmmAlQura)
        cal.locale = Locale(identifier: "ar_SA")
        cal.timeZone = TimeZone.current
        return cal
    }()

    static let gregorianCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ar_SA")
        cal.timeZone = TimeZone.current
        return cal
    }()

    static let hijriMonthNames = [
        "محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة",
        "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
    ]

    static let gregorianMonthNames = [
        "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
        "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
    ]

    static let weekdayNames = [
        "الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"
    ]

    /// ميلادي → هجري
    static func toHijri(_ date: Date) -> HijriDateParts {
        let comps = hijriCalendar.dateComponents([.year, .month, .day], from: date)
        return HijriDateParts(day: comps.day ?? 1, month: comps.month ?? 1, year: comps.year ?? 1)
    }

    /// هجري → ميلادي (nil إذا كان التاريخ غير صالح)
    static func toGregorian(day: Int, month: Int, year: Int) -> Date? {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.calendar = hijriCalendar
        return hijriCalendar.date(from: comps)
    }

    static func weekdayName(for date: Date) -> String {
        // Calendar.component(.weekday) => 1 = Sunday ... 7 = Saturday
        let idx = gregorianCalendar.component(.weekday, from: date) - 1
        return weekdayNames[idx]
    }

    static func hijriString(_ parts: HijriDateParts) -> String {
        "\(parts.day) \(hijriMonthNames[parts.month - 1]) \(parts.year)هـ"
    }

    static func gregorianString(_ date: Date) -> String {
        let comps = gregorianCalendar.dateComponents([.day, .month, .year], from: date)
        let d = comps.day ?? 1, m = (comps.month ?? 1) - 1, y = comps.year ?? 1
        return "\(d) \(gregorianMonthNames[m]) \(y)م"
    }
}
