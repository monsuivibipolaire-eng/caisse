import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonHeader, IonToolbar, IonTitle, IonContent, IonButtons, IonButton, ModalController, IonIcon } from '@ionic/angular/standalone';
import { NgxPrintModule } from 'ngx-print';
import { addIcons } from 'ionicons';
import { printOutline, closeOutline } from 'ionicons/icons';
import { Sale } from 'src/app/models/sale.model';
import { ConfigService } from 'src/app/services/config.service';
import { StoreConfig } from 'src/app/models/config.model';
import { Observable } from 'rxjs';

@Component({
  selector: 'app-receipt-modal',
  templateUrl: './receipt-modal.component.html',
  styleUrls: ['./receipt-modal.component.scss'],
  standalone: true,
  imports: [
    CommonModule, NgxPrintModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButtons, IonButton, IonIcon
  ]
})
export class ReceiptModalComponent implements OnInit {

  @Input() sale: Sale | null = null;
  config$: Observable<StoreConfig>;

  constructor(
    private modalCtrl: ModalController,
    private configService: ConfigService
  ) {
    addIcons({ printOutline, closeOutline });
    this.config$ = this.configService.getConfig();
  }

  ngOnInit() {}

  close() {
    this.modalCtrl.dismiss();
  }
}
