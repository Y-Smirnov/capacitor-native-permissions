import { registerPlugin } from '@capacitor/core';

export const NativePlugin = registerPlugin<NativePermissionsPlugin>('NativePermissions', {
  web: () => import('./web').then((m) => new m.NativePermissionsWeb()),
});

export interface NativePermissionsPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
