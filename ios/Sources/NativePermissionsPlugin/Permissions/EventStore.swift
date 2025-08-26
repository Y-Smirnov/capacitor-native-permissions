//
//  Created by Yevhenii Smirnov on 24/08/2025.
//

import Capacitor
import EventKit

internal final class EventStore {
    internal static let instance = EventStore()

    private let store = EKEventStore()

    internal func checkCalendarStatus(_ options: [String]) throws -> PermissionStatus {
        guard let permission = getPermission(options) else {
            throw NativePermissionsError.invalidPermissionOptions
        }

        switch permission {
        case .write:
            let status = EKEventStore.authorizationStatus(for: .event)
            return mapWriteStatus(status)

        case .full:
            let status = EKEventStore.authorizationStatus(for: .event)
            return mapFullAccessStatus(status)
        }
    }

    internal func checkReminderStatus() -> PermissionStatus {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        return mapFullAccessStatus(status)
    }

    internal func requestCalendarPermission(_ options: Array<String>) async throws -> PermissionStatus {
        guard let permission = getPermission(options) else {
            throw NativePermissionsError.invalidPermissionOptions
        }

        switch permission {
        case .write:
            if #available(iOS 17.0, *) {
                let granted = try await store.requestWriteOnlyAccessToEvents()

                return granted ? .granted : .permanentlyDenied
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    store.requestAccess(to: .event) { granted, error in
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

        case .full:
            if #available(iOS 17.0, *) {
                let granted = try await store.requestFullAccessToEvents()

                return granted ? .granted : .permanentlyDenied
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    store.requestAccess(to: .event) { granted, error in
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
    }

    internal func requestReminderPermission() async throws -> PermissionStatus {
        if #available(iOS 17.0, *) {
            let granted = try await store.requestFullAccessToReminders()

            return granted ? .granted : .permanentlyDenied
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                store.requestAccess(to: .reminder) { granted, error in
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

    private func getPermission(_ options: [String]) -> CalendarPermission? {
        for option in options {
            if let permission = CalendarPermission.allCases.first(where: {
                $0.rawValue.caseInsensitiveCompare(option) == .orderedSame
            }) {
                return permission
            }
        }

        return nil
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

    private enum CalendarPermission: String, CaseIterable {
        case write
        case full
    }
}
