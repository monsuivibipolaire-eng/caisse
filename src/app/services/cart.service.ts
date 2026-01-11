import { Injectable, inject } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { Firestore, collection, addDoc, serverTimestamp } from '@angular/fire/firestore';
import { Cart, CartItem } from '../models/cart.model';
import { Product } from '../models/product.model';
import { Sale } from '../models/sale.model';

@Injectable({
  providedIn: 'root'
})
export class CartService {
  
  private firestore: Firestore = inject(Firestore);
  private salesCollection = collection(this.firestore, 'sales');

  private cartSubject = new BehaviorSubject<Cart>({ items: [], total: 0, itemCount: 0 });
  cart$ = this.cartSubject.asObservable();

  constructor() { }

  /** Ajoute un produit au panier local */
  addToCart(product: Product) {
    const currentCart = this.cartSubject.value;
    // On clone les items pour éviter les mutations directes
    const items = [...currentCart.items]; 
    const existingItem = items.find(i => i.product.id === product.id);

    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      items.push({ product, quantity: 1 });
    }

    this.recalculate(items);
  }

  /** Retire un item ou décrémente sa quantité */
  removeFromCart(productId: string) {
    const currentCart = this.cartSubject.value;
    let items = [...currentCart.items];
    const itemIndex = items.findIndex(i => i.product.id === productId);

    if (itemIndex > -1) {
      const item = items[itemIndex];
      if (item.quantity > 1) {
        item.quantity -= 1;
      } else {
        items.splice(itemIndex, 1);
      }
      this.recalculate(items);
    }
  }

  /** Vide le panier local */
  clearCart() {
    this.cartSubject.next({ items: [], total: 0, itemCount: 0 });
  }

  /** Envoie le panier vers Firestore (Création de la vente) */
  async saveSale(paymentMethod: 'CASH' | 'CARD' = 'CASH'): Promise<void> {
    const currentCart = this.cartSubject.value;
    
    if (currentCart.items.length === 0) return;

    const sale: Sale = {
      items: currentCart.items,
      total: currentCart.total,
      itemCount: currentCart.itemCount,
      paymentMethod: paymentMethod,
      date: serverTimestamp() // Date serveur pour éviter les fraudes locales
    };

    try {
      await addDoc(this.salesCollection, sale);
      this.clearCart(); // On vide le panier après succès
    } catch (error) {
      console.error("Erreur lors de la vente:", error);
      throw error;
    }
  }

  /** Recalcule les totaux */
  private recalculate(items: CartItem[]) {
    const total = items.reduce((acc, item) => acc + (item.product.price * item.quantity), 0);
    const itemCount = items.reduce((acc, item) => acc + item.quantity, 0);
    this.cartSubject.next({ items, total, itemCount });
  }
}
