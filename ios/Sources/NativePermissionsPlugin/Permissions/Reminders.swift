//
//  Created by Yevhenii Smirnov on 24/08/2025.
//

#if PERMISSION_REMINDERS

import Capacitor
import EventKit
import Foundation

internal final class Reminders {
    internal static let instance = Reminders()

    private let store = EKEventStore()

    internal func checkStatus() -> PermissionStatus {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        return mapFullAccessStatus(status)
    }

    internal func requestPermission() async throws -> PermissionStatus {
        let status = checkStatus()

        guard status != .granted || status != .permanentlyDenied else {
            return status
        }

        if #available(iOS 17.0, *) {
            let granted = try await store.requestFullAccessToReminders()
            return granted ? .granted : .permanentlyDenied
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                store.requestAccess(to: .reminder) { granted, error in
                    guard let error else {
                        continuation.resume(returning: granted ? .granted : .permanentlyDenied)
                        return
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func mapFullAccessStatus(_ status: EKAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .fullAccess:
            return .granted
        case .writeOnly, .authorized:
            return .denied
        case .denied, .restricted:
            return .permanentlyDenied
        case .notDetermined:
            return .denied
        @unknown default:
            return .denied
        }
    }
}

#endif
