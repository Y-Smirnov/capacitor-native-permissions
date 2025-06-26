import { NativePermissions } from 'capacitor-native-permissions';

window.testEcho = () => {
  const inputValue = document.getElementById('echoInput').value;
  NativePermissions.echo({ value: inputValue });
};
