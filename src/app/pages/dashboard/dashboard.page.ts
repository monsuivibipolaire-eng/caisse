import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { IonContent, IonIcon } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { settingsOutline, walletOutline, trendingUpOutline, calculatorOutline, cubeOutline, timeOutline, receiptOutline } from 'ionicons/icons';
import { StatsService } from 'src/app/services/stats.service';
import { Observable, map } from 'rxjs';
import { Chart, registerables } from 'chart.js';

// Enregistrement des composants Chart.js
Chart.register(...registerables);

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.page.html',
  styleUrls: ['./dashboard.page.scss'],
  standalone: true,
  imports: [CommonModule, RouterLink, IonContent, IonIcon]
})
export class DashboardPage implements OnInit, AfterViewInit {

  // Observables KPI
  todaySales$ = this.statsService.getTodaySales();
  
  totalRevenue$: Observable<number>;
  totalCount$: Observable<number>;

  // Gestion du Graphique
  chart: any;

  constructor(private statsService: StatsService) {
    addIcons({ settingsOutline, walletOutline, trendingUpOutline, calculatorOutline, cubeOutline, timeOutline, receiptOutline });

    this.totalRevenue$ = this.todaySales$.pipe(
      map(sales => sales.reduce((acc, sale) => acc + sale.total, 0))
    );

    this.totalCount$ = this.todaySales$.pipe(
      map(sales => sales.length)
    );
  }

  ngOnInit() {}

  ngAfterViewInit() {
    this.loadChartData();
  }

  loadChartData() {
    // Simulation de données sur 7 jours (Pour l'exemple, à remplacer par une vraie requête StatsService)
    // Dans une vraie app, StatsService aurait une méthode getLast7DaysSales()
    const labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const data = [120, 190, 30, 50, 20, 300, 450]; // Exemple mock

    this.createChart(labels, data);
  }

  createChart(labels: string[], data: number[]) {
    const canvas = document.getElementById('salesChart') as HTMLCanvasElement;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Dégradé pour les barres
    const gradient = ctx.createLinearGradient(0, 0, 0, 400);
    gradient.addColorStop(0, 'rgba(79, 70, 229, 0.8)'); // Indigo-600
    gradient.addColorStop(1, 'rgba(79, 70, 229, 0.1)');

    this.chart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'CA Journalier',
          data: data,
          backgroundColor: gradient,
          borderRadius: 6,
          barThickness: 12
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false } // Pas de légende pour garder épuré
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: { display: false }, // Pas de grille Y
            ticks: { display: false } // Pas de chiffres Y (minimaliste)
          },
          x: {
            grid: { display: false }, // Pas de grille X
            ticks: { 
              font: { size: 10, weight: 'bold' },
              color: '#94a3b8' // Slate-400
            }
          }
        }
      }
    });
  }
}
