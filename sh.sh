#!/bin/bash

# Arrêter le script en cas d'erreur
set -e

echo "🛒 Implémentation de la logique Caisse (Services + UI)..."

# 1. Mise à jour du ProductService (Données Mock)
echo "📦 Configuration de ProductService..."
cat > src/app/services/product.service.ts <<EOF
import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { Product } from '../models/product.model';

@Injectable({
  providedIn: 'root'
})
export class ProductService {

  // Données de test pour l'instant
  private mockProducts: Product[] = [
    { id: '1', name: 'Café Espresso', price: 2.50, category: 'Boissons', stock: 100, imageUrl: 'https://placehold.co/100x100/3b82f6/white?text=Cafe' },
    { id: '2', name: 'Croissant', price: 1.20, category: 'Viennoiserie', stock: 50, imageUrl: 'https://placehold.co/100x100/fbbf24/white?text=Croissant' },
    { id: '3', name: 'Jus d Orange', price: 3.00, category: 'Boissons', stock: 30, imageUrl: 'https://placehold.co/100x100/f97316/white?text=Jus' },
    { id: '4', name: 'Sandwich Thon', price: 4.50, category: 'Snack', stock: 20, imageUrl: 'https://placehold.co/100x100/10b981/white?text=Sandwich' },
    { id: '5', name: 'Eau Minérale', price: 1.00, category: 'Boissons', stock: 200, imageUrl: 'https://placehold.co/100x100/06b6d4/white?text=Eau' },
    { id: '6', name: 'Chocolat Chaud', price: 2.80, category: 'Boissons', stock: 40, imageUrl: 'https://placehold.co/100x100/78350f/white?text=Choco' },
  ];

  constructor() { }

  getProducts(): Observable<Product[]> {
    return of(this.mockProducts);
  }
}
EOF

# 2. Mise à jour du CartService (Logique Panier)
echo "🛒 Configuration de CartService..."
cat > src/app/services/cart.service.ts <<EOF
import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { Cart, CartItem } from '../models/cart.model';
import { Product } from '../models/product.model';

@Injectable({
  providedIn: 'root'
})
export class CartService {

  private cartSubject = new BehaviorSubject<Cart>({ items: [], total: 0, itemCount: 0 });
  cart$ = this.cartSubject.asObservable();

  constructor() { }

  addToCart(product: Product) {
    const currentCart = this.cartSubject.value;
    const existingItem = currentCart.items.find(i => i.product.id === product.id);

    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      currentCart.items.push({ product, quantity: 1 });
    }

    this.updateCart(currentCart);
  }

  removeFromCart(productId: string) {
    const currentCart = this.cartSubject.value;
    const itemIndex = currentCart.items.findIndex(i => i.product.id === productId);

    if (itemIndex > -1) {
      const item = currentCart.items[itemIndex];
      if (item.quantity > 1) {
        item.quantity -= 1;
      } else {
        currentCart.items.splice(itemIndex, 1);
      }
      this.updateCart(currentCart);
    }
  }

  clearCart() {
    this.updateCart({ items: [], total: 0, itemCount: 0 });
  }

  private updateCart(cart: Cart) {
    cart.total = cart.items.reduce((acc, item) => acc + (item.product.price * item.quantity), 0);
    cart.itemCount = cart.items.reduce((acc, item) => acc + item.quantity, 0);
    this.cartSubject.next({ ...cart });
  }
}
EOF

# 3. Mise à jour de CaissePage (TS)
echo "⚡ Configuration de la logique CaissePage (TS)..."
cat > src/app/pages/caisse/caisse.page.ts <<EOF
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
EOF

# 4. Mise à jour de CaissePage (HTML)
echo "🖥️  Construction de l'interface CaissePage (HTML)..."
cat > src/app/pages/caisse/caisse.page.html <<EOF
<ion-header>
  <ion-toolbar color="primary">
    <ion-buttons slot="start">
      <ion-button routerLink="/dashboard">
        <ion-icon slot="icon-only" name="home-outline"></ion-icon>
      </ion-button>
    </ion-buttons>
    <ion-title>Caisse</ion-title>
    <ion-buttons slot="end">
      <ion-button>
        <ion-icon slot="start" name="cart-outline"></ion-icon>
        <ng-container *ngIf="cart$ | async as cart">
           {{ cart.itemCount }}
        </ng-container>
      </ion-button>
    </ion-buttons>
  </ion-toolbar>
</ion-header>

<ion-content [fullscreen]="true" class="bg-gray-100">
  <ion-grid class="h-full">
    <ion-row class="h-full">
      
      <ion-col size="12" size-md="7" size-lg="8" class="overflow-y-auto">
        <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 p-2">
          <ion-card 
            *ngFor="let product of products$ | async" 
            (click)="addToCart(product)"
            class="m-0 cursor-pointer active:scale-95 transition-transform hover:shadow-lg bg-white">
            <img [src]="product.imageUrl" class="h-24 w-full object-cover" alt="img" />
            <ion-card-content class="p-2 text-center">
              <h3 class="font-bold text-gray-800 text-sm truncate">{{ product.name }}</h3>
              <p class="text-blue-600 font-bold">{{ product.price | currency:'EUR' }}</p>
            </ion-card-content>
          </ion-card>
        </div>
      </ion-col>

      <ion-col size="12" size-md="5" size-lg="4" class="bg-white border-l h-full flex flex-col shadow-xl">
        
        <div class="p-4 bg-gray-50 border-b">
          <h2 class="text-xl font-bold flex items-center">
            Ticket en cours
          </h2>
        </div>

        <div class="flex-1 overflow-y-auto">
          <ng-container *ngIf="cart$ | async as cart">
            <ion-list lines="full">
              <ion-item *ngFor="let item of cart.items">
                <ion-label class="whitespace-normal">
                  <h2>{{ item.product.name }}</h2>
                  <p>{{ item.product.price | currency:'EUR' }} x {{ item.quantity }}</p>
                </ion-label>
                <div slot="end" class="flex items-center gap-2">
                  <ion-button fill="clear" color="medium" (click)="decreaseItem(item.product.id!)">
                    <ion-icon slot="icon-only" name="remove-circle-outline"></ion-icon>
                  </ion-button>
                  <span class="font-bold w-4 text-center">{{ item.quantity }}</span>
                  <ion-button fill="clear" color="primary" (click)="addToCart(item.product)">
                    <ion-icon slot="icon-only" name="add-circle-outline"></ion-icon>
                  </ion-button>
                </div>
              </ion-item>
              
              <div *ngIf="cart.items.length === 0" class="p-8 text-center text-gray-400">
                <ion-icon name="cart-outline" class="text-6xl mb-2"></ion-icon>
                <p>Le panier est vide</p>
              </div>
            </ion-list>
          </ng-container>
        </div>

        <div class="p-4 border-t bg-gray-50" *ngIf="cart$ | async as cart">
          <div class="flex justify-between items-center mb-4 text-xl font-bold">
            <span>Total</span>
            <span class="text-blue-600">{{ cart.total | currency:'EUR' }}</span>
          </div>
          <ion-button expand="block" size="large" (click)="checkout()" [disabled]="cart.items.length === 0">
            ENCAISSER
          </ion-button>
        </div>

      </ion-col>
    </ion-row>
  </ion-grid>
</ion-content>
EOF

echo "✅ Feature Caisse implémentée (Mock Data)."
echo "🚀 Le serveur Ionic devrait se recharger."