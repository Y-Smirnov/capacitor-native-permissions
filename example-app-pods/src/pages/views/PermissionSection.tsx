import { IonList, IonItem, IonLabel, IonCard, IonCardContent } from '@ionic/react';
import React from 'react';

type PermissionItems = {
  label: string;
  onClick: () => void;
};

type PermissionSectionProps = {
  title: string;
  items: PermissionItems[];
};

const PermissionSection: React.FC<PermissionSectionProps> = ({ title, items }) => (
  <div>
    <p className="perm-section-title">{title}</p>

    <IonCard className="perm-section-card">
      <IonCardContent className="ion-no-padding">
        <IonList>
          {items.map((item, index) => (
            <IonItem button key={index} onClick={item.onClick} lines={index === items.length - 1 ? 'none' : 'full'}>
              <IonLabel>{item.label}</IonLabel>
            </IonItem>
          ))}
        </IonList>
      </IonCardContent>
    </IonCard>
  </div>
);

export default PermissionSection;
