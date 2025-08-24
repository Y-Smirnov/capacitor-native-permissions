import { Capacitor } from '@capacitor/core';

import type { BluetoothAndroidOptions } from './models/bluetooth-android-permissions';
import type { AuthorizationIosOptions } from './models/permission-notifications';
import { PermissionStatus } from './models/permission-status';
import { SupportedPermissions } from './models/supported-permissions';
import { NativePlugin } from './plugin';

export class NativePermissions {
  public static async echo(options: { value: string }): Promise<{ value: string }> {
    return await NativePlugin.echo(options);
  }

  // Notifications

  public static async checkNotifications(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.check({ permission: SupportedPermissions.Notifications });
    return result;
  }

  public static async shouldShowNotificationsRationale(): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowRationale({ permission: SupportedPermissions.Notifications });
      return result;
    }

    return false;
  }

  public static async requestNotifications(options?: AuthorizationIosOptions[]): Promise<PermissionStatus> {
    const { result } = await NativePlugin.request({
      permission: SupportedPermissions.Notifications,
      options: options ?? ['badge', 'alert', 'sound'],
    });

    return result;
  }

  // App Tracking

  public static async checkAppTrackingTransparency(): Promise<PermissionStatus> {
    if (Capacitor.getPlatform() == 'ios') {
      const { result } = await NativePlugin.check({ permission: SupportedPermissions.AppTrackingTransparency });
      return result;
    }

    return PermissionStatus.NOT_APPLICABLE;
  }

  public static async requestAppTrackingTransparency(): Promise<PermissionStatus> {
    if (Capacitor.getPlatform() == 'ios') {
      const { result } = await NativePlugin.request({ permission: SupportedPermissions.AppTrackingTransparency });
      return result;
    }

    return PermissionStatus.NOT_APPLICABLE;
  }

  // Bluetooth

  public static async checkBluetooth(options: BluetoothAndroidOptions[]): Promise<PermissionStatus> {
    const { result } = await NativePlugin.check({ permission: SupportedPermissions.Bluetooth, options: options });
    return result;
  }

  public static async shouldShowBluetoothRationale(options: BluetoothAndroidOptions[]): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowRationale({
        permission: SupportedPermissions.Bluetooth,
        options: options,
      });

      return result;
    }

    return false;
  }

  public static async requestBluetooth(options: BluetoothAndroidOptions[]): Promise<PermissionStatus> {
    const { result } = await NativePlugin.request({ permission: SupportedPermissions.Bluetooth, options: options });
    return result;
  }
}
