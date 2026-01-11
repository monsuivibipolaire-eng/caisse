import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { IonContent, IonIcon, ToastController } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { arrowBackOutline } from 'ionicons/icons';
import { ConfigService } from 'src/app/services/config.service';
import { StoreConfig } from 'src/app/models/config.model';
import { take } from 'rxjs';

@Component({
  selector: 'app-settings',
  templateUrl: './settings.page.html',
  styleUrls: ['./settings.page.scss'],
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, IonContent, IonIcon]
})
export class SettingsPage implements OnInit {
  config: StoreConfig = { name: '', address: '', phone: '', footerMessage: '' };

  constructor(private configService: ConfigService, private toastCtrl: ToastController) {
    addIcons({ arrowBackOutline });
  }

  ngOnInit() {
    this.configService.getConfig().pipe(take(1)).subscribe(d => this.config = d);
  }

  async save() {
    await this.configService.saveConfig(this.config);
    const t = await this.toastCtrl.create({ message: 'Configuration sauvegardée', duration: 1500, color: 'success', position: 'top', cssClass: 'rounded-xl' });
    t.present();
  }
}
