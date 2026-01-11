import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { IonContent, IonIcon } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { calculatorOutline, cubeOutline, settingsOutline, trendingUpOutline, walletOutline, timeOutline, receiptOutline } from 'ionicons/icons';
import { StatsService } from 'src/app/services/stats.service';
import { Sale } from 'src/app/models/sale.model';
import { Observable, map } from 'rxjs';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.page.html',
  styleUrls: ['./dashboard.page.scss'],
  standalone: true,
  imports: [CommonModule, RouterLink, IonContent, IonIcon]
})
export class DashboardPage implements OnInit {
  todaySales$: Observable<Sale[]>;
  recentSales$: Observable<Sale[]>;
  totalRevenue$: Observable<number>;
  totalCount$: Observable<number>;

  constructor(private statsService: StatsService) {
    addIcons({ calculatorOutline, cubeOutline, settingsOutline, trendingUpOutline, walletOutline, timeOutline, receiptOutline });
    this.todaySales$ = this.statsService.getTodaySales();
    this.recentSales$ = this.statsService.getRecentSales();
    this.totalRevenue$ = this.todaySales$.pipe(map(sales => sales.reduce((acc, s) => acc + s.total, 0)));
    this.totalCount$ = this.todaySales$.pipe(map(sales => sales.length));
  }

  ngOnInit() {}
}
