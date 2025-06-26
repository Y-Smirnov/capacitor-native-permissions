import { WebPlugin } from '@capacitor/core';

import type { NativePermissionsPlugin } from './plugin';

export class NativePermissionsWeb extends WebPlugin implements NativePermissionsPlugin {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  async echo(_options: { value: string }): Promise<{ value: string }> {
    throw this.unimplemented('Not implemented on web.');
  }
}
