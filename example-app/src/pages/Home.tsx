import { IonContent, IonHeader, IonPage, IonTitle, IonToolbar, IonToast } from '@ionic/react';
import React, { useCallback, useMemo, useState } from 'react';

import '../theme/home.css';
import { checkPermission, requestPermission, shouldShowRationale } from '../services/permission/PermissionService';
import { PermissionType } from '../services/permission/PermissionType';

import PermissionSection from './views/PermissionSection';

const Home: React.FC = () => {
  const [toastMessage, setToastMessage] = useState<string>('');
  const [showToast, setShowToast] = useState<boolean>(false);

  const showResult = useCallback((msg: string) => {
    setToastMessage(msg);
    setShowToast(true);
  }, []);

  const permissionCheck = useCallback(
    async (type: PermissionType) => {
      try {
        const res = await checkPermission(type);
        showResult(`${type} status: ${res.status}`);
      } catch (e) {
        console.error(e);
        showResult(`Failed to check ${type} status.`);
      }
    },
    [showResult],
  );

  const permissionRationale = useCallback(
    async (type: PermissionType) => {
      try {
        const show = await shouldShowRationale(type);
        showResult(`[${type}] Should show rationale: ${show}`);
      } catch (e) {
        console.error(e);
        showResult(`Failed to check ${type} rationale.`);
      }
    },
    [showResult],
  );

  const permissionRequest = useCallback(
    async (type: PermissionType) => {
      try {
        const res = await requestPermission(type);
        showResult(`${type} request result: ${res.status}`);
      } catch (e) {
        console.error(e);
        showResult(`Failed to request ${type} permission.`);
      }
    },
    [showResult],
  );

  const notificationItems = useMemo(
    () => [
      { label: 'Check permission status', onClick: () => permissionCheck(PermissionType.Notifications) },
      { label: 'Should show rationale', onClick: () => permissionRationale(PermissionType.Notifications) },
      { label: 'Request permission', onClick: () => permissionRequest(PermissionType.Notifications) },
    ],
    [permissionCheck, permissionRationale, permissionRequest],
  );

  const appTrackingTransparency = useMemo(
    () => [
      { label: 'Check permission status', onClick: () => permissionCheck(PermissionType.AppTrackingTransparency) },
      { label: 'Request permission', onClick: () => permissionRequest(PermissionType.AppTrackingTransparency) },
    ],
    [permissionCheck, permissionRequest],
  );

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
          <PermissionSection title="Notifications" items={notificationItems} />

          <PermissionSection title="App Tracking Transparency" items={appTrackingTransparency} />
        </div>

        <IonToast isOpen={showToast} message={toastMessage} duration={2000} onDidDismiss={() => setShowToast(false)} />
      </IonContent>
    </IonPage>
  );
};

export default Home;
