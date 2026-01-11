import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { IonContent, IonIcon, ModalController, ToastController, LoadingController } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { arrowBackOutline, scanOutline, cartOutline, basketOutline, removeOutline, addOutline, arrowForward, add } from 'ionicons/icons';
import { ProductService } from 'src/app/services/product.service';
import { CartService } from 'src/app/services/cart.service';
import { Observable, firstValueFrom, take } from 'rxjs';
import { Product } from 'src/app/models/product.model';
import { Cart } from 'src/app/models/cart.model';
import { Sale } from 'src/app/models/sale.model';
import { ScanModalComponent } from 'src/app/components/scan-modal/scan-modal.component';
import { ReceiptModalComponent } from 'src/app/components/receipt-modal/receipt-modal.component';

@Component({
  selector: 'app-caisse',
  templateUrl: './caisse.page.html',
  styleUrls: ['./caisse.page.scss'],
  standalone: true,
  imports: [CommonModule, RouterLink, IonContent, IonIcon]
})
export class CaissePage implements OnInit {
  products$: Observable<Product[]>;
  cart$: Observable<Cart>;

  constructor(
    private productService: ProductService,
    private cartService: CartService,
    private modalCtrl: ModalController,
    private toastCtrl: ToastController,
    private loadingCtrl: LoadingController
  ) {
    addIcons({ arrowBackOutline, scanOutline, cartOutline, basketOutline, removeOutline, addOutline, arrowForward, add });
    this.products$ = this.productService.getProducts();
    this.cart$ = this.cartService.cart$;
  }

  ngOnInit() {}

  addToCart(product: Product) { this.cartService.addToCart(product); }
  decreaseItem(id: string) { this.cartService.removeFromCart(id); }

  async openScanner() {
    const modal = await this.modalCtrl.create({ component: ScanModalComponent });
    modal.present();
    const { data, role } = await modal.onWillDismiss();
    if (role === 'scan_success' && data) this.handleScanResult(data);
  }

  private handleScanResult(barcode: string) {
    this.products$.pipe(take(1)).subscribe(products => {
      const found = products.find(p => p.barcode === barcode);
      if (found) { this.addToCart(found); this.presentToast('Ajouté au panier', 'success'); }
      else { this.presentToast('Produit introuvable', 'warning'); }
    });
  }

  async checkout() {
    const cart = await firstValueFrom(this.cart$);
    if (!cart || cart.items.length === 0) return;
    
    const loading = await this.loadingCtrl.create({ message: 'Traitement...', duration: 1000, spinner: 'crescent' });
    await loading.present();

    try {
      await this.cartService.saveSale('CASH');
      await loading.dismiss();
      const sale: Sale = { ...cart, paymentMethod: 'CASH', date: { seconds: Date.now()/1000 } } as any;
      const modal = await this.modalCtrl.create({ component: ReceiptModalComponent, componentProps: { sale } });
      await modal.present();
    } catch (e) {
      await loading.dismiss();
      this.presentToast('Erreur lors de la vente', 'danger');
    }
  }

  async presentToast(msg: string, color: string) {
    const t = await this.toastCtrl.create({ message: msg, duration: 2000, color, position: 'top', cssClass: 'custom-toast' });
    t.present();
  }
}
