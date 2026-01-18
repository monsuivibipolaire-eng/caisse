#!/bin/bash
set -e
echo "🚑 Sécurisation du bouton Imprimer..."

# On remplace le contenu de receipt-modal.component.ts par une version blindée
cat > src/app/components/receipt-modal/receipt-modal.component.ts <<EOF
import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonContent, IonButton, IonIcon, ModalController, IonicModule, Platform } from '@ionic/angular';
import { addIcons } from 'ionicons';
import { printOutline, closeOutline, checkmarkCircle, barcodeOutline } from 'ionicons/icons';
import { Sale } from 'src/app/models/sale.model';
import { ConfigService } from 'src/app/services/config.service';
import { StoreConfig } from 'src/app/models/config.model';
import { Printer, PrintOptions } from '@awesome-cordova-plugins/printer/ngx';

@Component({
  selector: 'app-receipt-modal',
  templateUrl: './receipt-modal.component.html',
  styleUrls: ['./receipt-modal.component.scss'],
  standalone: true,
  imports: [CommonModule, IonicModule],
  providers: [Printer] // Ajout local au cas où main.ts a raté
})
export class ReceiptModalComponent implements OnInit {

  @Input() sale!: Sale;
  config: StoreConfig | null = null;

  constructor(
    private modalCtrl: ModalController,
    private configService: ConfigService,
    private printer: Printer,
    private platform: Platform
  ) {
    addIcons({ printOutline, closeOutline, checkmarkCircle, barcodeOutline });
  }

  ngOnInit() {
    this.configService.getConfig().subscribe(c => this.config = c);
  }

  close() {
    this.modalCtrl.dismiss();
  }

  parseDate(date: any): any {
    if (!date) return new Date();
    if (typeof date === 'object' && 'seconds' in date) {
      return new Date(date.seconds * 1000);
    }
    return date;
  }

  printReceipt() {
    const content = document.getElementById('receipt-area')?.innerHTML;
    const options: PrintOptions = {
      name: 'Ticket Caisse',
      duplex: false,
      orientation: 'portrait',
      monochrome: true
    };

    // Fonction d'impression native
    const doNativePrint = () => {
      this.printer.print(content || '', options).then(() => {
        console.log("Impression terminée");
      }).catch(err => {
        console.error("Erreur impression native:", err);
        // Dernier recours : window.print
        window.print();
      });
    };

    // 1. Si on est sur un navigateur web classique (pas une app)
    if (!this.platform.is('capacitor') && !this.platform.is('cordova')) {
      console.warn("Mode Web détecté -> window.print()");
      window.print();
      return;
    }

    // 2. Vérification sécurisée du plugin
    try {
      const check = this.printer.isAvailable();
      
      // Si check est une promesse valide
      if (check && typeof check.then === 'function') {
        check.then(() => {
          doNativePrint();
        }).catch(() => {
          // Si isAvailable rejette (ex: pas d'app d'impression installée), on tente quand même d'imprimer
          // car parfois isAvailable ment sur Android POS
          doNativePrint();
        });
      } else {
        // Le plugin a renvoyé undefined (cas de ton erreur)
        console.warn("Plugin Printer mal chargé, tentative directe...");
        doNativePrint();
      }
    } catch (e) {
      console.error("Crash check printer", e);
      // En cas de crash total, on essaie window.print
      window.print();
    }
  }
}
EOF

echo "✅ Code sécurisé."