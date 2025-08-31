import type { PermissionStatus } from 'capacitor-native-permissions';
import { NativePermissions, SupportedPermissions } from 'capacitor-native-permissions';

export type PermissionHandlers = {
  check: () => Promise<PermissionStatus>;
  request: () => Promise<PermissionStatus>;
  shouldShowRationale?: () => Promise<boolean>;
};

export const permissionRegistry: Record<SupportedPermissions, PermissionHandlers> = {
  [SupportedPermissions.Notifications]: {
    check: async () => {
      return await NativePermissions.checkNotifications();
    },
    request: async () => {
      return await NativePermissions.requestNotifications();
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowNotificationsRationale();
    },
  },

  [SupportedPermissions.AppTrackingTransparency]: {
    check: async () => {
      return await NativePermissions.checkAppTrackingTransparency();
    },
    request: async () => {
      return await NativePermissions.requestAppTrackingTransparency();
    },
  },

  [SupportedPermissions.Bluetooth]: {
    check: async () => {
      return await NativePermissions.checkBluetooth();
    },
    request: async () => {
      return await NativePermissions.requestBluetooth();
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowBluetoothRationale();
    },
  },

  [SupportedPermissions.Calendar]: {
    check: async () => {
      return await NativePermissions.checkCalendar();
    },
    request: async () => {
      return await NativePermissions.requestCalendar();
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowCalendarRationale();
    },
  },

  [SupportedPermissions.Reminders]: {
    check: async () => {
      return await NativePermissions.checkReminders();
    },
    request: async () => {
      return await NativePermissions.requestReminders();
    },
  },

  [SupportedPermissions.Camera]: {
    check: async () => {
      return await NativePermissions.checkCamera();
    },
    request: async () => {
      return await NativePermissions.requestCamera();
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowCameraRationale();
    },
  },

  [SupportedPermissions.Contacts]: {
    check: async () => {
      return await NativePermissions.checkContacts();
    },
    request: async () => {
      return await NativePermissions.requestContacts();
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowContactsRationale();
    },
  },

  [SupportedPermissions.Media]: {
    check: async () => {
      return await NativePermissions.checkMedia();
    },
    request: async () => {
      return await NativePermissions.requestMedia();
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowMediaRationale();
    },
  },

  [SupportedPermissions.Record]: {
    check: async () => {
      return await NativePermissions.checkAudioRecord();
    },
    request: async () => {
      return await NativePermissions.requestAudioRecord();
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowAudioRecordRationale();
    },
  },

  [SupportedPermissions.LocationForeground]: {
    check: async () => {
      return await NativePermissions.checkLocationForeground();
    },
    request: async () => {
      return await NativePermissions.requestLocationForeground();
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowLocationForegroundRationale();
    },
  },

  [SupportedPermissions.LocationBackground]: {
    check: async () => {
      return await NativePermissions.checkLocationBackground();
    },
    request: async () => {
      return await NativePermissions.requestLocationBackground();
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowLocationBackgroundRationale();
    },
  },
};
