import { NativePlugin } from './plugin';

export class NativePermissions {
  public static async echo(options: { value: string }): Promise<{ value: string }> {
    return await NativePlugin.echo(options);
  }
}
