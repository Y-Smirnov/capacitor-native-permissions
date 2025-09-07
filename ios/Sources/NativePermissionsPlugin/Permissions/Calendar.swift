//
//  Created by Yevhenii Smirnov on 24/08/2025.
//

#if PERMISSION_CALENDAR

import Capacitor
import EventKit
import Foundation

internal final class Calendar {
    internal static let instance = Calendar()

    private let store = EKEventStore()

    private enum CalendarAccessMode {
        case write
        case full
    }

    private var calendarAccessLevel: CalendarAccessMode {
        if Bundle.main.object(forInfoDictionaryKey: "NSCalendarsFullAccessUsageDescription") != nil {
            return .full
        }

        return .write
    }

    internal func checkStatus() -> PermissionStatus {
        switch calendarAccessLevel {
        case .write:
            let status = EKEventStore.authorizationStatus(for: .event)
            return mapWriteStatus(status)

        case .full:
            let status = EKEventStore.authorizationStatus(for: .event)
            return mapFullAccessStatus(status)
        }
    }

    internal func requestPermission() async throws -> PermissionStatus {
        let status = checkStatus()

        guard status != .granted || status != .permanentlyDenied else {
            return status
        }

        switch calendarAccessLevel {
        case .write:
            if #available(iOS 17.0, *) {
                let granted = try await store.requestWriteOnlyAccessToEvents()
                return granted ? .granted : .permanentlyDenied
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    store.requestAccess(to: .event) { granted, error in
                        guard let error else {
                            continuation.resume(returning: granted ? .granted : .permanentlyDenied)
                            return
                        }
                        continuation.resume(throwing: error)
                    }
                }
            }

        case .full:
            if #available(iOS 17.0, *) {
                let granted = try await store.requestFullAccessToEvents()
                return granted ? .granted : .permanentlyDenied
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    store.requestAccess(to: .event) { granted, error in
                        guard let error else {
                            continuation.resume(returning: granted ? .granted : .permanentlyDenied)
                            return
                        }
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    private func mapWriteStatus(_ status: EKAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized, .fullAccess, .writeOnly:
            return .granted
        case .denied, .restricted:
            return .permanentlyDenied
        case .notDetermined:
            return .denied
        @unknown default:
            return .denied
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
