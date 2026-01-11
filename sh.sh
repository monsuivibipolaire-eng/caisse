#!/bin/bash

# Arrêter le script en cas d'erreur
set -e

echo "🖨️ Mise en place du Ticket de Caisse Imprimable..."

# 1. LOGIQUE DU COMPOSANT (TS)
# Récupère la vente et la config magasin
echo "🧠 Création de src/app/components/receipt-modal/receipt-modal.component.ts..."
cat > src/app/components/receipt-modal/receipt-modal.component.ts <<EOF
import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonContent, IonButton, IonIcon, ModalController } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { printOutline, closeOutline, checkmarkCircle } from 'ionicons/icons';
import { Sale } from 'src/app/models/sale.model';
import { ConfigService } from 'src/app/services/config.service';
import { StoreConfig } from 'src/app/models/config.model';

@Component({
  selector: 'app-receipt-modal',
  templateUrl: './receipt-modal.component.html',
  styleUrls: ['./receipt-modal.component.scss'],
  standalone: true,
  imports: [CommonModule, IonContent, IonButton, IonIcon]
})
export class ReceiptModalComponent implements OnInit {

  @Input() sale!: Sale;
  config: StoreConfig | null = null;

  constructor(
    private modalCtrl: ModalController,
    private configService: ConfigService
  ) {
    addIcons({ printOutline, closeOutline, checkmarkCircle });
  }

  ngOnInit() {
    // Charger les infos du magasin (Nom, Adresse, etc.)
    this.configService.getConfig().subscribe(c => this.config = c);
  }

  close() {
    this.modalCtrl.dismiss();
  }

  printReceipt() {
    // Lance l'impression native du navigateur
    window.print();
  }
}
EOF

# 2. DESIGN DU TICKET (HTML)
# Structure HTML imitant un ticket thermique (80mm width style)
echo "🎨 Création de src/app/components/receipt-modal/receipt-modal.component.html..."
cat > src/app/components/receipt-modal/receipt-modal.component.html <<EOF
<ion-content class="bg-slate-800">
  
  <div class="flex flex-col items-center justify-center min-h-full p-4">
    
    <div class="screen-only flex flex-col items-center text-white mb-6 animate-fade-in">
      <ion-icon name="checkmark-circle" class="text-6xl text-emerald-400 mb-2"></ion-icon>
      <h2 class="text-2xl font-bold">Vente Validée !</h2>
      <p class="text-slate-400">Total: {{ sale.total | currency:'EUR' }}</p>
    </div>

    <div id="receipt-area" class="bg-white text-slate-900 w-full max-w-[380px] p-6 shadow-2xl relative ticket-paper">
      
      <div class="absolute top-0 left-0 right-0 h-1 bg-[url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMiAxMiIgd2lkdGg9IjEyIiBoZWlnaHQ9IjEyIiBmaWxsPSIjZmZmIiBzdHJva2U9Im5vbmUiPjxjaXJjbGUgY3g9IjYiIGN5PSIwIiByPSI2Ii8+PC9zdmc+')] bg-repeat-x bg-top transform -translate-y-1/2"></div>

      <div class="text-center mb-6">
        <h1 class="text-xl font-extrabold uppercase tracking-widest">{{ config?.name || 'MON MAGASIN' }}</h1>
        <p class="text-xs font-mono text-slate-500 mt-1 whitespace-pre-line">{{ config?.address || 'Adresse non configurée' }}</p>
        <p class="text-xs font-mono text-slate-500">{{ config?.phone }}</p>
        <p class="text-xs font-mono text-slate-500 mt-1">{{ sale.date?.seconds * 1000 | date:'dd/MM/yyyy HH:mm' }}</p>
      </div>

      <div class="border-b-2 border-dashed border-slate-300 my-4"></div>

      <div class="flex justify-between text-xs font-bold font-mono mb-4 text-slate-600">
        <span>Vendeur: {{ sale.staffName || 'Inconnu' }}</span>
        <span>ID: #{{ sale.id | slice:0:6 }}</span>
      </div>

      <div class="flex flex-col gap-2 font-mono text-sm mb-6">
        <div *ngFor="let item of sale.items" class="flex justify-between items-start">
          <div class="flex flex-col">
            <span class="font-bold uppercase">{{ item.product.name }}</span>
            <span class="text-xs text-slate-500">x{{ item.quantity }} @ {{ item.product.price | number:'1.2-2' }}</span>
          </div>
          <span class="font-bold">{{ (item.product.price * item.quantity) | number:'1.2-2' }}€</span>
        </div>
      </div>

      <div class="border-b-2 border-dashed border-slate-300 my-4"></div>

      <div class="space-y-1 font-mono text-right">
        <div class="flex justify-between text-xs text-slate-500">
          <span>Total HT</span>
          <span>{{ sale.total * 0.8 | number:'1.2-2' }}€</span>
        </div>
        <div class="flex justify-between text-xs text-slate-500">
          <span>TVA (20%)</span>
          <span>{{ sale.total * 0.2 | number:'1.2-2' }}€</span>
        </div>
        <div class="flex justify-between text-xl font-extrabold mt-3 border-t-2 border-slate-900 pt-2">
          <span>TOTAL TTC</span>
          <span>{{ sale.total | currency:'EUR':'symbol':'1.2-2' }}</span>
        </div>
        <div class="text-xs font-bold uppercase mt-2 text-slate-600 text-center">
          PAIEMENT : {{ sale.paymentMethod }}
        </div>
      </div>

      <div class="border-b-2 border-dashed border-slate-300 my-6"></div>

      <div class="text-center">
        <p class="text-xs font-mono font-bold">{{ config?.footerMessage || 'MERCI DE VOTRE VISITE !' }}</p>
        <p class="text-[10px] text-slate-400 mt-1">À bientôt</p>
        
        <div class="mt-4 h-12 bg-slate-900 mx-auto w-3/4 opacity-80" style="mask-image: url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAiIGhlaWdodD0iMTAiIHByZXNlcnZlQXNwZWN0UmF0aW89Im5vbmUiPjxwYXRoIGQ9Ik0wIDBoMnYxMEgwem00IDBoMXYxMEg0em0zIDBoMXYxMEg3em0zIDBoMnYxMEgxMHptNCAwaDF2MTBIMTR6bTMgMGgzdjEwSDE3em01IDBoMXYxMEgyMnptMyAwaDF2MTBIMjV6bTMgMGgydjEwSDI4em00IDBoMXYxMEgzMnptMyAwaDJ2MTBIMzV6bTQgMGgxdjEwSDM5em0zIDBoMXYxMEg0MnptNCAwaDF2MTBINDI2em0zIDBoMXYxMEg0OXptNCAwaDJ2MTBINTN6bTQgMGgxdjEwSDU3em0zIDBoMXYxMEg2MHptNCAwaDJ2MTBINjR6bTQgMGgxdjEwSDY4em0zIDBoMXYxMEg3MXptNCAwaDF2MTBINzR6bTMgMGgydjEwSDc3em00IDBoMXYxMEg4MXptMyAwaDJ2MTBIODR6bTQgMGgxdjEwSDg5em0zIDBoMXYxMEg5MnptNCAwaDF2MTB5OTZ6IiBmaWxsPSIjMDAwIi8+PC9zdmc+'); mask-size: contain;"></div>
      </div>
      
      <div class="absolute bottom-0 left-0 right-0 h-1 bg-[url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMiAxMiIgd2lkdGg9IjEyIiBoZWlnaHQ9IjEyIiBmaWxsPSIjZmZmIiBzdHJva2U9Im5vbmUiPjxjaXJjbGUgY3g9IjYiIGN5PSIxMiIgcj0iNiIvPjwvc3ZnPg==')] bg-repeat-x bg-bottom transform translate-y-1/2"></div>
    </div>

    <div class="screen-only flex flex-col w-full max-w-[380px] gap-3 mt-8">
      <button (click)="printReceipt()" class="w-full bg-white text-slate-900 py-4 rounded-xl font-bold text-lg shadow-lg tap-effect flex items-center justify-center gap-2 hover:bg-slate-50 transition-colors">
        <ion-icon name="print-outline" class="text-2xl"></ion-icon>
        IMPRIMER
      </button>
      
      <button (click)="close()" class="w-full bg-slate-700 text-slate-300 py-3 rounded-xl font-bold tap-effect hover:bg-slate-600 transition-colors">
        Fermer
      </button>
    </div>

  </div>
</ion-content>
EOF

# 3. STYLES D'IMPRESSION (SCSS)
# C'est ici que la magie opère pour cacher le reste de l'app
echo "🎨 Création de src/app/components/receipt-modal/receipt-modal.component.scss..."
cat > src/app/components/receipt-modal/receipt-modal.component.scss <<EOF
/* Style papier ticket */
.ticket-paper {
  filter: drop-shadow(0 20px 13px rgb(0 0 0 / 0.03)) drop-shadow(0 8px 5px rgb(0 0 0 / 0.08));
}

/* --- RÈGLES D'IMPRESSION (CRUCIAL) --- */
@media print {
  /* 1. Cacher tout le corps de l'application Ionic */
  body > * {
    display: none !important;
  }

  /* 2. Cacher les éléments "Screen Only" (Boutons, message succès) */
  .screen-only {
    display: none !important;
  }

  /* 3. Afficher uniquement la modale et son contenu */
  /* Ionic attache les modales à la racine, on doit cibler spécifiquement */
  /* Note: En impression Web pure, on triche souvent en positionnant le contenu en absolute */
  
  :host {
    display: block !important;
    position: absolute !important;
    top: 0 !important;
    left: 0 !important;
    width: 100% !important;
    height: 100% !important;
    z-index: 9999 !important;
    background: white !important;
  }

  /* Forcer le contenu du ticket à être visible */
  #receipt-area {
    display: block !important;
    width: 100% !important; /* Pleine largeur papier */
    max-width: none !important;
    box-shadow: none !important; /* Pas d'ombre à l'impression */
    margin: 0 !important;
    padding: 0 !important;
    position: absolute !important;
    top: 0 !important;
    left: 0 !important;
  }

  /* Supprimer les fonds sombres */
  ion-content {
    --background: white !important;
  }
  
  .bg-slate-800 {
    background-color: white !important;
  }
}
EOF

echo "✅ Ticket de caisse installé avec succès."
echo "👉 Cliquez sur 'Valider' dans le panier. Une fenêtre s'ouvrira avec le ticket et le bouton 'Imprimer'."