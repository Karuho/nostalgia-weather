#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE="$ROOT/package"
ID="io.github.karuho.nostalgiaweather"

if kpackagetool6 \
    --type Plasma/Applet \
    --upgrade "$PACKAGE" >/dev/null 2>&1
then
    echo "Nostalgia Weather actualizado."
else
    kpackagetool6 \
        --type Plasma/Applet \
        --install "$PACKAGE"

    echo "Nostalgia Weather instalado."
fi

kbuildsycoca6 --noincremental >/dev/null 2>&1 || true

echo
echo "Widget: $ID"
echo "Prueba ventana: plasmawindowed $ID"
echo "Prueba bandeja: plasmawindowed --statusnotifier $ID"
