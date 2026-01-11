import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { IonContent, IonIcon, ToastController, AlertController } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { arrowBackOutline, saveOutline, storefrontOutline, callOutline, mailOutline, receiptOutline, warningOutline, peopleOutline, chevronForwardOutline } from 'ionicons/icons';
import { ConfigService } from 'src/app/services/config.service';
import { StoreConfig } from 'src/app/models/config.model';
import { take } from 'rxjs';

@Component({
  selector: 'app-settings',
  templateUrl: './settings.page.html',
  styleUrls: ['./settings.page.scss'],
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, IonContent, IonIcon]
})
export class SettingsPage implements OnInit {
  
  config: StoreConfig = { 
    name: '', address: '', phone: '', footerMessage: '', email: '', siret: '', defaultVat: 20, currencySymbol: '€'
  };
  isSaving = false;

  constructor(private configService: ConfigService, private toastCtrl: ToastController, private alertCtrl: AlertController) {
    addIcons({ arrowBackOutline, saveOutline, storefrontOutline, callOutline, mailOutline, receiptOutline, warningOutline, peopleOutline, chevronForwardOutline });
  }

  ngOnInit() {
    this.configService.getConfig().pipe(take(1)).subscribe(d => {
      if (d) this.config = { ...this.config, ...d };
    });
  }

  async save() {
    this.isSaving = true;
    try {
      await this.configService.saveConfig(this.config);
      const toast = await this.toastCtrl.create({ message: 'Sauvegardé !', duration: 2000, color: 'success', position: 'top' });
      toast.present();
    } catch (e) {
      console.error(e);
    } finally {
      this.isSaving = false;
    }
  }

  async resetCache() {
    const alert = await this.alertCtrl.create({
      header: 'Confirmation',
      message: 'Vider le cache local ?',
      buttons: [
        { text: 'Annuler', role: 'cancel' },
        { text: 'Oui', role: 'confirm', handler: () => { localStorage.clear(); location.reload(); } }
      ]
    });
    await alert.present();
  }
}
