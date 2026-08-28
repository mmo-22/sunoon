//
//  PrayerTimesCalculator.swift
//  حساب فلكي تقريبي لمواقيت الصلاة (زاوية فجر 18.5°، عشاء = مغرب + 90 دقيقة
//  وفق طريقة أم القرى، وعصر بمعامل الشافعي=1). الخوارزمية تمّ اختبارها
//  ومطابقتها يدويًا مع مواقيت دمّام الرسمية قبل التطبيق هنا.
//

import Foundation

struct PrayerTimes {
    var fajr: Double     // بالساعات العشرية، محليًا
    var sunrise: Double
    var dhuhr: Double
    var asr: Double
    var maghrib: Double
    var isha: Double

    subscript(key: PrayerKey) -> Double {
        switch key {
        case .fajr: return fajr
        case .sunrise: return sunrise
        case .dhuhr: return dhuhr
        case .asr: return asr
        case .maghrib: return maghrib
        case .isha: return isha
        }
    }
}

enum PrayerKey: String, CaseIterable {
    case fajr, sunrise, dhuhr, asr, maghrib, isha

    var arabicLabel: String {
        switch self {
        case .fajr: return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }

    /// المواقيت المرشحة كـ"الصلاة القادمة" (نستبعد الشروق لأنه ليس وقت صلاة)
    static var nextPrayerCandidates: [PrayerKey] { [.fajr, .dhuhr, .asr, .maghrib, .isha] }
}

enum PrayerTimesCalculator {

    private static func deg2rad(_ d: Double) -> Double { d * .pi / 180 }
    private static func rad2deg(_ r: Double) -> Double { r * 180 / .pi }
    private static func fix360(_ a: Double) -> Double {
        var v = a.truncatingRemainder(dividingBy: 360)
        if v < 0 { v += 360 }
        return v
    }
    private static func fix24(_ a: Double) -> Double {
        var v = a.truncatingRemainder(dividingBy: 24)
        if v < 0 { v += 24 }
        return v
    }

    private static func julianDate(year: Int, month: Int, day: Int) -> Double {
        var y = year, m = month
        if m <= 2 { y -= 1; m += 12 }
        let a = Double(y) / 100
        let A = floor(a)
        let B = 2 - A + floor(A / 4)
        return floor(365.25 * Double(y + 4716)) + floor(30.6001 * Double(m + 1)) + Double(day) + B - 1524.5
    }

    private struct SunPosition { var eqt: Double; var decl: Double }

    private static func sunPosition(jd: Double) -> SunPosition {
        let D = jd - 2451545.0
        let g = fix360(357.529 + 0.98560028 * D)
        let q = fix360(280.459 + 0.98564736 * D)
        let L = fix360(q + 1.915 * sin(deg2rad(g)) + 0.020 * sin(deg2rad(2 * g)))
        let e = 23.439 - 0.00000036 * D
        let RA = rad2deg(atan2(cos(deg2rad(e)) * sin(deg2rad(L)), cos(deg2rad(L)))) / 15
        let eqt = q / 15 - fix24(RA)
        let decl = rad2deg(asin(sin(deg2rad(e)) * sin(deg2rad(L))))
        return SunPosition(eqt: eqt, decl: decl)
    }

    /// زاوية الساعة (بالساعات) عند ارتفاع شمسي معيّن (موجب = فوق الأفق)
    private static func altHourAngle(lat: Double, decl: Double, altitude: Double) -> Double {
        let num = sin(deg2rad(altitude)) - sin(deg2rad(lat)) * sin(deg2rad(decl))
        let den = cos(deg2rad(lat)) * cos(deg2rad(decl))
        let ratio = max(-1, min(1, num / den))
        return rad2deg(acos(ratio)) / 15
    }

    /// - Parameters:
    ///   - timeZoneOffsetHours: فرق التوقيت المحلي عن UTC (مثلاً 3 للسعودية)
    static func calculate(year: Int, month: Int, day: Int,
                           latitude: Double, longitude: Double,
                           timeZoneOffsetHours: Double) -> PrayerTimes {
        let jd = julianDate(year: year, month: month, day: day) - longitude / (15 * 24)
        let sun = sunPosition(jd: jd)
        let dhuhr = fix24(12 - longitude / 15 - sun.eqt + timeZoneOffsetHours)

        let tSun = altHourAngle(lat: latitude, decl: sun.decl, altitude: -0.833)
        let tFajr = altHourAngle(lat: latitude, decl: sun.decl, altitude: -18.5)

        let asrFactor = 1.0 // مذهب الشافعي، المعتمد في الحساب الرسمي بالسعودية
        let asrAltitude = rad2deg(atan(1 / (asrFactor + tan(deg2rad(abs(latitude - sun.decl))))))
        let tAsr = altHourAngle(lat: latitude, decl: sun.decl, altitude: asrAltitude)

        let fajr = fix24(dhuhr - tFajr)
        let sunrise = fix24(dhuhr - tSun)
        let asr = fix24(dhuhr + tAsr)
        let maghrib = fix24(dhuhr + tSun)
        let isha = fix24(maghrib + 1.5) // عشاء = مغرب + 90 دقيقة (طريقة أم القرى)

        return PrayerTimes(fajr: fajr, sunrise: sunrise, dhuhr: dhuhr, asr: asr, maghrib: maghrib, isha: isha)
    }

    /// تحويل ساعة عشرية (مثل 13.5) إلى "HH:mm"
    static func timeString(_ t: Double) -> String {
        var h = Int(floor(t))
        var mn = Int((t - floor(t)) * 60 + 0.5)
        if mn == 60 { h += 1; mn = 0 }
        h = ((h % 24) + 24) % 24
        return String(format: "%02d:%02d", h, mn)
    }

    static func decimalHours(from date: Date, calendar: Calendar) -> Double {
        let c = calendar.dateComponents([.hour, .minute, .second], from: date)
        return Double(c.hour ?? 0) + Double(c.minute ?? 0) / 60 + Double(c.second ?? 0) / 3600
    }
}
