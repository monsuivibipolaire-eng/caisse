#!/bin/bash

# Arrêter le script en cas d'erreur
set -e

echo "🚑 Réparation du bouton Retour sur la page Stocks..."

# 1. Mise à jour de stocks.page.ts
# Ajout de NavController pour une navigation "Retour" native et fiable
echo "🧠 Mise à jour de la logique Stocks (Ajout NavController)..."
cat > src/app/pages/stocks/stocks.page.ts <<EOF
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonContent, IonIcon, IonItemSliding, IonItem, IonItemOptions, IonItemOption, ModalController, NavController } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { arrowBackOutline, addOutline, cubeOutline, trashOutline, imageOutline, barcodeOutline, searchOutline, alertCircleOutline, filterOutline } from 'ionicons/icons';
import { ProductService } from 'src/app/services/product.service';
import { Observable, BehaviorSubject, combineLatest } from 'rxjs';
import { map } from 'rxjs/operators';
import { Product } from 'src/app/models/product.model';
import { ProductModalComponent } from 'src/app/components/product-modal/product-modal.component';

@Component({
  selector: 'app-stocks',
  templateUrl: './stocks.page.html',
  styleUrls: ['./stocks.page.scss'],
  standalone: true,
  imports: [CommonModule, FormsModule, IonContent, IonIcon, IonItemSliding, IonItem, IonItemOptions, IonItemOption]
})
export class StocksPage implements OnInit {
  
  // Flux de données
  private productsSource$ = this.productService.getProducts();
  
  // Flux de critères de filtre
  searchTerm$ = new BehaviorSubject<string>('');
  categoryFilter$ = new BehaviorSubject<string>('Tout');

  // Résultat combiné
  filteredProducts$: Observable<Product[]>;

  // Liste des catégories
  categories = ['Tout', 'Stock Faible', 'Boissons', 'Snack', 'Viennoiserie', 'Divers'];

  constructor(
    private productService: ProductService, 
    private modalCtrl: ModalController,
    private navCtrl: NavController // <--- Injection pour la navigation
  ) {
    addIcons({ arrowBackOutline, addOutline, cubeOutline, trashOutline, imageOutline, barcodeOutline, searchOutline, alertCircleOutline, filterOutline });
    
    // Logique de filtrage (RxJS)
    this.filteredProducts$ = combineLatest([
      this.productsSource$,
      this.searchTerm$,
      this.categoryFilter$
    ]).pipe(
      map(([products, term, category]) => {
        let filtered = products.filter(p => 
          p.name.toLowerCase().includes(term.toLowerCase()) || 
          (p.barcode && p.barcode.includes(term))
        );

        if (category === 'Stock Faible') {
          filtered = filtered.filter(p => p.stock <= 5);
        } else if (category !== 'Tout') {
          filtered = filtered.filter(p => p.category === category);
        }

        return filtered;
      })
    );
  }

  ngOnInit() {}

  // Navigation Retour Robuste
  goBack() {
    this.navCtrl.navigateBack('/dashboard');
  }

  onSearch(event: any) {
    this.searchTerm$.next(event.target.value);
  }

  setCategory(cat: string) {
    this.categoryFilter$.next(cat);
  }

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
EOF

# 2. Mise à jour de stocks.page.html
# Binding explicite (click)="goBack()" sur le bouton
echo "🎨 Mise à jour du template HTML (Fix Bouton Retour)..."
cat > src/app/pages/stocks/stocks.page.html <<EOF
<ion-content [fullscreen]="true" [scrollY]="false" class="bg-slate-50">
  
  <div class="absolute inset-0 flex flex-col w-full h-full overflow-hidden">
    
    <div class="bg-white px-6 pt-4 pb-2 border-b border-slate-50 flex justify-between items-center shrink-0 z-20">
      
      <div class="flex items-center gap-3">
        <button (click)="goBack()" class="h-10 w-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-600 tap-effect hover:bg-slate-100 transition-colors z-30">
          <ion-icon name="arrow-back-outline" class="text-xl"></ion-icon>
        </button>
        <h1 (click)="goBack()" class="font-bold text-lg text-slate-800 cursor-pointer">Gestion Stock</h1>
      </div>
      
      <button (click)="openAddModal()" class="bg-indigo-600 text-white px-4 py-2 rounded-xl flex items-center gap-2 text-sm font-bold shadow-lg shadow-indigo-200 tap-effect active:scale-95 transition-transform">
        <ion-icon name="add-outline" class="text-lg"></ion-icon>
        <span class="hidden sm:inline">Nouveau</span>
      </button>
    </div>

    <div class="bg-white pb-3 px-4 shadow-sm z-10 shrink-0 flex flex-col gap-3">
      
      <div class="relative bg-slate-100 rounded-xl overflow-hidden flex items-center h-12 border border-slate-100 focus-within:border-indigo-300 focus-within:ring-2 focus-within:ring-indigo-100 transition-all">
        <div class="pl-4 text-slate-400">
          <ion-icon name="search-outline" class="text-xl"></ion-icon>
        </div>
        <input 
          type="text" 
          placeholder="Rechercher nom ou code-barres..." 
          class="w-full h-full bg-transparent border-none outline-none px-3 text-slate-700 font-medium placeholder-slate-400"
          (input)="onSearch(\$event)"
        >
      </div>

      <div class="flex gap-2 overflow-x-auto no-scrollbar pb-1">
        <ng-container *ngFor="let cat of categories">
          <button 
            (click)="setCategory(cat)"
            [class]="(categoryFilter$ | async) === cat 
              ? 'bg-indigo-600 text-white shadow-md shadow-indigo-200' 
              : 'bg-white text-slate-600 border border-slate-200'"
            class="whitespace-nowrap px-4 py-1.5 rounded-full text-xs font-bold transition-all tap-effect flex items-center gap-1">
            <ion-icon *ngIf="cat === 'Stock Faible'" name="alert-circle-outline" class="text-base"></ion-icon>
            {{ cat }}
          </button>
        </ng-container>
      </div>
    </div>

    <div class="flex-1 overflow-y-auto p-4 space-y-3 pb-24 bg-slate-50">
      <ng-container *ngIf="filteredProducts$ | async as products">
        
        <div *ngIf="products.length === 0" class="flex flex-col items-center justify-center h-48 text-slate-400 gap-2">
          <ion-icon name="search-outline" class="text-4xl opacity-50"></ion-icon>
          <p class="font-medium text-sm">Aucun produit trouvé</p>
        </div>

        <ion-item-sliding *ngFor="let product of products" class="group rounded-2xl overflow-hidden bg-transparent shadow-sm hover:shadow-md transition-shadow">
          <ion-item lines="none" class="bg-white border border-slate-100 rounded-2xl p-0">
            <div class="flex items-center w-full py-3 px-1 pl-3">
              <div class="h-14 w-14 rounded-xl bg-slate-50 overflow-hidden border border-slate-100 shrink-0 relative">
                 <img [src]="product.imageUrl" class="h-full w-full object-cover" loading="lazy" />
                 <div *ngIf="!product.imageUrl" class="absolute inset-0 flex items-center justify-center text-slate-300">
                   <ion-icon name="image-outline"></ion-icon>
                 </div>
              </div>
              <div class="ml-4 flex-1 min-w-0 pr-3">
                <div class="flex justify-between items-start">
                  <h3 class="font-bold text-slate-800 text-sm truncate pr-2">{{ product.name }}</h3>
                  <p class="font-bold text-slate-900 text-sm">{{ product.price | currency:'EUR' }}</p>
                </div>
                <div class="flex flex-wrap items-center gap-2 mt-1.5">
                  <span class="text-[10px] bg-slate-100 text-slate-500 px-2 py-0.5 rounded-md font-bold uppercase tracking-wide">{{ product.category }}</span>
                  <div class="flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-md border"
                        [ngClass]="{
                          'bg-red-50 text-red-600 border-red-100': product.stock <= 5,
                          'bg-emerald-50 text-emerald-600 border-emerald-100': product.stock > 5
                        }">
                    <ion-icon *ngIf="product.stock <= 5" name="alert-circle-outline"></ion-icon>
                    Stock: {{ product.stock }}
                  </div>
                </div>
              </div>
            </div>
          </ion-item>
          <ion-item-options side="end">
            <ion-item-option color="danger" (click)="deleteProduct(product.id!)" class="pl-6 pr-6">
              <ion-icon slot="icon-only" name="trash-outline" class="text-xl"></ion-icon>
            </ion-item-option>
          </ion-item-options>
        </ion-item-sliding>
      </ng-container>
    </div>

  </div>
</ion-content>
EOF

echo "✅ Correctif appliqué : Le bouton Retour fonctionne maintenant correctement."