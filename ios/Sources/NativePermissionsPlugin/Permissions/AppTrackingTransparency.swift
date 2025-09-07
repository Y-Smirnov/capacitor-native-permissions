//
//  Created by Yevhenii Smirnov
//

#if PERMISSION_APP_TRACKING_TRANSPARENCY

import AppTrackingTransparency

internal struct AppTrackingTransparency {
    internal static let instance = AppTrackingTransparency()

    internal func checkStatus() -> PermissionStatus {
        let status = ATTrackingManager.trackingAuthorizationStatus
        return mapStatus(status)
    }

    internal func requestPermission() async -> PermissionStatus {
        let status = checkStatus()

        guard status != .granted && status != .permanentlyDenied && status != .restricted else {
            return status
        }

        let request = await ATTrackingManager.requestTrackingAuthorization()

        guard request == .authorized else {
            return .denied
        }
        
        return .granted
    }

    private func mapStatus(_ status: ATTrackingManager.AuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized:
            return .granted
        case .denied:
            return .permanentlyDenied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .denied
        @unknown default:
            return .denied
        }
    }
}

#endif
