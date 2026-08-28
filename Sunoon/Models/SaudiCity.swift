//
//  SaudiCity.swift
//  قائمة جاهزة بأهم مدن السعودية وإحداثياتها، لاختيار الموقع يدويًا
//  من الإعدادات بدل الاعتماد على GPS فقط.
//

import Foundation

struct SaudiCity: Identifiable {
    var id: String { name }
    var name: String
    var latitude: Double
    var longitude: Double
}

enum SaudiCityCatalog {
    static let all: [SaudiCity] = [
        SaudiCity(name: "الرياض", latitude: 24.7136, longitude: 46.6753),
        SaudiCity(name: "جدة", latitude: 21.4858, longitude: 39.1925),
        SaudiCity(name: "مكة المكرمة", latitude: 21.3891, longitude: 39.8579),
        SaudiCity(name: "المدينة المنورة", latitude: 24.5247, longitude: 39.5692),
        SaudiCity(name: "الدمام", latitude: 26.4207, longitude: 50.0888),
        SaudiCity(name: "الخبر", latitude: 26.2172, longitude: 50.1971),
        SaudiCity(name: "الظهران", latitude: 26.2361, longitude: 50.1400),
        SaudiCity(name: "الطائف", latitude: 21.2703, longitude: 40.4158),
        SaudiCity(name: "تبوك", latitude: 28.3838, longitude: 36.5550),
        SaudiCity(name: "بريدة", latitude: 26.3260, longitude: 43.9750),
        SaudiCity(name: "خميس مشيط", latitude: 18.3000, longitude: 42.7333),
        SaudiCity(name: "أبها", latitude: 18.2164, longitude: 42.5053),
        SaudiCity(name: "حائل", latitude: 27.5114, longitude: 41.6900),
        SaudiCity(name: "نجران", latitude: 17.4933, longitude: 44.1277),
        SaudiCity(name: "جازان", latitude: 16.8892, longitude: 42.5611),
        SaudiCity(name: "ينبع", latitude: 24.0896, longitude: 38.0618),
        SaudiCity(name: "القطيف", latitude: 26.5196, longitude: 49.9975),
        SaudiCity(name: "الأحساء (الهفوف)", latitude: 25.3838, longitude: 49.5872),
        SaudiCity(name: "عرعر", latitude: 30.9753, longitude: 41.0381),
        SaudiCity(name: "سكاكا", latitude: 29.9697, longitude: 40.2064),
    ]
}
