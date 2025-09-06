import { registerPlugin } from '@capacitor/core';

import type { PermissionStatus } from './models/permission-status';
import type { SupportedPermissions } from './models/supported-permissions';

export const NativePlugin = registerPlugin<NativePermissionsPlugin>('NativePermissionsPlugin', {
  web: () => import('./web').then((m) => new m.NativePermissionsWeb()),
});

export interface NativePermissionsPlugin {
  check(options: { permission: SupportedPermissions }): Promise<{ result: PermissionStatus }>;

  shouldShowRationale(options: { permission: SupportedPermissions }): Promise<{ result: boolean }>;

  showRationale(options: {
    title: string;
    message: string;
    positiveButton?: string;
    negativeButton?: string;
  }): Promise<{ result: boolean }>;

  request(options: { permission: SupportedPermissions; options?: string[] }): Promise<{ result: PermissionStatus }>;

  openAppSettings(): Promise<void>;
}
