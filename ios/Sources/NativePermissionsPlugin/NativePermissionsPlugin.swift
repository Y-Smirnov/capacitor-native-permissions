import Foundation
import Capacitor

@objc(NativePermissionsPlugin)
public class NativePermissionsPlugin: CAPPlugin, CAPBridgedPlugin {
    private let notificationCenter = UNUserNotificationCenter.current()

    public let identifier = "NativePermissionsPlugin"
    public let jsName = "NativePermissionsPlugin"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "check", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "request", returnType: CAPPluginReturnPromise),
    ]

    private let implementation = NativePermissions()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    @objc func check(_ call: CAPPluginCall) {
        guard let permission = getPermission(call) else {
            call.reject("Missing 'permission' parameter.")
            return
        }

        Task {
            do {
                var status: PermissionStatus = .denied

                switch permission {
                case .notifications:
                    status = await Notifications.instance.checkStatus()

                case .appTrackingTransparency:
                    status = AppTrackingTransparency.instance.checkStatus()
                }

                call.resolve(["result": status.rawValue])
            }
        }
    }

    @objc func request(_ call: CAPPluginCall) {
        guard let permission = getPermission(call) else {
            call.reject("Missing 'permission' parameter.")
            return
        }

        Task {
            do {
                var status: PermissionStatus = .denied

                switch permission {

                case .notifications:
                    guard let options = call.getArray("options", String.self) else {
                        call.reject("Missing authorization options.")
                        return
                    }

                    status = try await Notifications.instance.requestPermission(options)

                case .appTrackingTransparency:
                    status = await AppTrackingTransparency.instance.requestPermission()
                }

                call.resolve(["result": status.rawValue])
            } catch {
                call.reject("Unable to request \(permission.rawValue) permission.", error.localizedDescription)
            }
        }
    }

    private func getPermission(_ call: CAPPluginCall) -> AppPermission? {
        guard let permission = call.getString("permission") else {
            return nil
        }

        return AppPermission.allCases.first { $0.rawValue.caseInsensitiveCompare(permission) == .orderedSame }
    }

    private enum AppPermission: String, CaseIterable {
        case notifications
        case appTrackingTransparency
    }
}
