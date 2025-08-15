import { Capacitor } from '@capacitor/core';

import type { AuthorizationIosOptions } from './models/permission-notifications';
import { PermissionStatus } from './models/permission-status';
import { NativePlugin } from './plugin';

export class NativePermissions {
  public static async echo(options: { value: string }): Promise<{ value: string }> {
    return await NativePlugin.echo(options);
  }

  // Notifications

  public static async checkNotifications(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.checkNotifications();
    return result;
  }

  public static async shouldShowNotificationsRationale(): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowNotificationsRationale();
      return result;
    }

    return false;
  }

  public static async requestNotifications(options?: AuthorizationIosOptions[]): Promise<PermissionStatus> {
    const { result } = await NativePlugin.requestNotifications({ options: options ?? ['badge', 'alert', 'sound'] });
    return result;
  }

  // App Tracking

  public static async checkAppTrackingTransparency(): Promise<PermissionStatus> {
    if (Capacitor.getPlatform() == 'ios') {
      const { result } = await NativePlugin.checkAppTrackingTransparency();
      return result;
    }

    return PermissionStatus.NOT_APPLICABLE;
  }

  public static async requestAppTrackingTransparency(): Promise<PermissionStatus> {
    if (Capacitor.getPlatform() == 'ios') {
      const { result } = await NativePlugin.requestAppTrackingTransparency();
      return result;
    }

    return PermissionStatus.NOT_APPLICABLE;
  }
}
