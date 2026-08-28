//
//  DailyAdhkar.swift
//  يختار ذكرًا قصيرًا مناسبًا حسب وقت اليوم، مع تذكير خاص بقراءة
//  سورة الكهف يوم الجمعة يطغى على بقية الأذكار.
//

import Foundation

enum AdhkarProvider {
    private static let morning = [
        "أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له",
        "اللهم بك أصبحنا، وبك أمسينا، وبك نحيا وبك نموت وإليك النشور",
        "سبحان الله وبحمده عدد خلقه ورضا نفسه وزنة عرشه ومداد كلماته"
    ]

    private static let evening = [
        "أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له",
        "اللهم بك أمسينا، وبك أصبحنا، وبك نحيا وبك نموت وإليك المصير",
        "أستغفر الله العظيم الذي لا إله إلا هو الحي القيوم وأتوب إليه"
    ]

    private static let general = [
        "سبحان الله وبحمده، سبحان الله العظيم",
        "لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير",
        "لا حول ولا قوة إلا بالله",
        "استغفر الله وأتوب إليه"
    ]

    private static let fridayReminder = "اليوم الجمعة، لا تنس قراءة سورة الكهف 📖"

    /// يُرجع نص الذكر المناسب للحظة الحالية: يوم الجمعة يطغى على البقية،
    /// وإلا يُختار حسب فترة اليوم (صباح/مساء/عام)، مع تدوير يومي بسيط
    /// بين العبارات المتاحة بحيث يثبت نفس الذكر طول اليوم ويتغيّر غدًا.
    static func text(for date: Date, calendar: Calendar = .current) -> String {
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 6 { // الجمعة (الأحد = 1 ... الجمعة = 6)
            return fridayReminder
        }

        let hour = calendar.component(.hour, from: date)
        let pool: [String]
        switch hour {
        case 4..<12: pool = morning
        case 15..<21: pool = evening
        default: pool = general
        }

        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = dayOfYear % pool.count
        return pool[index]
    }
}
