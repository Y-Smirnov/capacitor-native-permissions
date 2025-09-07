import { IonContent, IonHeader, IonPage, IonTitle, IonToast, IonToolbar } from '@ionic/react';
import { NativePermissions, PermissionStatus, SupportedPermissions } from 'capacitor-native-permissions';
import React, { useCallback, useMemo, useState } from 'react';

import '../theme/home.css';
import { permissionRegistry } from '../services/permission/PermissionService';

import PermissionSection from './views/PermissionSection';

type Item = { label: string; onClick: () => void };

const Home: React.FC = () => {
  const [toastMessage, setToastMessage] = useState<string>('');
  const [showToast, setShowToast] = useState<boolean>(false);

  const showResult = useCallback((msg: string) => {
    setToastMessage(msg);
    setShowToast(true);
  }, []);

  const exec = useCallback(
    async (action: () => Promise<unknown>, success: (res: unknown) => string, failure: string) => {
      try {
        const res = await action();
        showResult(success(res));
      } catch (e) {
        console.error(e);
        showResult(failure);
      }
    },
    [showResult],
  );

  const buildItems = useCallback(
    (type: SupportedPermissions): Item[] => {
      const handlers = permissionRegistry[type];
      const items: Item[] = [];

      items.push({
        label: 'Check permission status',
        onClick: () =>
          exec(handlers.check, (status) => `${type} status: ${String(status)}`, `Failed to check ${type} status.`),
      });

      if (handlers.shouldShowRationale) {
        items.push({
          label: 'Should show rationale',
          onClick: () =>
            exec(
              handlers.shouldShowRationale!,
              (show) => `[${type}] Should show rationale: ${String(show)}`,
              `Failed to check ${type} rationale.`,
            ),
        });
      }

      items.push({
        label: 'Request permission',
        onClick: () =>
          exec(
            () => handlers.request(),
            (status) => `${type} request result: ${String(status)}`,
            `Failed to request ${type} permission.`,
          ),
      });

      return items;
    },
    [exec],
  );

  const commonItems = useMemo<Item[]>(
    () => [
      {
        label: 'Show rationale dialog',
        onClick: () =>
          exec(
            () =>
              NativePermissions.showRationale(
                'Permission required',
                'We need this permission to proceed.',
                'OK',
                'Cancel',
              ),
            (result) => `Rationale result: ${String(result)}`,
            'Failed to show rationale.',
          ),
      },
      {
        label: 'Open app settings (no wait)',
        onClick: () =>
          exec(
            async () => {
              await NativePermissions.openAppSettings(false);
            },
            () => 'Returned from app settings.',
            'Failed to open app settings.',
          ),
      },
      {
        label: 'Open app settings (wait)',
        onClick: () =>
          exec(
            async () => {
              await NativePermissions.openAppSettings(true);
            },
            () => 'Returned from app settings.',
            'Failed to open app settings.',
          ),
      },
    ],
    [exec],
  );

  const usageExamplesItems = useMemo<Item[]>(
    () => [
      {
        label: 'Basic calendar flow',
        onClick: () =>
          exec(
            () => ensureCalendarPermissionBasic(),
            (result) => `Permission granted: ${String(result)}`,
            'Basic calendar flow failed.',
          ),
      },
      {
        label: 'Advanced calendar flow',
        onClick: () =>
          exec(
            () => ensureCalendarPermissionAdvanced(),
            (result) => `Permission granted: ${String(result)}`,
            'Advanced calendar flow failed.',
          ),
      },
    ],
    [exec],
  );

  async function ensureCalendarPermissionBasic(): Promise<boolean> {
    const status = await NativePermissions.checkCalendar();

    if (status === PermissionStatus.GRANTED) return true;

    if (await NativePermissions.shouldShowCalendarRationale()) {
      await NativePermissions.showRationale(
        'Permission required',
        'We need this permission to access your calendar.',
        'Continue',
      );
    }

    const result = await NativePermissions.requestCalendar();
    return result === PermissionStatus.GRANTED;
  }

  async function ensureCalendarPermissionAdvanced(): Promise<boolean> {
    const status = await NativePermissions.checkCalendar();

    if (status === PermissionStatus.GRANTED) return true;

    if (await NativePermissions.shouldShowCalendarRationale()) {
      await NativePermissions.showRationale(
        'Permission required',
        'We need this permission to access your calendar.',
        'Continue',
      );
    }

    const result = await NativePermissions.requestCalendar();

    // Return result after permission prompt answer
    if (result !== PermissionStatus.PERMANENTLY_DENIED) {
      return result === PermissionStatus.GRANTED;
    }

    // Taking action when no prompt is shown as the permission is already permanently denied
    const shouldForwardToAppSettings = await NativePermissions.showRationale(
      'Permission required',
      'Enable calendar permissions in the app settings.',
      'Continue',
      'Cancel',
    );

    if (shouldForwardToAppSettings) {
      // Passing true to openAppSettings and wait until the user to return to the app
      await NativePermissions.openAppSettings(true);
      const status = await NativePermissions.checkCalendar();

      return status === PermissionStatus.GRANTED;
    }

    return false;
  }

  const notificationItems = useMemo(() => buildItems(SupportedPermissions.Notifications), [buildItems]);
  const appTrackingTransparency = useMemo(() => buildItems(SupportedPermissions.AppTrackingTransparency), [buildItems]);
  const bluetoothItems = useMemo(() => buildItems(SupportedPermissions.Bluetooth), [buildItems]);
  const calendarItems = useMemo(() => buildItems(SupportedPermissions.Calendar), [buildItems]);
  const remindersItems = useMemo(() => buildItems(SupportedPermissions.Reminders), [buildItems]);
  const cameraItems = useMemo(() => buildItems(SupportedPermissions.Camera), [buildItems]);
  const contactsItems = useMemo(() => buildItems(SupportedPermissions.Contacts), [buildItems]);
  const mediaItems = useMemo(() => buildItems(SupportedPermissions.Media), [buildItems]);
  const audioRecord = useMemo(() => buildItems(SupportedPermissions.Record), [buildItems]);
  const locationForeground = useMemo(() => buildItems(SupportedPermissions.LocationForeground), [buildItems]);
  const locationBackground = useMemo(() => buildItems(SupportedPermissions.LocationBackground), [buildItems]);

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Permissions</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent fullscreen>
        <IonHeader collapse="condense">
          <IonToolbar>
            <IonTitle size="large">Permissions</IonTitle>
          </IonToolbar>
        </IonHeader>

        <div className="permissions-content">
          <PermissionSection title="Common" items={commonItems} />
          <PermissionSection title="Usage Examples" items={usageExamplesItems} />

          <PermissionSection title="Notifications" items={notificationItems} />
          <PermissionSection title="App Tracking Transparency" items={appTrackingTransparency} />
          <PermissionSection title="Bluetooth" items={bluetoothItems} />
          <PermissionSection title="Calendar" items={calendarItems} />
          <PermissionSection title="Reminders" items={remindersItems} />
          <PermissionSection title="Camera" items={cameraItems} />
          <PermissionSection title="Contacts" items={contactsItems} />
          <PermissionSection title="Media" items={mediaItems} />
          <PermissionSection title="Audio Record" items={audioRecord} />
          <PermissionSection title="Location Foreground" items={locationForeground} />
          <PermissionSection title="Location Background" items={locationBackground} />
        </div>

        <IonToast isOpen={showToast} message={toastMessage} duration={2000} onDidDismiss={() => setShowToast(false)} />
      </IonContent>
    </IonPage>
  );
};

export default Home;
