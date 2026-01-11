#!/bin/bash

# Arrêter le script en cas d'erreur
set -e

echo "⚙️ Refonte complète de la page Paramètres (Design & Features)..."

# 1. Mise à jour du Modèle de Configuration
# On ajoute des champs utiles pour un vrai commerce
echo "📝 Mise à jour de src/app/models/config.model.ts..."
cat > src/app/models/config.model.ts <<EOF
export interface StoreConfig {
  name: string;
  address: string;
  phone: string;
  email?: string;
  siret?: string;
  footerMessage: string;
  defaultVat?: number;
  currencySymbol?: string;
}
EOF

# 2. Refonte du HTML (Settings)
# Utilisation du layout "absolu" pour éviter la page blanche + Design soigné
echo "🎨 Refonte de src/app/pages/settings/settings.page.html..."
cat > src/app/pages/settings/settings.page.html <<EOF
<ion-content [fullscreen]="true" [scrollY]="false" class="bg-slate-50">
  
  <div class="absolute inset-0 flex flex-col w-full h-full overflow-hidden">
    
    <div class="bg-white px-6 py-4 border-b border-slate-100 flex justify-between items-center z-20 shrink-0 shadow-sm">
      <div class="flex items-center gap-3">
        <button routerLink="/dashboard" class="h-10 w-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-600 tap-effect hover:bg-slate-100 transition-colors">
          <ion-icon name="arrow-back-outline" class="text-xl"></ion-icon>
        </button>
        <h1 class="font-bold text-lg text-slate-800">Paramètres</h1>
      </div>
      
      <button (click)="save()" [disabled]="isSaving" class="bg-indigo-600 text-white px-5 py-2.5 rounded-xl flex items-center gap-2 text-sm font-bold shadow-lg shadow-indigo-200 tap-effect active:scale-95 transition-transform disabled:opacity-50">
        <ion-icon name="save-outline" class="text-lg"></ion-icon>
        <span class="hidden sm:inline">{{ isSaving ? '...' : 'Sauvegarder' }}</span>
      </button>
    </div>

    <div class="flex-1 overflow-y-auto p-4 sm:p-6 space-y-6 bg-slate-50 pb-24">
      
      <div>
        <h2 class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-3 ml-1 flex items-center gap-2">
          <ion-icon name="storefront-outline"></ion-icon> Identité du Magasin
        </h2>
        <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          
          <div class="p-4 border-b border-slate-50">
            <label class="block text-xs font-bold text-indigo-600 uppercase mb-1">Nom de la boutique</label>
            <input [(ngModel)]="config.name" type="text" class="w-full text-lg font-bold text-slate-800 bg-transparent outline-none placeholder-slate-300" placeholder="Ma Boutique">
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2">
            <div class="p-4 border-b md:border-b-0 md:border-r border-slate-50">
              <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Téléphone</label>
              <div class="flex items-center gap-2">
                <ion-icon name="call-outline" class="text-slate-300"></ion-icon>
                <input [(ngModel)]="config.phone" type="tel" class="w-full font-medium text-slate-700 bg-transparent outline-none placeholder-slate-300" placeholder="+33 6...">
              </div>
            </div>
            
            <div class="p-4 border-b md:border-b-0 border-slate-50">
              <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Email</label>
              <div class="flex items-center gap-2">
                <ion-icon name="mail-outline" class="text-slate-300"></ion-icon>
                <input [(ngModel)]="config.email" type="email" class="w-full font-medium text-slate-700 bg-transparent outline-none placeholder-slate-300" placeholder="contact@boutique.com">
              </div>
            </div>
          </div>

          <div class="p-4 border-t border-slate-50">
            <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Adresse Complète</label>
            <textarea [(ngModel)]="config.address" rows="3" class="w-full font-medium text-slate-700 bg-transparent outline-none placeholder-slate-300 resize-none leading-relaxed" placeholder="123 Rue du Commerce, 75000 Paris"></textarea>
          </div>

          <div class="p-4 border-t border-slate-50 bg-slate-50/50">
             <label class="block text-xs font-bold text-slate-400 uppercase mb-1">SIRET / Mat. Fiscale</label>
             <input [(ngModel)]="config.siret" type="text" class="w-full font-mono text-sm text-slate-600 bg-transparent outline-none placeholder-slate-300" placeholder="000 000 000 00000">
          </div>
        </div>
      </div>

      <div>
        <h2 class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-3 ml-1 flex items-center gap-2">
          <ion-icon name="receipt-outline"></ion-icon> Ticket & Fiscalité
        </h2>
        <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          
          <div class="p-4 border-b border-slate-50">
            <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Message de pied de page</label>
            <input [(ngModel)]="config.footerMessage" type="text" class="w-full font-medium text-slate-700 bg-transparent outline-none placeholder-slate-300" placeholder="Merci de votre visite !">
            <p class="text-[10px] text-slate-400 mt-1">Apparaît tout en bas du ticket de caisse.</p>
          </div>

          <div class="grid grid-cols-2">
            <div class="p-4 border-r border-slate-50">
              <label class="block text-xs font-bold text-slate-400 uppercase mb-1">TVA par défaut (%)</label>
              <input [(ngModel)]="config.defaultVat" type="number" class="w-full font-bold text-slate-700 bg-transparent outline-none placeholder-slate-300" placeholder="20">
            </div>
            <div class="p-4">
              <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Symbole Monétaire</label>
              <input [(ngModel)]="config.currencySymbol" type="text" class="w-full font-bold text-slate-700 bg-transparent outline-none placeholder-slate-300" placeholder="€">
            </div>
          </div>
        </div>
      </div>

      <div>
        <h2 class="text-xs font-bold text-red-400 uppercase tracking-wider mb-3 ml-1 flex items-center gap-2">
          <ion-icon name="warning-outline"></ion-icon> Zone de Danger
        </h2>
        <div class="bg-white rounded-2xl shadow-sm border border-red-100 overflow-hidden p-4 flex items-center justify-between">
          <div>
            <h3 class="font-bold text-slate-700 text-sm">Réinitialiser les données locales</h3>
            <p class="text-xs text-slate-400 mt-1">Efface le cache (panier en cours, préférences)</p>
          </div>
          <button (click)="resetCache()" class="bg-red-50 text-red-600 px-4 py-2 rounded-lg text-xs font-bold border border-red-100 tap-effect">
            Effacer
          </button>
        </div>
      </div>
      
      <div class="text-center text-xs text-slate-300 py-4">
        <p>IonicCaisse v2.0.0 (Standalone)</p>
        <p class="mt-1">ID: {{ config.siret || 'N/A' }}</p>
      </div>

    </div>
  </div>
</ion-content>
EOF

# 3. Refonte du TS (Logique)
echo "🧠 Mise à jour de src/app/pages/settings/settings.page.ts..."
cat > src/app/pages/settings/settings.page.ts <<EOF
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
EOF

echo "✅ Page Paramètres mise à jour et enrichie."
echo "👉 Rechargez la page Settings pour voir le nouveau formulaire."