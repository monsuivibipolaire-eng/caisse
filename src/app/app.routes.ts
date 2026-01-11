import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'dashboard',
    pathMatch: 'full',
  },
  {
    path: 'dashboard',
    loadComponent: () => import('./pages/dashboard/dashboard.page').then( m => m.DashboardPage)
  },
  {
    path: 'caisse',
    loadComponent: () => import('./pages/caisse/caisse.page').then( m => m.CaissePage)
  },
  {
    path: 'stocks',
    loadComponent: () => import('./pages/stocks/stocks.page').then( m => m.StocksPage)
  },
  {
    path: 'settings',
    loadComponent: () => import('./pages/settings/settings.page').then( m => m.SettingsPage)
  },
];
