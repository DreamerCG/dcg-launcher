#!/usr/bin/env bash
# BATOCERA - System Install
# TERM=xterm clear > /dev/tty 2>/dev/null || printf "\033c" > /dev/tty

trap 'rm -f "$temp_file"' EXIT

echo "BATOCERA - SYSTEM INSTALL"
echo ""
echo "Attempting to Install  ..."

# Récupération de la version principale de Batocera
version=$(batocera-es-swissknife --version | grep -oE '^[0-9]+')

# Vérification que la version est bien détectée
if [[ -z "$version" ]]; then
    echo "ERROR: Impossible de détecter une version valide de Batocera."
    echo "Installation annulée."
    exit 1
fi

# Vérification stricte : uniquement Batocera 43 autorisée
[[ "$version" =~ ^(42|43)$ ]] || {
    echo "ERROR: Batocera non supportée (détectée: $version)"
    echo "Versions supportées : 42, 43"
    exit 1
}

echo "Batocera $version détectée — poursuite de l'installation."

set -e

# Download and Install BSA
(
	url="https://github.com/DreamerCG/dcg-launcher/archive/refs/heads/main.tar.gz"
    echo $url;
	BSA_path="/userdata/system/dcg"

	# Retrieve and Extract BSA to /userdata/BSA (will overwrite)
	temp_file=$(mktemp) || { echo "ERROR: Failed to create temp file"; exit 1; }
    wget --quiet --show-progress --progress=bar:force:noscroll \
        --tries=10 --timeout=30 --waitretry=3 \
        --no-check-certificate --no-cache --no-cookies \
        -O "$temp_file" \
        --max-redirect=10 \
        "$url"


	[[ -n "$BSA_path" ]] && rm -rf "$BSA_path"
	mkdir -p "$BSA_path"
	tar -xzf "$temp_file" -C "$BSA_path" --strip-components=1
	rm -f "$temp_file"
)

# Copier les fichiers de configuration des systèmes
cp -rf /userdata/system/dcg/configs/emulationstations/* /userdata/system/configs/emulationstation/

# Copier les fichiers de configuration des evmapy
cp -rf /userdata/system/dcg/configs/evmapy/* /userdata/system/configs/evmapy/

# Téléchargement de l'AppImage Play! (PS2 Emulator)
mkdir -p /userdata/system/dcg/emulators/play/
wget --quiet --show-progress --progress=bar:force:noscroll \
    --tries=10 --timeout=30 --waitretry=3 \
    --no-check-certificate --no-cache --no-cookies \
    -O "/userdata/system/dcg/emulators/play/play.AppImage" \
    --max-redirect=10 \
    "https://purei.org/downloads/play/stable/0.72/Play!-8de4a71f-x86_64.AppImage"


# Installation de Demul/Arcabview
mkdir -p /userdata/system/dcg/emulators/demul/
tar -xzf /userdata/system/dcg/emulators/demul.tar.gz -C /userdata/system/dcg/emulators/demul/

# Applications des droits pour Play! (PS2 Emulator)
chmod a+x "/userdata/system/dcg/emulators/play/play.AppImage"

# Applications des droits des binaries de BSA
chmod a+x "/userdata/system/dcg/bin/batocera-wine"

# Supression du fichier install par precautions
# rm -f /userdata/system/dcg/install.sh
# rm -f /userdata/system/dcg/emulators/demul.tar.gz

# Nettoyage des fichiers de configuration temporaires
# rm -rf /userdata/system/dcg/configs/evmapy
# rm -rf /userdata/system/dcg/configs/emulationstations/

echo "System Launcher Installed!"

killall -9 emulationstation || true