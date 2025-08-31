import Foundation
import Capacitor

@objc(NativePermissionsPlugin)
public class NativePermissionsPlugin: CAPPlugin, CAPBridgedPlugin {
    private let notificationCenter = UNUserNotificationCenter.current()

    public let identifier = "NativePermissionsPlugin"
    public let jsName = "NativePermissionsPlugin"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "check", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "request", returnType: CAPPluginReturnPromise),
    ]

    public override func load() {
        Task { @MainActor in
            _ = Location.instance
        }
    }

    @objc func check(_ call: CAPPluginCall) {
        guard let permission = getPermission(call) else {
            call.reject("Missing permission parameter.")
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

                case .bluetooth:
                    status = Bluetooth.instance.checkStatus()

                case .calendar:
                    status = EventStore.instance.checkCalendarStatus()

                case .reminders:
                    status = EventStore.instance.checkReminderStatus()

                case .camera:
                    status = Camera.instance.checkStatus()

                case .contacts:
                    status = Contacts.instance.checkStatus()

                case .media:
                    status = MediaLibrary.instance.checkStatus()

                case .record:
                    status = Audio.instance.checkRecordPermission()

                case .locationForeground:
                    status =  await Location.instance.checkForegroundStatus()

                case .locationBackground:
                    status = await Location.instance.checkBackgroundStatus()
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
                    guard let options = getOptions(call) else {
                        call.reject("Missing authorization options.")
                        return
                    }

                    status = try await Notifications.instance.requestPermission(options)

                case .appTrackingTransparency:
                    status = await AppTrackingTransparency.instance.requestPermission()

                case .bluetooth:
                    status = await Bluetooth.instance.requestPermission()

                case .calendar:
                    status = try await EventStore.instance.requestCalendarPermission()

                case .reminders:
                    status = try await EventStore.instance.requestReminderPermission()

                case .camera:
                    status = await Camera.instance.requestPermission()

                case .contacts:
                    status = try await Contacts.instance.requestPermisison()

                case .media:
                    status = await MediaLibrary.instance.requestPermisison()

                case .record:
                    status = await Audio.instance.requestRecordPermission()

                case .locationForeground:
                    status =  await Location.instance.requestForegroundPermission()

                case .locationBackground:
                    status = await Location.instance.requestBackgroundPermission()
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

    private func getOptions(_ call: CAPPluginCall) -> Array<String>? {
        return call.getArray("options", String.self)
    }

    private enum AppPermission: String, CaseIterable {
        case notifications
        case appTrackingTransparency
        case bluetooth
        case calendar
        case reminders
        case camera
        case contacts
        case media
        case record
        case locationForeground
        case locationBackground
    }
}
