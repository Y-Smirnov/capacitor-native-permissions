import Foundation
import Photos

internal final class MediaLibrary: Sendable {
    internal static let instance = MediaLibrary()

    private var accessLevel: PHAccessLevel {
        if Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") != nil {
            return .readWrite
        } else {
            return .addOnly
        }
    }

    internal func checkStatus() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        return mapStatus(status)
    }

    internal func requestPermisison() async -> PermissionStatus {
        let status = checkStatus()

        if status == .granted || status == .permanentlyDenied {
            return status
        }

        let accessLevel = accessLevel

        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
                continuation.resume(returning: self.mapStatus(status))
            }
        }
    }

    private func mapStatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized, .limited:
            return .granted

        case .denied, .restricted:
            return .permanentlyDenied

        case .notDetermined:
            return .denied

        @unknown default:
            return .denied
        }
    }
}
