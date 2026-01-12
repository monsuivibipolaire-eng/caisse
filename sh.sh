#!/bin/bash

# Arrêter le script en cas d'erreur
set -e

echo "🚑 Réparation critique du Build (Fichiers SCSS manquants)..."

# 1. Création du fichier manquant qui cause le crash
echo "📄 Création de src/app/pages/history/history.page.scss..."
cat > src/app/pages/history/history.page.scss <<EOF
/* Style spécifique à l'historique */
ion-segment-button {
  --indicator-color: #4f46e5; /* Indigo 600 */
  --color-checked: #fff;
  --color: #64748b; /* Slate 500 */
}
EOF

# 2. Vérification de sécurité pour les autres pages (au cas où)
# On crée des fichiers vides si ils n'existent pas pour éviter d'autres crashs

mkdir -p src/app/pages/staff
if [ ! -f src/app/pages/staff/staff.page.scss ]; then
    echo "📄 Création de src/app/pages/staff/staff.page.scss..."
    echo "" > src/app/pages/staff/staff.page.scss
fi

mkdir -p src/app/pages/settings
if [ ! -f src/app/pages/settings/settings.page.scss ]; then
    echo "📄 Création de src/app/pages/settings/settings.page.scss..."
    echo "" > src/app/pages/settings/settings.page.scss
fi

mkdir -p src/app/pages/stocks
if [ ! -f src/app/pages/stocks/stocks.page.scss ]; then
    echo "📄 Création de src/app/pages/stocks/stocks.page.scss..."
    echo "" > src/app/pages/stocks/stocks.page.scss
fi

echo "✅ Réparation terminée. Relancez 'ionic serve'."