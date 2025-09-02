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

#if PERMISSION_LOCATION_FOREGROUND
    public override func load() {
        Task { @MainActor in
            _ = Location.instance
        }
    }
#endif

    @objc func check(_ call: CAPPluginCall) {
        guard let permission = getPermission(call) else {
            call.reject("Missing permission parameter.")
            return
        }

        Task {
            do {
                var status: PermissionStatus = .denied

                switch permission {
#if PERMISSION_NOTIFICATIONS
                case .notifications:
                    status = await Notifications.instance.checkStatus()
#endif

#if PERMISSION_APP_TRACKING_TRANSPARENCY
                case .appTrackingTransparency:
                    status = AppTrackingTransparency.instance.checkStatus()
#endif

#if PERMISSION_BLUETOOTH
                case .bluetooth:
                    status = Bluetooth.instance.checkStatus()
#endif

#if PERMISSION_CALENDAR
                case .calendar:
                    status = Calendar.instance.checkStatus()
#endif

#if PERMISSION_REMINDERS
                case .reminders:
                    status = Reminders.instance.checkStatus()
#endif

#if PERMISSION_CAMERA
                case .camera:
                    status = Camera.instance.checkStatus()
#endif

#if PERMISSION_CONTACTS
                case .contacts:
                    status = Contacts.instance.checkStatus()
#endif

#if PERMISSION_MEDIA
                case .media:
                    status = MediaLibrary.instance.checkStatus()
#endif

#if PERMISSION_RECORD
                case .record:
                    status = Audio.instance.checkRecordPermission()
#endif

#if PERMISSION_LOCATION_FOREGROUND
                case .locationForeground:
                    status =  await Location.instance.checkForegroundStatus()

#endif

#if PERMISSION_LOCATION_BACKGROUND
                case .locationBackground:
                    status = await Location.instance.checkBackgroundStatus()
#endif
                default:
                    call.reject("Unable to check \(permission.rawValue) permission. Ensure you added permission flag in your Podfile.")
                    return
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
#if PERMISSION_NOTIFICATIONS
                case .notifications:
                    guard let options = getOptions(call) else {
                        call.reject("Missing authorization options.")
                        return
                    }

                    status = try await Notifications.instance.requestPermission(options)
#endif

#if PERMISSION_APP_TRACKING_TRANSPARENCY
                case .appTrackingTransparency:
                    status = await AppTrackingTransparency.instance.requestPermission()
#endif

#if PERMISSION_BLUETOOTH
                case .bluetooth:
                    status = await Bluetooth.instance.requestPermission()
#endif

#if PERMISSION_CALENDAR
                case .calendar:
                    status = try await Calendar.instance.requestPermission()
#endif

#if PERMISSION_REMINDERS
                case .reminders:
                    status = try await Reminders.instance.requestPermission()
#endif

#if PERMISSION_CAMERA
                case .camera:
                    status = await Camera.instance.requestPermission()
#endif

#if PERMISSION_CONTACTS
                case .contacts:
                    status = try await Contacts.instance.requestPermisison()
#endif

#if PERMISSION_MEDIA
                case .media:
                    status = await MediaLibrary.instance.requestPermisison()
#endif

#if PERMISSION_RECORD
                case .record:
                    status = await Audio.instance.requestRecordPermission()
#endif

#if PERMISSION_LOCATION_FOREGROUND
                case .locationForeground:
                    status =  await Location.instance.requestForegroundPermission()
#endif

#if PERMISSION_LOCATION_BACKGROUND
                case .locationBackground:
                    status = await Location.instance.requestBackgroundPermission()
#endif

                default:
                    call.reject("Unable to request \(permission.rawValue) permission. Ensure you added permission flag in your Podfile.")
                    return
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
