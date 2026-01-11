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
