import { registerPlugin } from '@capacitor/core';

import type { AuthorizationIosOptions } from './models/permission-notifications';
import type { PermissionStatus } from './models/permission-status';

export const NativePlugin = registerPlugin<NativePermissionsPlugin>('NativePermissionsPlugin', {
  web: () => import('./web').then((m) => new m.NativePermissionsWeb()),
});

export interface NativePermissionsPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;

  checkNotifications(): Promise<{ result: PermissionStatus }>;

  shouldShowNotificationsRationale(): Promise<{ result: boolean }>;

  requestNotifications(options?: { options: AuthorizationIosOptions[] }): Promise<{ result: PermissionStatus }>;

  checkAppTrackingTransparency(): Promise<{ result: PermissionStatus }>;

  requestAppTrackingTransparency(): Promise<{ result: PermissionStatus }>;
}
