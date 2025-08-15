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
        CAPPluginMethod(name: "requestNotifications", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "checkAppTrackingTransparency", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestAppTrackingTransparency", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = NativePermissions()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
}

// Notifications
extension NativePermissionsPlugin {
    @objc func checkNotifications(_ call: CAPPluginCall) {
        Task {
            let status = await Notifications.instance.checkStatus()
            call.resolve(["result": status.rawValue])
        }
    }

    @objc func shouldShowNotificationsRationale(_ call: CAPPluginCall) {
        call.resolve([
            "result": false
        ])
    }

    @objc func requestNotifications(_ call: CAPPluginCall) {
        guard let options = call.getArray("options", String.self) else {
            call.reject("Missing authorization options.")
            return
        }

        Task {
            do {
                let status = try await Notifications.instance.requestPermission(options)
                call.resolve(["result": status.rawValue])
            } catch {
                call.reject("Unable to request notifications permission.", error.localizedDescription)
            }
        }
    }
}

// App Tracking

extension NativePermissionsPlugin {
    @objc func checkAppTrackingTransparency(_ call: CAPPluginCall) {
        let status = AppTrackingTransparency.instance.checkStatus()
        call.resolve(["result": status.rawValue])
    }

    @objc func requestAppTrackingTransparency(_ call: CAPPluginCall) {
        Task {
            let status = await AppTrackingTransparency.instance.requestPermission()
            call.resolve(["result": status.rawValue])
        }
    }
}
