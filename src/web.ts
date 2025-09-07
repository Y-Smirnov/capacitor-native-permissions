import { WebPlugin } from '@capacitor/core';

import type { PermissionStatus } from './models/permission-status';
import type { SupportedPermissions } from './models/supported-permissions';
import type { NativePermissionsPlugin } from './plugin';

export class NativePermissionsWeb extends WebPlugin implements NativePermissionsPlugin {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  check(_options: { permission: SupportedPermissions }): Promise<{ result: PermissionStatus }> {
    throw new Error('Method not implemented.');
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  shouldShowRationale(_options: { permission: SupportedPermissions }): Promise<{ result: boolean }> {
    throw new Error('Method not implemented.');
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  showRationale(_options: {
    title: string;
    message: string;
    positiveButton?: string;
    negativeButton?: string;
  }): Promise<{ result: boolean }> {
    return Promise.resolve({ result: false });
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  request(_options: {
    permission: SupportedPermissions;
    options?: string[] | undefined;
  }): Promise<{ result: PermissionStatus }> {
    throw new Error('Method not implemented.');
  }

  openAppSettings(): Promise<void> {
    throw new Error('Method not implemented.');
  }
}
