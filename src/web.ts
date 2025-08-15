import { WebPlugin } from '@capacitor/core';

import type { AuthorizationIosOptions } from './models/permission-notifications';
import type { PermissionStatus } from './models/permission-status';
import type { NativePermissionsPlugin } from './plugin';

export class NativePermissionsWeb extends WebPlugin implements NativePermissionsPlugin {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  async echo(_options: { value: string }): Promise<{ value: string }> {
    throw this.unimplemented('Not implemented on web.');
  }

  checkNotifications(): Promise<{ result: PermissionStatus }> {
    throw this.unimplemented('Not implemented on web.');
  }

  shouldShowNotificationsRationale(): Promise<{ result: boolean }> {
    throw this.unimplemented('Not implemented on web.');
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  requestNotifications(_options?: { options: AuthorizationIosOptions[] }): Promise<{ result: PermissionStatus }> {
    throw new Error('Method not implemented.');
  }

  checkAppTrackingTransparency(): Promise<{ result: PermissionStatus }> {
    throw new Error('Method not implemented.');
  }
  requestAppTrackingTransparency(): Promise<{ result: PermissionStatus }> {
    throw new Error('Method not implemented.');
  }
}
