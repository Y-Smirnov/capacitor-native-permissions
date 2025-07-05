import { registerPlugin } from '@capacitor/core';

import type { AuthorizationIosOptions, NotificationsStatus } from './models/permission-notifications';

export const NativePlugin = registerPlugin<NativePermissionsPlugin>('NativePermissionsPlugin', {
  web: () => import('./web').then((m) => new m.NativePermissionsWeb()),
});

export interface NativePermissionsPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;

  checkNotifications(): Promise<{ result: NotificationsStatus }>;

  shouldShowNotificationsRationale(): Promise<{ result: boolean }>;

  requestNotifications(options?: { options: AuthorizationIosOptions[] }): Promise<{ result: NotificationsStatus }>;
}
