//
//  Created by Yevhenii Smirnov on 24/08/2025.
//

#if PERMISSION_LOCATION_FOREGROUND

import Capacitor
import CoreLocation

private let REQUESTED_LOCATION_BACKGROUND_KEY = "capacitor.native.permisisons.requested_location_background"

@MainActor
internal final class Location: NSObject {
    internal static let instance = Location()

    private let locationManager = CLLocationManager()
    private var requestedPermission: LocationPermission?
    private var requestedPermissionContinuation: CheckedContinuation<PermissionStatus, Never>?

    internal override init() {
        super.init()

        locationManager.delegate = self
    }

    private var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        }

        return CLLocationManager.authorizationStatus()
    }

    internal func checkForegroundStatus() -> PermissionStatus {
        return mapStatus(.foreground, authorizationStatus: authorizationStatus)
    }

    internal func requestForegroundPermission() async -> PermissionStatus {
        let status = checkForegroundStatus()

        guard status != .granted && status != .permanentlyDenied else {
            return status
        }

        return await withCheckedContinuation { continuation in
            requestedPermissionContinuation = continuation
            requestedPermission = .foreground

            locationManager.requestWhenInUseAuthorization()
        }
    }

#if PERMISSION_LOCATION_BACKGROUND

    internal func checkBackgroundStatus() -> PermissionStatus {
        return mapStatus(.background, authorizationStatus: authorizationStatus)
    }

    internal func requestBackgroundPermission() async -> PermissionStatus {
        let status = checkBackgroundStatus()

        guard status != .granted && status != .permanentlyDenied else {
            return status
        }

        return await withCheckedContinuation { continuation in
            requestedPermissionContinuation = continuation
            requestedPermission = .background

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationDidBecomeActive),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )

            locationManager.requestAlwaysAuthorization()
            UserDefaults.standard.set(true, forKey: REQUESTED_LOCATION_BACKGROUND_KEY)
        }
    }

    @objc private func applicationDidBecomeActive() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        guard let requestedPermissionContinuation = requestedPermissionContinuation else {
            return
        }

        if (authorizationStatus != .authorizedAlways) {
            requestedPermissionContinuation.resume(returning: PermissionStatus.denied)

            self.requestedPermission = nil
            self.requestedPermissionContinuation = nil
        }
    }

#endif

    private func mapStatus(_ permission: LocationPermission, authorizationStatus: CLAuthorizationStatus) -> PermissionStatus {
        if permission == .background {
            switch authorizationStatus {
            case .notDetermined, .restricted:
                return .denied
            case .denied:
                return .permanentlyDenied
            case .authorizedWhenInUse:
                return UserDefaults.standard.bool(forKey: REQUESTED_LOCATION_BACKGROUND_KEY) ? .permanentlyDenied : .denied
            case .authorizedAlways:
                return .granted
            @unknown default:
                return .denied
            }
        }

        switch authorizationStatus {
        case .notDetermined, .restricted:
            return .denied
        case .denied:
            return .permanentlyDenied
        case .authorizedWhenInUse, .authorizedAlways:
            return .granted
        @unknown default:
            return .denied
        }
    }

    private enum LocationPermission: String, CaseIterable {
        case foreground
        case background
    }
}

extension Location: @preconcurrency CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorizationChange(status)
    }

    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationChange(manager.authorizationStatus)
    }

    private func handleAuthorizationChange(_ authorizationStatus: CLAuthorizationStatus) {
        if authorizationStatus == .notDetermined {
            // When the user makes change in the Settings app.
            UserDefaults.standard.removeObject(forKey: REQUESTED_LOCATION_BACKGROUND_KEY)
        }

        guard let requestedPermission = requestedPermission, let requestedPermissionContinuation = requestedPermissionContinuation else {
            return
        }
        
        let status = mapStatus(requestedPermission, authorizationStatus: authorizationStatus)

        // Treat 'Permanently Denied' as 'Denied' as this is result from request (applies only to 'When in Use' permission)
        if (status == .permanentlyDenied) {
            requestedPermissionContinuation.resume(returning: PermissionStatus.denied)
        } else {
            requestedPermissionContinuation.resume(returning: status)
        }

        self.requestedPermission = nil
        self.requestedPermissionContinuation = nil
    }
}

#endif
