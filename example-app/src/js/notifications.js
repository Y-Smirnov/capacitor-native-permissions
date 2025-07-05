import { NativePermissions } from 'capacitor-native-permissions';

window.checkNotificationsPermission = async () => {
  const result = await NativePermissions.checkNotifications();

  window.alert(`Notifications permission status: ${result}`);
};

window.checkShouldShowNotificationsRationale = async () => {
  const result = await NativePermissions.shouldShowNotificationsRationale();

  window.alert(`Notifications should show rationale: ${result}`);
};

window.requestNotificationsPermission = async () => {
  const result = await NativePermissions.requestNotifications();

  window.alert(`Notifications permission request result: ${result}`);
};
