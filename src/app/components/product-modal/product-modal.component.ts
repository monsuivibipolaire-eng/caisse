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
