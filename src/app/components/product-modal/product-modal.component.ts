import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { 
  IonHeader, IonToolbar, IonTitle, IonContent, IonButtons, IonButton, 
  IonItem, IonLabel, IonInput, IonSelect, IonSelectOption, ModalController, IonIcon, 
  IonSpinner, LoadingController 
} from '@ionic/angular/standalone';
import { Product } from 'src/app/models/product.model';
import { addIcons } from 'ionicons';
// IMPORTS COMPLETS
import { closeOutline, saveOutline, barcodeOutline, gridOutline, cameraOutline, imageOutline, add } from 'ionicons/icons';
import { ImageService } from 'src/app/services/image.service';

@Component({
  selector: 'app-product-modal',
  templateUrl: './product-modal.component.html',
  standalone: true,
  imports: [
    CommonModule, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButtons, IonButton,
    IonItem, IonLabel, IonInput, IonSelect, IonSelectOption, IonIcon, IonSpinner
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

  isUploading = false;

  constructor(
    private modalCtrl: ModalController,
    private imageService: ImageService,
    private loadingCtrl: LoadingController
  ) {
    // ENREGISTREMENT DES ICONES
    addIcons({ closeOutline, saveOutline, barcodeOutline, gridOutline, cameraOutline, imageOutline, add });
  }

  cancel() {
    this.modalCtrl.dismiss(null, 'cancel');
  }

  async selectPhoto() {
    console.log('Début sélection photo...');
    try {
      const base64 = await this.imageService.selectImage();
      
      if (base64) {
        this.isUploading = true;
        console.log('Image reçue, début upload...');
        const url = await this.imageService.uploadImage(base64);
        this.product.imageUrl = url;
        console.log('Succès upload:', url);
      } else {
        console.log('Aucune image sélectionnée');
      }
    } catch (e) {
      console.error('Erreur dans le processus photo:', e);
    } finally {
      this.isUploading = false;
    }
  }

  confirm() {
    if (!this.product.name) return;
    this.modalCtrl.dismiss(this.product, 'confirm');
  }
}
