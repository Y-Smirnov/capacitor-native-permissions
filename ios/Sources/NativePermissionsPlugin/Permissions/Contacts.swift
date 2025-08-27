//
//  Created by Yevhenii Smirnov on 27/08/2025.
//

import Contacts

internal final class Contacts {
    internal static let instance = Contacts()

    internal func checkStatus() -> PermissionStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)

        switch status {
        case .authorized, .limited:
            return .granted
        case .notDetermined:
            return .denied
        case .denied, .restricted:
            return .permanentlyDenied
        @unknown default:
            return .denied
        }
    }

    internal func requestPermisison() async throws -> PermissionStatus {
        return try await withCheckedThrowingContinuation { continuation in
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                guard let error else {
                    if granted {
                        continuation.resume(returning: .granted)
                    } else {
                        continuation.resume(returning: .permanentlyDenied)
                    }

                    return
                }

                continuation.resume(throwing: error)
            }
        }
    }
}
