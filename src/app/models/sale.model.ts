import { CartItem } from './cart.model';

export interface Sale {
  id?: string;
  items: CartItem[];
  total: number;
  itemCount: number;
  date: any; // Timestamp Firestore
  paymentMethod: 'CASH' | 'CARD';
}
