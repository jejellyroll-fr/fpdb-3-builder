#!/bin/bash

# Déterminer le système d'exploitation
if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
    # Windows
    dest_dir="$APPDATA/fpdb"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    dest_dir="$HOME/.fpdb"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    dest_dir="$HOME/.fpdb"
else
    echo "Système d'exploitation non reconnu"
    exit 1
fi

# Créer le répertoire de destination s'il n'existe pas
mkdir -p "$dest_dir"

# Copier le fichier de config
if cp "fpdb-3/HUD_config.xml" "$dest_dir/"; then
    echo "Le fichier HUD_config.xml a été copié avec succès dans $dest_dir"
else
    echo "Erreur lors de la copie du fichier"
    exit 1
fi
# Copier le fichier de conf du log
if cp "fpdb-3/logging.conf" "$dest_dir/"; then
    echo "Le fichier HUD_config.xml a été copié avec succès dans $dest_dir"
else
    echo "Erreur lors de la copie du fichier"
    exit 1
fi