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
      return await NativePermissions.checkBluetooth(['scan', 'connect', 'advertise']);
    },
    request: async () => {
      return await NativePermissions.requestBluetooth(['scan', 'connect', 'advertise']);
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowBluetoothRationale(['scan', 'connect', 'advertise']);
    },
  },

  [SupportedPermissions.Calendar]: {
    check: async () => {
      return await NativePermissions.checkCalendar(['read', 'write'], 'full');
    },
    request: async () => {
      return await NativePermissions.requestCalendar(['read', 'write'], 'full');
    },
    shouldShowRationale: async () => {
      return await NativePermissions.shouldShowCalendarRationale(['read', 'write']);
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
};
