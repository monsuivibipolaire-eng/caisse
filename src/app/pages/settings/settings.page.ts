import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { IonContent, IonIcon, ToastController, AlertController } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { arrowBackOutline, saveOutline, storefrontOutline, callOutline, mailOutline, receiptOutline, warningOutline } from 'ionicons/icons';
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
    name: '', 
    address: '', 
    phone: '', 
    footerMessage: '',
    email: '',
    siret: '',
    defaultVat: 20,
    currencySymbol: '€'
  };

  isSaving = false;

  constructor(
    private configService: ConfigService, 
    private toastCtrl: ToastController,
    private alertCtrl: AlertController
  ) {
    addIcons({ arrowBackOutline, saveOutline, storefrontOutline, callOutline, mailOutline, receiptOutline, warningOutline });
  }

  ngOnInit() {
    this.configService.getConfig().pipe(take(1)).subscribe(d => {
      if (d) {
        // Fusionner avec les valeurs par défaut pour éviter les champs vides
        this.config = { ...this.config, ...d };
      }
    });
  }

  async save() {
    this.isSaving = true;
    try {
      await this.configService.saveConfig(this.config);
      
      const toast = await this.toastCtrl.create({
        message: 'Paramètres sauvegardés avec succès !',
        duration: 2000,
        color: 'success',
        position: 'top',
        icon: 'checkmark-circle'
      });
      toast.present();

    } catch (e) {
      const toast = await this.toastCtrl.create({
        message: 'Erreur lors de la sauvegarde',
        duration: 2000,
        color: 'danger',
        position: 'top'
      });
      toast.present();
    } finally {
      this.isSaving = false;
    }
  }

  async resetCache() {
    const alert = await this.alertCtrl.create({
      header: 'Confirmation',
      message: 'Voulez-vous vraiment vider le cache local ? Cela ne supprimera pas les produits de la base de données.',
      buttons: [
        { text: 'Annuler', role: 'cancel' },
        { 
          text: 'Oui, vider', 
          role: 'confirm',
          handler: () => {
            localStorage.clear();
            location.reload();
          }
        }
      ]
    });
    await alert.present();
  }
}
