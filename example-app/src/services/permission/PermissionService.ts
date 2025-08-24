import type { PermissionStatus } from 'capacitor-native-permissions';
import { NativePermissions } from 'capacitor-native-permissions';

import { PermissionType } from './PermissionType';

export type PermissionHandlers = {
  check: () => Promise<PermissionStatus>;
  request: () => Promise<PermissionStatus>;
  shouldShowRationale?: () => Promise<boolean>;
};

export const permissionRegistry: Record<PermissionType, PermissionHandlers> = {
  [PermissionType.Notifications]: {
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

  [PermissionType.AppTrackingTransparency]: {
    check: async () => {
      return await NativePermissions.checkAppTrackingTransparency();
    },
    request: async () => {
      return await NativePermissions.requestAppTrackingTransparency();
    },
  },

  [PermissionType.Bluetooth]: {
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
};
