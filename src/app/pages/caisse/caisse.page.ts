import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { IonContent, IonIcon, IonSpinner, ModalController, ToastController } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { arrowBackOutline, scanOutline, cartOutline, basketOutline, removeOutline, addOutline, checkmarkCircleOutline } from 'ionicons/icons';
import { ProductService } from 'src/app/services/product.service';
import { CartService } from 'src/app/services/cart.service';
import { Observable, take } from 'rxjs';
import { Product } from 'src/app/models/product.model';
import { ScanModalComponent } from 'src/app/components/scan-modal/scan-modal.component';
import { ReceiptModalComponent } from 'src/app/components/receipt-modal/receipt-modal.component';

@Component({
  selector: 'app-caisse',
  templateUrl: './caisse.page.html',
  styleUrls: ['./caisse.page.scss'],
  standalone: true,
  imports: [CommonModule, RouterLink, IonContent, IonIcon, IonSpinner]
})
export class CaissePage implements OnInit {

  products$: Observable<Product[]>;
  cart$: Observable<any>;
  isProcessing = false;
  isCartExpanded = false; // Pour mobile

  constructor(
    private productService: ProductService,
    private cartService: CartService,
    private modalCtrl: ModalController,
    private toastCtrl: ToastController
  ) {
    addIcons({ arrowBackOutline, scanOutline, cartOutline, basketOutline, removeOutline, addOutline, checkmarkCircleOutline });
    this.products$ = this.productService.getProducts();
    this.cart$ = this.cartService.cart$;
  }

  ngOnInit() {}

  addToCart(product: Product) { this.cartService.addToCart(product); }
  decreaseItem(id: string) { this.cartService.removeFromCart(id); }

  toggleCartHeight() {
    // Logique future pour agrandir/réduire le panier sur mobile
    // Pour l'instant géré par CSS height fixe
  }

  async openScanner() {
    const modal = await this.modalCtrl.create({ component: ScanModalComponent });
    modal.present();
    const { data, role } = await modal.onWillDismiss();
    if (role === 'scan_success' && data) {
      this.handleScanResult(data);
    }
  }

  private handleScanResult(barcode: string) {
    this.products$.pipe(take(1)).subscribe(products => {
      const found = products.find(p => p.barcode === barcode);
      if (found) {
        this.addToCart(found);
        this.presentToast('Ajouté', 'success');
      } else {
        this.presentToast('Inconnu', 'warning');
      }
    });
  }

  async validateSale() {
    this.isProcessing = true;
    try {
      const sale = await this.cartService.checkout('ESPECES');
      const modal = await this.modalCtrl.create({
        component: ReceiptModalComponent,
        componentProps: { sale: sale },
        backdropDismiss: false
      });
      await modal.present();
      this.presentToast('Vente OK', 'success');
    } catch (error) {
      console.error(error);
      this.presentToast('Erreur vente', 'danger');
    } finally {
      this.isProcessing = false;
    }
  }

  async presentToast(msg: string, color: string) {
    const t = await this.toastCtrl.create({ message: msg, duration: 2000, color, position: 'top', cssClass: 'rounded-xl' });
    t.present();
  }
}
