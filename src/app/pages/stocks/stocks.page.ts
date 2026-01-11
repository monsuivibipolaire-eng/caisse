import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { IonContent, IonIcon, IonItemSliding, IonItem, IonItemOptions, IonItemOption, ModalController } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { arrowBackOutline, addOutline, cubeOutline, trashOutline, imageOutline, barcodeOutline } from 'ionicons/icons';
import { ProductService } from 'src/app/services/product.service';
import { Observable } from 'rxjs';
import { Product } from 'src/app/models/product.model';
import { ProductModalComponent } from 'src/app/components/product-modal/product-modal.component';

@Component({
  selector: 'app-stocks',
  templateUrl: './stocks.page.html',
  styleUrls: ['./stocks.page.scss'],
  standalone: true,
  imports: [CommonModule, RouterLink, IonContent, IonIcon, IonItemSliding, IonItem, IonItemOptions, IonItemOption]
})
export class StocksPage implements OnInit {
  products$: Observable<Product[]>;

  constructor(private productService: ProductService, private modalCtrl: ModalController) {
    // Enregistrement de toutes les icônes utilisées dans le HTML
    addIcons({ arrowBackOutline, addOutline, cubeOutline, trashOutline, imageOutline, barcodeOutline });
    this.products$ = this.productService.getProducts();
  }

  ngOnInit() {}

  async openAddModal() {
    const modal = await this.modalCtrl.create({ component: ProductModalComponent });
    modal.present();
    const { data, role } = await modal.onWillDismiss();
    if (role === 'confirm' && data) {
      this.productService.addProduct(data);
    }
  }

  deleteProduct(id: string) {
    this.productService.deleteProduct(id);
  }
}
