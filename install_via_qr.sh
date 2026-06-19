#!/bin/bash
# Buscaminas 98 - Instalar APK en móvil vía QR
# Uso: bash install_via_qr.sh

set -e

APK_DIR="$(cd "$(dirname "$0")" && pwd)/APK"
APK_FILE="$APK_DIR/buscaminas-98.apk"
PORT=8888

echo "=== Buscaminas 98 - Instalación vía QR ==="
echo ""

# Verificar APK
if [ ! -f "$APK_FILE" ]; then
    echo "✗ No se encontró el APK. Ejecuta primero: flutter build apk --release"
    exit 1
fi
echo "✓ APK encontrado: $(ls -lh "$APK_FILE" | awk '{print $5}')"

# Detectar IP local
IP=$(ip -4 addr show | grep -oP 'inet \K[\d.]+' | grep -v '127.0.0.1' | head -1)
if [ -z "$IP" ]; then
    IP=$(hostname -I | awk '{print $1}')
fi
if [ -z "$IP" ]; then
    echo "✗ No se pudo detectar la IP local"
    exit 1
fi
echo "✓ IP local: $IP"

URL="http://$IP:$PORT/buscaminas-98.apk"

# Verificar dependencias
HAS_PYTHON=false
HAS_QR=false

if command -v python3 &>/dev/null; then
    HAS_PYTHON=true
    echo "✓ Python3 disponible"
else
    echo "⚠  Python3 no instalado. Intentando instalar..."
    sudo apt-get install -y python3 2>/dev/null && HAS_PYTHON=true || echo "✗ No se pudo instalar python3"
fi

if command -v qrencode &>/dev/null; then
    HAS_QR=true
    echo "✓ qrencode disponible"
else
    echo "⚠  qrencode no instalado. Intentando instalar..."
    sudo apt-get install -y qrencode 2>/dev/null && HAS_QR=true || echo "✗ No se pudo instalar qrencode (usa web https://qrickit.com)"
fi

echo ""
echo "=== ESCANEA EL QR DESDE TU MÓVIL ==="
echo ""

# Mostrar QR
if [ "$HAS_QR" = true ]; then
    qrencode -t ANSIUTF8 "$URL" 2>/dev/null || qrencode -t UTF8 "$URL"
    echo ""
fi

echo "O abre esta URL en el navegador del móvil:"
echo "  $URL"
echo ""

# URL alternativa con qrickit
echo "QR alternativo (copia-pega esta URL):"
echo "  https://api.qrickit.com/qr.php?text=$URL&format=png&size=300"
echo ""

# Iniciar servidor HTTP
echo "=== Iniciando servidor HTTP (Ctrl+C para salir) ==="
echo "Sirviendo: $APK_DIR"
echo ""

cd "$APK_DIR"
if [ "$HAS_PYTHON" = true ]; then
    python3 -m http.server $PORT
else
    echo "✗ No hay python3, no se puede iniciar el servidor"
    echo "  Alternativa: instala 'python3' o usa 'npx serve $APK_DIR'"
    exit 1
fi
