import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, map } from 'rxjs';
import { Product } from '../models/product.model';
import { CartItem, Sale } from '../models/sale.model';
import { Firestore, collection, doc, writeBatch, serverTimestamp } from '@angular/fire/firestore';

export interface CartState {
  items: CartItem[];
  total: number;
  itemCount: number;
}

@Injectable({
  providedIn: 'root'
})
export class CartService {
  
  private firestore: Firestore = inject(Firestore);
  
  private initialState: CartState = { items: [], total: 0, itemCount: 0 };
  private cartSubject = new BehaviorSubject<CartState>(this.initialState);
  
  cart$ = this.cartSubject.asObservable();

  constructor() {}

  // Ajouter au panier
  addToCart(product: Product) {
    const current = this.cartSubject.value;
    const existingItem = current.items.find(i => i.product.id === product.id);

    let newItems;
    if (existingItem) {
      existingItem.quantity++;
      newItems = [...current.items];
    } else {
      newItems = [...current.items, { product, quantity: 1 }];
    }

    this.updateCart(newItems);
  }

  // Retirer du panier
  removeFromCart(productId: string) {
    const current = this.cartSubject.value;
    const existingItem = current.items.find(i => i.product.id === productId);

    if (!existingItem) return;

    let newItems;
    if (existingItem.quantity > 1) {
      existingItem.quantity--;
      newItems = [...current.items];
    } else {
      newItems = current.items.filter(i => i.product.id !== productId);
    }

    this.updateCart(newItems);
  }

  // Vider le panier
  clearCart() {
    this.cartSubject.next(this.initialState);
  }

  private updateCart(items: CartItem[]) {
    const total = items.reduce((acc, i) => acc + (i.product.price * i.quantity), 0);
    const itemCount = items.reduce((acc, i) => acc + i.quantity, 0);
    this.cartSubject.next({ items, total, itemCount });
  }

  // --- LE COEUR DU SYSTEME : CHECKOUT ---
  // Utilise un BATCH pour :
  // 1. Créer la vente
  // 2. Mettre à jour les stocks de CHAQUE produit
  async checkout(paymentMethod: 'ESPECES' | 'CARTE'): Promise<Sale> {
    const current = this.cartSubject.value;
    if (current.items.length === 0) throw new Error('Panier vide');

    const batch = writeBatch(this.firestore);
    
    // 1. Préparer la Vente
    const saleRef = doc(collection(this.firestore, 'sales'));
    const saleData: Sale = {
      id: saleRef.id,
      items: current.items,
      total: current.total,
      itemCount: current.itemCount,
      paymentMethod,
      date: serverTimestamp()
    };
    batch.set(saleRef, saleData);

    // 2. Préparer la mise à jour des Stocks
    current.items.forEach(item => {
      if (item.product.id) {
        const productRef = doc(this.firestore, 'products', item.product.id);
        // On calcule le nouveau stock
        const newStock = (item.product.stock || 0) - item.quantity;
        batch.update(productRef, { stock: newStock });
      }
    });

    // 3. Exécuter tout en même temps
    await batch.commit();

    // 4. Vider le panier local
    this.clearCart();

    return saleData;
  }
}
