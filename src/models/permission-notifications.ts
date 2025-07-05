import type { PermissionStatus } from './permission-status';

export type AuthorizationIosOptions =
  | 'alert'
  | 'badge'
  | 'sound'
  | 'carPlay'
  | 'criticalAlert'
  | 'provisional'
  | 'providesAppSettings';

export type NotificationsStatus = {
  status: PermissionStatus;
  options?: AuthorizationIosOptions;
};
