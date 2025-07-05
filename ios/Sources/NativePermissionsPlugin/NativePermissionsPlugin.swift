import Foundation
import Capacitor

@objc(NativePermissionsPlugin)
public class NativePermissionsPlugin: CAPPlugin, CAPBridgedPlugin {
    private let notificationCenter = UNUserNotificationCenter.current()

    public let identifier = "NativePermissionsPlugin"
    public let jsName = "NativePermissionsPlugin"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "checkNotifications", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "shouldShowNotificationsRationale", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestNotifications", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = NativePermissions()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    @objc func checkNotifications(_ call: CAPPluginCall) {
        checkPermissionStatus { status in
            call.resolve(["result": status.rawValue])
        }
    }

    @objc func shouldShowNotificationsRationale(_ call: CAPPluginCall) {
        call.resolve([
            "result": false
        ])
    }

    @objc func requestNotifications(_ call: CAPPluginCall) {
        checkPermissionStatus { status in
            guard status != .granted && status != .permanentlyDenied else {
                call.resolve(["result": status.rawValue])
                return
            }

            guard let options = call.getArray("options", String.self) else {
                call.reject("Missing authorization options.")
                return
            }

            let authorizationOptions = self.processNotificationAuthorizationOptions(options)

            self.notificationCenter.requestAuthorization(options: authorizationOptions) { (granted, error) in
                if error == nil {
                    call.resolve(granted ? ["result": PermissionStatus.granted.rawValue] : ["result": PermissionStatus.denied.rawValue])
                    return
                }

                call.reject("Unable to request notifications permission.", error?.localizedDescription)
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

    private func checkPermissionStatus(_ completion: @escaping (PermissionStatus) -> Void) {
        notificationCenter.getNotificationSettings { status in
            var permissionStatus = PermissionStatus.denied

            if status.authorizationStatus == .authorized {
                permissionStatus = PermissionStatus.granted
            }

            if status.authorizationStatus == .denied {
                permissionStatus = PermissionStatus.permanentlyDenied
            }

            completion(permissionStatus)
        }
    }
}
