//
//  Created by Yevhenii Smirnov on 27/08/2025.
//

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
        case .denied, .restricted:
                return .permanentlyDenied
        @unknown default:
            return .denied
        }
    }

    internal func requestPermission() async -> PermissionStatus {
        return await withCheckedContinuation { continuation in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                continuation.resume(returning: .granted)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted ?.granted : .denied)
                }
            case .denied, .restricted:
                continuation.resume(returning: .permanentlyDenied)
            @unknown default:
                continuation.resume(returning: .denied)
            }
        }
    }
}
