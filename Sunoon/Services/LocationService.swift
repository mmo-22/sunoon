//
//  LocationService.swift
//  طلب الموقع مرة واحدة عند الضغط على زر تحديد الموقع.
//
//  مهم: أضف مفتاح NSLocationWhenInUseUsageDescription في Info.plist
//  (راجع ملف README المرفق مع المشروع لنص مقترح بالعربي).
//

import CoreLocation
import Observation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    var isRequesting = false
    var lastError: String?

    /// يُستدعى عند نجاح تحديد الموقع
    var onLocationResolved: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestOnce() {
        lastError = nil
        isRequesting = true
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            isRequesting = false
            lastError = "الوصول للموقع مرفوض من إعدادات الجهاز. سيتم استخدام الموقع الافتراضي."
        @unknown default:
            isRequesting = false
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied {
            isRequesting = false
            lastError = "الوصول للموقع مرفوض. سيتم استخدام الموقع الافتراضي."
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isRequesting = false
        guard let coord = locations.last?.coordinate else { return }
        onLocationResolved?(coord)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRequesting = false
        lastError = "تعذّر تحديد الموقع. سيتم استخدام الموقع الافتراضي."
    }
}
