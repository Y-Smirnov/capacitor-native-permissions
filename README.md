# capacitor-native-permissions

A Capacitor plugin for requesting and managing native permissions on Android and iOS.

## Supported permissions

- Notifications
- App Tracking Transparency (iOS only)
- Bluetooth
- Calendar
- Reminders (iOS only)
- Camera
- Contacts
- Media
- Record (Microphone)
- Location (Foreground and Background)

## Setup

### Install

```bash
npm install capacitor-native-permissions
npx cap sync
```

### iOS

In iOS, no permissions are available by default. Edit the following section in your Podfile and uncomment the permissions you need:

```ruby
post_install do |installer|
  assertDeploymentTarget(installer)

  installer.pods_project.targets.each do |target|
    next unless target.name == 'CapacitorNativePermissions'

    target.build_configurations.each do |config|
      enabled_flags = [
#         'PERMISSION_NOTIFICATIONS',
#         'PERMISSION_APP_TRACKING_TRANSPARENCY',
#         'PERMISSION_BLUETOOTH',
#         'PERMISSION_CALENDAR',
#         'PERMISSION_REMINDERS',
#         'PERMISSION_CAMERA',
#         'PERMISSION_CONTACTS',
#         'PERMISSION_MEDIA',
#         'PERMISSION_RECORD',
#         'PERMISSION_LOCATION_FOREGROUND',
#         'PERMISSION_LOCATION_BACKGROUND',
      ]

      current_swift_flags = config.build_settings['OTHER_SWIFT_FLAGS'] || '$(inherited)'
      config.build_settings['OTHER_SWIFT_FLAGS'] = [current_swift_flags, *enabled_flags.map { |f| "-D#{f}" }].join(' ')
    end
  end
end
```

Add corresponding permissions usage description in your Info.plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>NSBluetoothAlwaysUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSCalendarsFullAccessUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSCalendarsWriteOnlyAccessUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSCameraUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSContactsUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSLocationWhenInUseUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSMicrophoneUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSPhotoLibraryAddUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSPhotoLibraryUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSRemindersFullAccessUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSRemindersUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
        <key>NSUserTrackingUsageDescription</key>
        <string>Use this field to describe usage reason.</string>
    </dict>
</plist>
```

### Android

Add used permissions to your AndroidManifest.xml:
Note: Make sure to keep only the permissions you need.

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<uses-permission android:name="android.permission.BLUETOOTH"
                 android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"
                 android:maxSdkVersion="30" />


<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />

<uses-permission android:name="android.permission.CAMERA" />

<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WRITE_CONTACTS" />

<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />

<uses-permission android:name="android.permission.RECORD_AUDIO" />

<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

## Permission statuses

- `PermissionStatus.GRANTED`
- `PermissionStatus.DENIED`
- `PermissionStatus.RESTRICTED`
- `PermissionStatus.PERMANENTLY_DENIED`
- `PermissionStatus.NOT_APPLICABLE`

If a permission is not applicable on the current platform (for example, requesting appTrackingTransparency on Android), the result will be PermissionStatus.NOT_APPLICABLE.

Platform nuance:
- Only iOS can return PERMANENTLY_DENIED when checking permission status.
- Both platforms can return PERMANENTLY_DENIED when a permission is permanently blocked (i.e., no request will be shown). In this case, you may guide the user to system settings.

## Public API

Notifications:
- `NativePermissions.checkNotifications(): Promise<PermissionStatus>`
- `NativePermissions.shouldShowNotificationsRationale(): Promise<boolean>` (Android only)
- `NativePermissions.requestNotifications(options?: NotificationsAuthorizationOptionsIos[]): Promise<PermissionStatus>`
    - On iOS, options defaults to ['badge', 'alert', 'sound'] when not defined.
    - On Android, options are ignored.

App Tracking Transparency (iOS only):
- `NativePermissions.checkAppTrackingTransparency(): Promise<PermissionStatus>`
- `NativePermissions.requestAppTrackingTransparency(): Promise<PermissionStatus>`
    - Returns PermissionStatus.NOT_APPLICABLE on Android.

Bluetooth:
- `NativePermissions.checkBluetooth(): Promise<PermissionStatus>`
- `NativePermissions.shouldShowBluetoothRationale(): Promise<boolean>` (Android only, returns always false on iOS)
- `NativePermissions.requestBluetooth(): Promise<PermissionStatus>`

Calendar:
- `NativePermissions.checkCalendar(): Promise<PermissionStatus>`
- `NativePermissions.shouldShowCalendarRationale(): Promise<boolean>` (Android only, returns always false on iOS)
- `NativePermissions.requestCalendar(): Promise<PermissionStatus>`

Reminders (iOS only):
- `NativePermissions.checkReminders(): Promise<PermissionStatus>`
- `NativePermissions.requestReminders(): Promise<PermissionStatus>`
    - Returns PermissionStatus.NOT_APPLICABLE on non‑iOS.

Camera:
- `NativePermissions.checkCamera(): Promise<PermissionStatus>`
- `NativePermissions.shouldShowCameraRationale(): Promise<boolean>` (Android only, returns always false on iOS)
- `NativePermissions.requestCamera(): Promise<PermissionStatus>`

Contacts:
- `NativePermissions.checkContacts(): Promise<PermissionStatus>`
- `NativePermissions.shouldShowContactsRationale(): Promise<boolean>` (Android only, returns always false on iOS)
- `NativePermissions.requestContacts(): Promise<PermissionStatus>`

Media (Photos/Media Library):
- `NativePermissions.checkMedia(): Promise<PermissionStatus>`
- `NativePermissions.shouldShowMediaRationale(): Promise<boolean>` (Android only, returns always false on iOS)
- `NativePermissions.requestMedia(): Promise<PermissionStatus>`

Record (Microphone):
- `NativePermissions.checkAudioRecord(): Promise<PermissionStatus>`
- `NativePermissions.shouldShowAudioRecordRationale(): Promise<boolean>` (Android only, returns always false on iOS)
- `NativePermissions.requestAudioRecord(): Promise<PermissionStatus>`

Location (Foreground):
- `NativePermissions.checkLocationForeground(): Promise<PermissionStatus>`
- `NativePermissions.shouldShowLocationForegroundRationale(): Promise<boolean>` (Android only, returns always false on iOS)
- `NativePermissions.requestLocationForeground(): Promise<PermissionStatus>`

Location (Background):
- `NativePermissions.checkLocationBackground(): Promise<PermissionStatus>`
- `NativePermissions.shouldShowLocationBackgroundRationale(): Promise<boolean>` (Android only, returns always false on iOS)
- `NativePermissions.requestLocationBackground(): Promise<PermissionStatus>`

## Usage Examples

#### Basic usage
Check → should show rationale → if `true`, show rationale → request → return result

```typescript
  async function ensureNotificationsPermission(): Promise<boolean> {
  const status = await NativePermissions.checkNotifications();

  if (status === PermissionStatus.GRANTED) return true;

  if (await NativePermissions.shouldShowNotificationsRationale()) {
    await NativePermissions.showRationale(
      'Permission required',
      'Allow notifications in order to receive relevant updates.',
      'Continue',
    );
  }

  const result = await NativePermissions.requestNotifications();

  return result === PermissionStatus.GRANTED;
}
```

#### Advanced usage
Check → should show rationale → if `true`, show rationale → request → if `PERMANENTLY_DENIED`, forward to settings when permanently denied → check again → return result

```typescript
  async function ensureNotificationsPermission(): Promise<boolean> {
  const status = await NativePermissions.checkNotifications();

  if (status === PermissionStatus.GRANTED) return true;

  if (await NativePermissions.shouldShowNotificationsRationale()) {
    await NativePermissions.showRationale(
      'Permission required',
      'Allow notifications in order to receive relevant updates.',
      'Continue',
    );
  }

  const result = await NativePermissions.requestNotifications();

  // Return result after permission prompt answer
  if (result !== PermissionStatus.PERMANENTLY_DENIED) {
    return result === PermissionStatus.GRANTED;
  }

  // Taking action when no prompt is shown as the permission is already permanently denied
  const shouldForwardToAppSettings = await NativePermissions.showRationale(
    'Permission required',
    'Enable notifications in app settings in order to receive relevant updates.',
    'Continue',
    'Cancel',
  );

  if (shouldForwardToAppSettings) {
    // Passing true to openAppSettings and wait until the user to return to the app
    await NativePermissions.openAppSettings(true);
    const status = await NativePermissions.checkNotifications();

    return status === PermissionStatus.GRANTED;
  }

  return false;
}
```

## Behavior notes and edge cases

- PERMANENTLY_DENIED means the system won’t prompt anymore. Direct users to system settings to change it.
- RESTRICTED indicates a policy or parental-control block; treat it as non‑grantable.
- Some permissions are platform‑specific. When permission does not apply to current platforms you’ll get `NOT_APPLICABLE`.
- Rationale helpers are Android-only and return false on iOS.
- For background location, foreground must be granted first.

## License

MIT
