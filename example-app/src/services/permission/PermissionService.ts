import { NativePermissions } from 'capacitor-native-permissions';

import { PermissionType } from './PermissionType';

export type CheckResult =
  | { type: PermissionType.Notifications; status: string }
  | { type: PermissionType.AppTrackingTransparency; status: string };

export async function checkPermission(type: PermissionType): Promise<CheckResult> {
  switch (type) {
    case PermissionType.Notifications: {
      const res = await NativePermissions.checkNotifications(); // { status, options? }
      return { type, status: res };
    }

    case PermissionType.AppTrackingTransparency: {
      const status = await NativePermissions.checkAppTrackingTransparency();
      return { type, status };
    }
  }
}

export async function shouldShowRationale(type: PermissionType): Promise<boolean> {
  switch (type) {
    case PermissionType.Notifications:
      return await NativePermissions.shouldShowNotificationsRationale();

    case PermissionType.AppTrackingTransparency:
      // Not applicable; return false by convention
      return false;
  }
}

export type RequestResult =
  | { type: PermissionType.Notifications; status: string }
  | { type: PermissionType.AppTrackingTransparency; status: string };

export async function requestPermission(type: PermissionType): Promise<RequestResult> {
  switch (type) {
    case PermissionType.Notifications: {
      const res = await NativePermissions.requestNotifications(); // { status, options? }
      return { type, status: res };
    }
    case PermissionType.AppTrackingTransparency: {
      const status = await NativePermissions.requestAppTrackingTransparency();
      return { type, status };
    }
  }
}
