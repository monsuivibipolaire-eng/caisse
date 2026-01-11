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
