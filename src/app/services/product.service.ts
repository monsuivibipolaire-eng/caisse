import { Injectable, inject } from '@angular/core';
import { Firestore, collection, collectionData, addDoc, deleteDoc, doc } from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { Product } from '../models/product.model';

@Injectable({
  providedIn: 'root'
})
export class ProductService {
  
  // Injection du service Firestore
  private firestore: Firestore = inject(Firestore);
  
  // Référence à la collection 'products'
  private productsCollection = collection(this.firestore, 'products');

  // Observable en temps réel (inclut l'ID du document)
  readonly products$: Observable<Product[]> = collectionData(this.productsCollection, {
    idField: 'id',
  }) as Observable<Product[]>;

  constructor() {}

  /**
   * Retourne le flux de données en temps réel
   */
  getProducts(): Observable<Product[]> {
    return this.products$;
  }

  /**
   * Ajoute un produit dans Firestore
   */
  async addProduct(product: Product): Promise<void> {
    // On retire l'id s'il existe (Firestore le génère)
    const { id, ...data } = product;
    
    // Valeur par défaut pour l'image si vide
    if (!data.imageUrl) {
      data.imageUrl = 'https://placehold.co/100x100/e5e7eb/black?text=Produit';
    }

    // Ajout asynchrone
    await addDoc(this.productsCollection, data);
  }

  /**
   * Supprime un produit via son ID Firestore
   */
  async deleteProduct(id: string): Promise<void> {
    const docRef = doc(this.firestore, 'products/' + id);
    await deleteDoc(docRef);
  }
}
