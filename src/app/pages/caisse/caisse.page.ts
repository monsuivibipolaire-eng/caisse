import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common'; // Important pour AsyncPipe, CurrencyPipe
import { RouterLink } from '@angular/router';
import { 
  IonContent, IonHeader, IonTitle, IonToolbar, 
  IonButtons, IonButton, IonIcon, IonGrid, IonRow, IonCol,
  IonCard, IonCardContent, IonBadge, IonFooter, IonList, IonItem, IonLabel, IonNote
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { homeOutline, trashOutline, addCircleOutline, removeCircleOutline, cartOutline } from 'ionicons/icons';
import { ProductService } from 'src/app/services/product.service';
import { CartService } from 'src/app/services/cart.service';
import { Observable } from 'rxjs';
import { Product } from 'src/app/models/product.model';
import { Cart } from 'src/app/models/cart.model';

@Component({
  selector: 'app-caisse',
  templateUrl: './caisse.page.html',
  styleUrls: ['./caisse.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterLink,
    IonContent, IonHeader, IonTitle, IonToolbar, 
    IonButtons, IonButton, IonIcon, IonGrid, IonRow, IonCol,
    IonCard, IonCardContent, IonBadge, IonFooter, IonList, IonItem, IonLabel, IonNote
  ]
})
export class CaissePage implements OnInit {

  products$: Observable<Product[]>;
  cart$: Observable<Cart>;

  constructor(
    private productService: ProductService,
    private cartService: CartService
  ) {
    addIcons({ homeOutline, trashOutline, addCircleOutline, removeCircleOutline, cartOutline });
    this.products$ = this.productService.getProducts();
    this.cart$ = this.cartService.cart$;
  }

  ngOnInit() {
  }

  addToCart(product: Product) {
    this.cartService.addToCart(product);
  }

  decreaseItem(productId: string) {
    this.cartService.removeFromCart(productId);
  }

  checkout() {
    console.log('Paiement initié');
    // TODO: Implémenter le modal de paiement
  }
}
