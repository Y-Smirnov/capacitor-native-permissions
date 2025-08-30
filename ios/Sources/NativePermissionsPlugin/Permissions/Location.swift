//
//  Created by Yevhenii Smirnov on 30/08/2025.
//

import Capacitor
import CoreLocation

private let REQUESTED_BACKGROUND_LOCATION_KEY = "capacitor.native.permisisons.requested_location_background"

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

    internal func checkStatus(_ options: [String]) throws -> PermissionStatus {
        guard let permission = getPermission(options) else {
            throw NativePermissionsError.invalidPermissionOptions
        }

        return mapStatus(permission, authorizationStatus: authorizationStatus)
    }

    internal func requestPermission(_ options: [String]) async throws -> PermissionStatus {
        let status = try checkStatus(options)

        if status == .granted || status == .permanentlyDenied {
            return status
        }

        guard let permission = getPermission(options) else {
            throw NativePermissionsError.invalidPermissionOptions
        }

        if (permission == .background) {
            if (authorizationStatus == .notDetermined) {
                throw NativePermissionsError.invalidRequestSequence(message: "Foreground (when in use) location permission should be requested before background (always) request.")
            }
        }

        return await withCheckedContinuation { continuation in
            requestedPermissionContinuation = continuation
            requestedPermission = permission

            if permission == .foreground {
                locationManager.requestWhenInUseAuthorization()
            } else if permission == .background {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(applicationDidBecomeActive),
                    name: UIApplication.didBecomeActiveNotification,
                    object: nil
                )

                locationManager.requestAlwaysAuthorization()
                UserDefaults.standard.set(true, forKey: REQUESTED_BACKGROUND_LOCATION_KEY)
            }
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

    private func getPermission(_ options: [String]) -> LocationPermission? {
        for option in options {
            if let permission = LocationPermission.allCases.first(where: {
                $0.rawValue.caseInsensitiveCompare(option) == .orderedSame
            }) {
                return permission
            }
        }

        return nil
    }

    private func mapStatus(_ permission: LocationPermission, authorizationStatus: CLAuthorizationStatus) -> PermissionStatus {
        if permission == .background {
            switch authorizationStatus {
            case .notDetermined:
                return .denied
            case .restricted:
                return .denied
            case .denied:
                return .permanentlyDenied
            case .authorizedWhenInUse:
                return UserDefaults.standard.bool(forKey: REQUESTED_BACKGROUND_LOCATION_KEY) ? .permanentlyDenied : .denied
            case .authorizedAlways:
                return .granted
            @unknown default:
                return .denied
            }
        }

        switch authorizationStatus {
        case .notDetermined:
            return .denied
        case .restricted:
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

extension Location: CLLocationManagerDelegate {
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
            UserDefaults.standard.removeObject(forKey: REQUESTED_BACKGROUND_LOCATION_KEY)
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
