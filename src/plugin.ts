import { registerPlugin } from '@capacitor/core';

// import type { AuthorizationIosOptions } from './models/permission-notifications';
import type { PermissionStatus } from './models/permission-status';
import type { SupportedPermissions } from './models/supported-permissions';

export const NativePlugin = registerPlugin<NativePermissionsPlugin>('NativePermissionsPlugin', {
  web: () => import('./web').then((m) => new m.NativePermissionsWeb()),
});

export interface NativePermissionsPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;

  check(options: { permission: SupportedPermissions }): Promise<{ result: PermissionStatus }>;

  shouldShowRationale(options: { permission: SupportedPermissions }): Promise<{ result: boolean }>;

  request(options: { permission: SupportedPermissions; options?: string[] }): Promise<{ result: PermissionStatus }>;
}
