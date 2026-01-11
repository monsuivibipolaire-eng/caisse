import { Injectable, inject } from '@angular/core';
import { Firestore, collection, query, where, orderBy, limit, collectionData, Timestamp } from '@angular/fire/firestore';
import { Observable, map } from 'rxjs';
import { Sale } from '../models/sale.model';

@Injectable({
  providedIn: 'root'
})
export class StatsService {

  private firestore: Firestore = inject(Firestore);
  private salesCollection = collection(this.firestore, 'sales');

  constructor() { }

  /**
   * Récupère les ventes depuis le début de la journée (00:00)
   */
  getTodaySales(): Observable<Sale[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const startOfDay = Timestamp.fromDate(today);

    // Requête : Ventes où la date >= aujourd'hui 00h
    // Note : Nécessite parfois la création d'un index composite dans la console Firebase
    const q = query(
      this.salesCollection,
      where('date', '>=', startOfDay),
      orderBy('date', 'desc')
    );

    return collectionData(q, { idField: 'id' }) as Observable<Sale[]>;
  }

  /**
   * Récupère les 5 dernières ventes (pour l'historique rapide)
   */
  getRecentSales(): Observable<Sale[]> {
    const q = query(
      this.salesCollection,
      orderBy('date', 'desc'),
      limit(5)
    );
    return collectionData(q, { idField: 'id' }) as Observable<Sale[]>;
  }
}
