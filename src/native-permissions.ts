import { Capacitor } from '@capacitor/core';

import type { AuthorizationIosOptions, NotificationsStatus } from './models/permission-notifications';
import { NativePlugin } from './plugin';

export class NativePermissions {
  public static async echo(options: { value: string }): Promise<{ value: string }> {
    return await NativePlugin.echo(options);
  }

  // Notifications

  public static async checkNotifications(): Promise<NotificationsStatus> {
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

  public static async requestNotifications(options?: AuthorizationIosOptions[]): Promise<NotificationsStatus> {
    const { result } = await NativePlugin.requestNotifications({ options: options ?? ['badge', 'alert', 'sound'] });
    return result;
  }
}
