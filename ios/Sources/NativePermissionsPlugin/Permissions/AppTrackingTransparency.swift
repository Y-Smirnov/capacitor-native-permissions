//
//  Created by Yevhenii Smirnov
//

#if PERMISSION_APP_TRACKING_TRANSPARENCY

import AppTrackingTransparency

internal struct AppTrackingTransparency {
    internal static let instance = AppTrackingTransparency()

    internal func checkStatus() -> PermissionStatus {
        let status = ATTrackingManager.trackingAuthorizationStatus

        var permissionStatus = PermissionStatus.denied

        if status == .authorized {
            permissionStatus = .granted
        }

        if status == .denied {
            return .permanentlyDenied
        }

        return permissionStatus
    }

    internal func requestPermission() async -> PermissionStatus {
        let status = checkStatus()

        guard status != .granted && status != .permanentlyDenied else {
            return status
        }

        let request = await ATTrackingManager.requestTrackingAuthorization()

        guard request == .authorized else {
            return .permanentlyDenied
        }
        
        return .granted
    }
}

#endif
