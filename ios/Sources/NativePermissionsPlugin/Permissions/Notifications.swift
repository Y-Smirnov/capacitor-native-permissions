//
//  Created by Yevhenii Smirnov
//

#if PERMISSION_NOTIFICATIONS

internal struct Notifications {
    internal static let instance = Notifications()

    private let notificationCenter = UNUserNotificationCenter.current()

    internal func checkStatus() async -> PermissionStatus {
        return await withCheckedContinuation { continuation in
            notificationCenter.getNotificationSettings { status in
                var permissionStatus = PermissionStatus.denied

                if status.authorizationStatus == .authorized {
                    permissionStatus = PermissionStatus.granted
                }

                if status.authorizationStatus == .denied {
                    permissionStatus = PermissionStatus.permanentlyDenied
                }

                continuation.resume(returning: permissionStatus)
            }
        }
    }

    internal func requestPermission(_ options: [String]) async throws -> PermissionStatus {
        let status = await checkStatus()

        guard status != .granted && status != .permanentlyDenied && status != .restricted else {
            return status
        }

        let authorizationOptions = self.processNotificationAuthorizationOptions(options)

         return try await withCheckedThrowingContinuation { continuation in
            self.notificationCenter.requestAuthorization(options: authorizationOptions) { (granted, error) in
                guard let error else {
                    if granted {
                        continuation.resume(returning: PermissionStatus.granted)
                    } else {
                        continuation.resume(returning: PermissionStatus.denied)
                    }

                    return
                }

                continuation.resume(throwing: error)
            }
        }
    }

    private func processNotificationAuthorizationOptions(_ options: [String]) -> UNAuthorizationOptions {
        var authorizationOptions: UNAuthorizationOptions = []

        options.forEach { option in
            if option == "alert" {
                authorizationOptions = [authorizationOptions, .alert]
            }

            if option == "badge" {
                authorizationOptions = [authorizationOptions, .badge]
            }

            if option == "sound" {
                authorizationOptions = [authorizationOptions, .sound]
            }

            if option == "carPlay" {
                authorizationOptions = [authorizationOptions, .carPlay]
            }

            if #available(iOS 12.0, *) {
                if option == "providesAppNotificationSettings" {
                    authorizationOptions = [authorizationOptions, .providesAppNotificationSettings]
                }

                if option == "provisional" {
                    authorizationOptions = [authorizationOptions, .provisional]
                }

                if option == "criticalAlert" {
                    authorizationOptions = [authorizationOptions, .criticalAlert]
                }
            }

            if #available(iOS 13.0, *) {
                if option == "announcement" {
                    authorizationOptions = [authorizationOptions, .announcement]
                }
            }
        }

        return authorizationOptions
    }
}

#endif
