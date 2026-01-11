import { Injectable, inject } from '@angular/core';
import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';
import { Storage, ref, uploadBytes, getDownloadURL } from '@angular/fire/storage';

@Injectable({
  providedIn: 'root'
})
export class ImageService {
  
  private storage: Storage = inject(Storage);

  constructor() { }

  /**
   * Ouvre la caméra ou la galerie, compresse l'image et la retourne en Base64
   */
  async selectImage(): Promise<string | undefined> {
    try {
      const image = await Camera.getPhoto({
        quality: 70, // Compression pour économiser la data
        allowEditing: false,
        resultType: CameraResultType.Base64,
        source: CameraSource.Prompt, // Demande : Caméra ou Galerie
        width: 600 // Redimensionnement automatique
      });

      return image.base64String;
    } catch (e) {
      console.log('Sélection annulée par l utilisateur');
      return undefined;
    }
  }

  /**
   * Envoie l'image Base64 vers Firebase Storage et retourne l'URL publique
   */
  async uploadImage(base64: string): Promise<string> {
    const fileName = `products/${new Date().getTime()}.jpeg`;
    const storageRef = ref(this.storage, fileName);

    // Conversion Base64 -> Blob
    const response = await fetch(`data:image/jpeg;base64,${base64}`);
    const blob = await response.blob();

    // Upload
    await uploadBytes(storageRef, blob);
    
    // Récupération de l'URL
    return await getDownloadURL(storageRef);
  }
}
