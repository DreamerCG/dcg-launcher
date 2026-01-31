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

	BSA_path="/userdata/system/dcg"

	# Retrieve and Extract BSA to /userdata/BSA (will overwrite)
	temp_file=$(mktemp) || { echo "ERROR: Failed to create temp file"; exit 1; }
	wget --quiet --show-progress --progress=bar:force:noscroll \
		--tries=10 --timeout=30 --waitretry=3 \
		--no-check-certificate --no-cache --no-cookies \
		-O "$temp_file" \
		"$url"
	[[ -n "$BSA_path" ]] && rm -rf "$BSA_path"
	mkdir -p "$BSA_path"
	tar -xzf "$temp_file" -C "$BSA_path" --strip-components=1
	rm -f "$temp_file"
)


# Copier les fichiers de configuration
cp -rf /userdata/system/dcg/system/namco2x6/config/es_systems_namco2x6.cfg /userdata/system/configs/emulationstation/es_systems_namco2x6.cfg
cp -rf /userdata/system/dcg/system/namco2x6/evmappy/namco2x6.keys /userdata/system/configs/evmappy/namco2x6.keys

# Applications des droits
chmod a+x /userdata/system/dcg/system/namco2x6/appimage/play.AppImage

echo "System Launcher Installed!"

