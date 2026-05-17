import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'io.ysmirnov.example.permissions',
  appName: 'example-app',
  webDir: 'dist',

  experimental: {
    ios: {
      spm: {
        swiftToolsVersion: '6.1',
        packageTraits: {
          'capacitor-native-permissions': [
            'PERMISSION_NOTIFICATIONS',
            'PERMISSION_APP_TRACKING_TRANSPARENCY',
            'PERMISSION_BLUETOOTH',
            'PERMISSION_CALENDAR',
            'PERMISSION_REMINDERS',
            'PERMISSION_CAMERA',
            'PERMISSION_CONTACTS',
            'PERMISSION_MEDIA',
            'PERMISSION_RECORD',
            'PERMISSION_LOCATION_FOREGROUND',
            'PERMISSION_LOCATION_BACKGROUND',
          ],
        },
      },
    },
  },
};

export default config;
