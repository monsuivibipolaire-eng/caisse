#!/bin/bash

# Arrêt immédiat en cas d'erreur
set -e

echo "🧹 Nettoyage complet du projet..."

# 1. Suppression des dossiers corrompus
rm -rf node_modules
rm -f package-lock.json

# 2. Nettoyage du cache NPM (force)
echo "🧹 Nettoyage du cache NPM..."
npm cache clean --force

# 3. Réinstallation propre
echo "📦 Réinstallation des dépendances (Mode Compatibilité)..."
# L'option --legacy-peer-deps est cruciale ici pour faire cohabiter vos versions
npm install --legacy-peer-deps

# 4. Vérification de sécurité
echo "🔍 Vérification des modules ZXing..."
if [ ! -d "node_modules/@zxing/browser" ]; then
    echo "⚠️ Modules ZXing manquants, installation explicite..."
    npm install @zxing/browser @zxing/library --legacy-peer-deps
fi

echo "✅ Réparation terminée."
echo "👉 Vous pouvez relancer 'ionic serve'."