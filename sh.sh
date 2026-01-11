#!/bin/bash

# Arrêter le script en cas d'erreur
set -e

echo "🚑 Réparation des boutons du Modal Produit (Déplacement dans le Header)..."

# 1. Mise à jour de ProductModal (HTML)
# CHANGEMENT : On place "Annuler" à gauche et "Enregistrer" à droite dans la Toolbar
echo "🔧 Correction du template HTML (Boutons visibles)..."
cat > src/app/components/product-modal/product-modal.component.html <<EOF
<ion-header class="ion-no-border">
  <ion-toolbar class="bg-white border-b border-slate-100">
    
    <ion-buttons slot="start">
      <ion-button (click)="cancel()" class="text-slate-500 font-medium text-sm normal-case">
        Annuler
      </ion-button>
    </ion-buttons>

    <ion-title class="font-bold text-slate-800 text-center">Nouveau Produit</ion-title>

    <ion-buttons slot="end">
      <ion-button (click)="confirm()" [strong]="true" class="text-indigo-600 font-bold text-sm normal-case">
        Enregistrer
      </ion-button>
    </ion-buttons>

  </ion-toolbar>
</ion-header>

<ion-content class="bg-slate-50">
  <div class="p-5 flex flex-col gap-5 pb-10">
    
    <div>
      <p class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2 ml-1">Identification</p>
      <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        <ion-item lines="none" class="border-b border-slate-50">
          <ion-label position="stacked" class="font-bold text-slate-500 text-xs uppercase mb-1">Nom du produit</ion-label>
          <ion-input [(ngModel)]="product.name" type="text" placeholder="Ex: Café Espresso" class="font-semibold text-slate-800"></ion-input>
        </ion-item>

        <ion-item lines="none">
          <ion-label position="stacked" class="font-bold text-slate-500 text-xs uppercase mb-1">Code-barres (EAN)</ion-label>
          <div class="flex items-center w-full gap-2">
            <ion-icon name="barcode-outline" class="text-slate-400"></ion-icon>
            <ion-input [(ngModel)]="product.barcode" type="text" placeholder="Scanner ou saisir" class="font-mono text-slate-600"></ion-input>
          </div>
        </ion-item>
      </div>
    </div>

    <div>
      <p class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2 ml-1">Détails</p>
      <div class="grid grid-cols-2 gap-4">
        <div class="bg-white p-3 rounded-2xl shadow-sm border border-slate-100">
          <ion-label class="block font-bold text-slate-500 text-xs uppercase mb-1">Prix (€)</ion-label>
          <ion-input [(ngModel)]="product.price" type="number" placeholder="0.00" class="font-bold text-slate-800 text-lg"></ion-input>
        </div>

        <div class="bg-white p-3 rounded-2xl shadow-sm border border-slate-100">
          <ion-label class="block font-bold text-slate-500 text-xs uppercase mb-1">Stock</ion-label>
          <ion-input [(ngModel)]="product.stock" type="number" placeholder="0" class="font-bold text-slate-800 text-lg"></ion-input>
        </div>
      </div>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-slate-100 p-1">
      <ion-item lines="none">
        <ion-icon name="grid-outline" slot="start" class="text-slate-400 text-sm"></ion-icon>
        <ion-label class="font-bold text-slate-600 text-sm">Catégorie</ion-label>
        <ion-select [(ngModel)]="product.category" interface="popover" class="font-bold text-indigo-600">
          <ion-select-option value="Boissons">Boissons</ion-select-option>
          <ion-select-option value="Snack">Snack</ion-select-option>
          <ion-select-option value="Viennoiserie">Viennoiserie</ion-select-option>
          <ion-select-option value="Divers">Divers</ion-select-option>
        </ion-select>
      </ion-item>
    </div>

  </div>
</ion-content>
EOF

# 2. Mise à jour de ProductModal (TS)
# Synchronisation des imports (ajout gridOutline, barcodeOutline)
echo "🔧 Correction du code TS..."
cat > src/app/components/product-modal/product-modal.component.ts <<EOF
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { 
  IonHeader, IonToolbar, IonTitle, IonContent, IonButtons, IonButton, 
  IonItem, IonLabel, IonInput, IonSelect, IonSelectOption, ModalController, IonIcon
} from '@ionic/angular/standalone';
import { Product } from 'src/app/models/product.model';
import { addIcons } from 'ionicons';
import { closeOutline, saveOutline, barcodeOutline, gridOutline } from 'ionicons/icons';

@Component({
  selector: 'app-product-modal',
  templateUrl: './product-modal.component.html',
  standalone: true,
  imports: [
    CommonModule, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButtons, IonButton,
    IonItem, IonLabel, IonInput, IonSelect, IonSelectOption, IonIcon
  ]
})
export class ProductModalComponent {

  product: Product = {
    name: '',
    price: 0,
    category: 'Divers',
    stock: 0,
    imageUrl: '',
    barcode: ''
  };

  constructor(private modalCtrl: ModalController) {
    addIcons({ closeOutline, saveOutline, barcodeOutline, gridOutline });
  }

  cancel() {
    this.modalCtrl.dismiss(null, 'cancel');
  }

  confirm() {
    if (!this.product.name) return;
    this.modalCtrl.dismiss(this.product, 'confirm');
  }
}
EOF

echo "✅ Correctif appliqué. Les boutons 'Annuler' et 'Enregistrer' sont maintenant dans l'en-tête."