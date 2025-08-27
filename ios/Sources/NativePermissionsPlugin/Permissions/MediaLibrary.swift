//
//  Created by Yevhenii Smirnov on 27/08/2025.
//

import Photos

internal final class MediaLibrary: Sendable {
    internal static let instance = MediaLibrary()

    internal func checkStatus(_ options: [String]) throws -> PermissionStatus {
        guard let permission = getPermission(options) else {
            throw NativePermissionsError.invalidPermissionOptions
        }

        switch permission {
        case .write:
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            return maptatus(status)

        case .readWrite:
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            return maptatus(status)
        }
    }

    internal func requestPermisison(_ options: [String]) async throws -> PermissionStatus {
        guard let permission = getPermission(options) else {
            throw NativePermissionsError.invalidPermissionOptions
        }

        var accessLevel: PHAccessLevel {
            switch (permission) {
            case .write:
                return .addOnly
            case .readWrite:
                return .readWrite
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
                continuation.resume(returning: self.maptatus(status))
            }
        }
    }

    private func getPermission(_ options: [String]) -> MediaLibraryPermission? {
        for option in options {
            if let permission = MediaLibraryPermission.allCases.first(where: {
                $0.rawValue.caseInsensitiveCompare(option) == .orderedSame
            }) {
                return permission
            }
        }

        return nil
    }

    private func maptatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
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

    private enum MediaLibraryPermission: String, CaseIterable {
        case write
        case readWrite
    }
}
