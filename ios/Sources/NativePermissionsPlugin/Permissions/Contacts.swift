//
//  Created by Yevhenii Smirnov on 27/08/2025.
//

#if PERMISSION_CONTACTS

import Contacts

internal final class Contacts {
    internal static let instance = Contacts()

    internal func checkStatus() -> PermissionStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)

        switch status {
        case .authorized, .limited:
            return .granted

        case .notDetermined, .restricted:
            return .denied

        case .denied:
            return .permanentlyDenied

        @unknown default:
            return .denied
        }
    }

    internal func requestPermisison() async throws -> PermissionStatus {
        let status = checkStatus()

        guard status != .granted && status != .permanentlyDenied else {
            return status
        }

        return try await withCheckedThrowingContinuation { continuation in
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                guard let error else {
                    if granted {
                        continuation.resume(returning: .granted)
                    } else {
                        continuation.resume(returning: .denied)
                    }

                    return
                }

                continuation.resume(returning: .denied)
            }
        }
    }
}

#endif
