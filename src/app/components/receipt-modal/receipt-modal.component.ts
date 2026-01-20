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
    this.configService.getConfig().subscribe(c => this.config = c);
  }

  close() {
    this.modalCtrl.dismiss();
  }

  // --- CORRECTION DU CRASH DATE ---
  parseDate(date: any): any {
    if (!date) return null;
    
    // Si c'est déjà une Date JS valide
    if (date instanceof Date) return date;
    
    // Si c'est un Timestamp Firestore (objet avec seconds)
    if (typeof date === 'object' && 'seconds' in date) {
      return new Date(date.seconds * 1000);
    }

    // Si c'est une chaine ou un nombre
    return new Date(date);
  }

  printReceipt() {
    window.print();
  }
}
