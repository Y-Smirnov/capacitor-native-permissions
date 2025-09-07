//
//  Created by Yevhenii Smirnov on 27/08/2025.
//

#if PERMISSION_CAMERA

import AVFoundation

internal final class Camera {
    internal static let instance = Camera()

    internal func checkStatus() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return .granted

        case .notDetermined:
                return .denied

        case .denied:
                return .permanentlyDenied

        case .restricted:
            return .restricted

        @unknown default:
            return .denied
        }
    }

    internal func requestPermission() async -> PermissionStatus {
        let status = checkStatus()

        guard status != .granted && status != .permanentlyDenied && status != .restricted else {
            return status
        }

        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted ?.granted : .denied)
            }
        }
    }
}

#endif
