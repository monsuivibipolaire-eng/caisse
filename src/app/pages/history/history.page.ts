import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { 
  IonContent, IonIcon, IonModal, IonDatetime, IonDatetimeButton, 
  IonSegment, IonSegmentButton, IonLabel, ModalController 
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { arrowBackOutline, calendarOutline, receiptOutline, cardOutline, cashOutline } from 'ionicons/icons';
import { StatsService } from 'src/app/services/stats.service';
import { Sale } from 'src/app/models/sale.model';
import { Observable, BehaviorSubject, combineLatest, map, switchMap } from 'rxjs';
import { ReceiptModalComponent } from 'src/app/components/receipt-modal/receipt-modal.component';

@Component({
  selector: 'app-history',
  templateUrl: './history.page.html',
  standalone: true,
  imports: [
    CommonModule, RouterLink, FormsModule,
    IonContent, IonIcon, IonModal, IonDatetime, IonDatetimeButton,
    IonSegment, IonSegmentButton, IonLabel
  ]
})
export class HistoryPage implements OnInit {

  // Flux de données
  rangeSubject = new BehaviorSubject<{start: Date, end: Date}>(this.getRange('today'));
  paymentFilter$ = new BehaviorSubject<string>('ALL');
  
  sales$: Observable<Sale[]>;
  stats$: Observable<{ totalRevenue: number, count: number }>;
  
  currentRange: 'today' | 'yesterday' | 'week' | 'custom' = 'today';

  constructor(private statsService: StatsService, private modalCtrl: ModalController) {
    addIcons({ arrowBackOutline, calendarOutline, receiptOutline, cardOutline, cashOutline });

    this.sales$ = combineLatest([
      this.rangeSubject.pipe(
        switchMap(range => this.statsService.getSalesHistory(range.start, range.end))
      ),
      this.paymentFilter$
    ]).pipe(
      map(([sales, paymentType]) => {
        if (paymentType === 'ALL') return sales;
        return sales.filter(s => s.paymentMethod === paymentType);
      })
    );

    this.stats$ = this.sales$.pipe(
      map(sales => ({
        totalRevenue: sales.reduce((acc, s) => acc + s.total, 0),
        count: sales.length
      }))
    );
  }

  ngOnInit() {}

  setRange(type: 'today' | 'yesterday' | 'week') {
    this.currentRange = type;
    this.rangeSubject.next(this.getRange(type));
  }

  onDateChange(event: any) {
    const dateStr = event.detail.value;
    if (dateStr) {
      this.currentRange = 'custom';
      const start = new Date(dateStr);
      start.setHours(0,0,0,0);
      const end = new Date(dateStr);
      end.setHours(23,59,59,999);
      this.rangeSubject.next({ start, end });
    }
  }

  onPaymentChange(event: any) {
    this.paymentFilter$.next(event.detail.value);
  }

  getRange(type: string): {start: Date, end: Date} {
    const start = new Date();
    const end = new Date();
    end.setHours(23, 59, 59, 999);

    if (type === 'today') {
      start.setHours(0, 0, 0, 0);
    } else if (type === 'yesterday') {
      start.setDate(start.getDate() - 1);
      start.setHours(0, 0, 0, 0);
      end.setDate(end.getDate() - 1);
      end.setHours(23, 59, 59, 999);
    } else if (type === 'week') {
      start.setDate(start.getDate() - 7);
      start.setHours(0, 0, 0, 0);
    }
    return { start, end };
  }

  async openReceipt(sale: Sale) {
    const modal = await this.modalCtrl.create({
      component: ReceiptModalComponent,
      componentProps: { sale: sale }
    });
    await modal.present();
  }
}
