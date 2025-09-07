import { Capacitor } from '@capacitor/core';

import type { NotificationsAuthorizationOptionsIos } from './models/notifications-authorization-options-ios';
import { PermissionStatus } from './models/permission-status';
import { SupportedPermissions } from './models/supported-permissions';
import { NativePlugin } from './plugin';

export class NativePermissions {
  // Common

  public static async showRationale(
    title: string,
    message: string,
    positiveButton?: string,
    negativeButton?: string,
  ): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.showRationale({
        title: title,
        message: message,
        positiveButton: positiveButton,
        negativeButton: negativeButton,
      });

      return result;
    }

    return true;
  }

  public static async openAppSettings(waitUntilReturn: boolean): Promise<void> {
    await NativePlugin.openAppSettings({ waitUntilReturn });
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

  public static async requestNotifications(
    options?: NotificationsAuthorizationOptionsIos[],
  ): Promise<PermissionStatus> {
    if (Capacitor.getPlatform() == 'ios') {
      const { result } = await NativePlugin.request({
        permission: SupportedPermissions.Notifications,
        options: options ?? ['badge', 'alert', 'sound'],
      });

      return result;
    }

    const { result } = await NativePlugin.request({
      permission: SupportedPermissions.Notifications,
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

  public static async checkBluetooth(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.check({ permission: SupportedPermissions.Bluetooth });
    return result;
  }

  public static async shouldShowBluetoothRationale(): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowRationale({
        permission: SupportedPermissions.Bluetooth,
      });

      return result;
    }

    return false;
  }

  public static async requestBluetooth(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.request({ permission: SupportedPermissions.Bluetooth });
    return result;
  }

  // Calendar

  public static async checkCalendar(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.check({
      permission: SupportedPermissions.Calendar,
    });

    return result;
  }

  public static async shouldShowCalendarRationale(): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowRationale({
        permission: SupportedPermissions.Calendar,
      });

      return result;
    } else {
      return false;
    }
  }

  public static async requestCalendar(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.request({
      permission: SupportedPermissions.Calendar,
    });

    return result;
  }

  // Reminders (iOS only)

  public static async checkReminders(): Promise<PermissionStatus> {
    if (Capacitor.getPlatform() == 'ios') {
      const { result } = await NativePlugin.check({ permission: SupportedPermissions.Reminders });
      return result;
    }

    return PermissionStatus.NOT_APPLICABLE;
  }

  public static async requestReminders(): Promise<PermissionStatus> {
    if (Capacitor.getPlatform() == 'ios') {
      const { result } = await NativePlugin.request({ permission: SupportedPermissions.Reminders });
      return result;
    }

    return PermissionStatus.NOT_APPLICABLE;
  }

  // Camera

  public static async checkCamera(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.check({ permission: SupportedPermissions.Camera });
    return result;
  }

  public static async shouldShowCameraRationale(): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowRationale({ permission: SupportedPermissions.Camera });
      return result;
    }

    return false;
  }

  public static async requestCamera(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.request({
      permission: SupportedPermissions.Camera,
    });

    return result;
  }

  // Contacts

  public static async checkContacts(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.check({ permission: SupportedPermissions.Contacts });
    return result;
  }

  public static async shouldShowContactsRationale(): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowRationale({
        permission: SupportedPermissions.Contacts,
      });

      return result;
    }

    return false;
  }

  public static async requestContacts(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.request({ permission: SupportedPermissions.Contacts });
    return result;
  }

  // Media

  public static async checkMedia(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.check({ permission: SupportedPermissions.Media });
    return result;
  }

  public static async shouldShowMediaRationale(): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowRationale({ permission: SupportedPermissions.Media });
      return result;
    }

    return false;
  }

  public static async requestMedia(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.request({ permission: SupportedPermissions.Media });
    return result;
  }

  // Record

  public static async checkAudioRecord(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.check({ permission: SupportedPermissions.Record });
    return result;
  }

  public static async shouldShowAudioRecordRationale(): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowRationale({ permission: SupportedPermissions.Record });
      return result;
    }

    return false;
  }

  public static async requestAudioRecord(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.request({
      permission: SupportedPermissions.Record,
    });

    return result;
  }

  // Location

  public static async checkLocationForeground(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.check({
      permission: SupportedPermissions.LocationForeground,
    });

    return result;
  }

  public static async shouldShowLocationForegroundRationale(): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowRationale({
        permission: SupportedPermissions.LocationForeground,
      });

      return result;
    }

    return false;
  }

  public static async requestLocationForeground(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.request({
      permission: SupportedPermissions.LocationForeground,
    });

    return result;
  }

  public static async checkLocationBackground(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.check({
      permission: SupportedPermissions.LocationBackground,
    });

    return result;
  }

  public static async shouldShowLocationBackgroundRationale(): Promise<boolean> {
    if (Capacitor.getPlatform() == 'android') {
      const { result } = await NativePlugin.shouldShowRationale({
        permission: SupportedPermissions.LocationBackground,
      });

      return result;
    }

    return false;
  }

  public static async requestLocationBackground(): Promise<PermissionStatus> {
    const { result } = await NativePlugin.request({
      permission: SupportedPermissions.LocationBackground,
    });

    return result;
  }
}
