#!/bin/bash
# ============================================================
# empaquetar_codigo.sh
# Genera un ZIP con el código fuente importante de Buscaminas,
# excluyendo build/, .dart_tool/, .git/, .idea/, APK/,
# archivos generados y lo que ignora .gitignore.
# ============================================================

set -e

PROYECTO="buscaminas"
FECHA=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="$(dirname "$0")"
OUTPUT_ZIP="${OUTPUT_DIR}/${PROYECTO}_src_${FECHA}.zip"

echo "📦 Empaquetando código fuente de $PROYECTO..."
echo "   Destino: $OUTPUT_ZIP"
echo ""

# Cambiar al directorio raíz del proyecto (donde está .git)
cd "$(git rev-parse --show-toplevel)"

# Construir lista de exclusiones como regex (patrones que matchean
# en cualquier parte de la ruta, como los .gitignore)
EXCLUIR_REGEX=(
  '(^|/)build/'
  '(^|/)\.dart_tool/'
  '(^|/)\.pub-cache/'
  '(^|/)\.git/'
  '(^|/)\.idea/'
  '(^|/)\.opencode/'
  '(^|/)APK/'
  '(^|/)coverage/'
  '(^|/)script_tools/'
  '\.iml$'
  '\.ipr$'
  '\.iws$'
  '(^|/)\.flutter-plugins$'
  '(^|/)\.flutter-plugins-dependencies$'
  '(^|/)\.metadata$'
  '(^|/)\.packages$'
  '(^|/)pubspec\.lock$'
  '\.apk$'
  '\.aab$'
  '\.ipa$'
  '\.log$'
  '\.swp$'
  '\.swo$'
  '(^|/)\.DS_Store$'
)

# --- Lista de archivos: tracked por git (respeta .gitignore) ---
ARCHIVOS=$(mktemp)
git ls-files > "$ARCHIVOS"

# Agregar untracked no ignorados (ej: nuevos archivos sin commit)
git ls-files --others --exclude-standard >> "$ARCHIVOS"

# --- Aplicar filtros de exclusión ---
for PATRON in "${EXCLUIR_REGEX[@]}"; do
  grep -v -E "$PATRON" "$ARCHIVOS" > "${ARCHIVOS}.tmp" && mv "${ARCHIVOS}.tmp" "$ARCHIVOS"
done

# Limpiar duplicados y ordenar
sort -u "$ARCHIVOS" -o "$ARCHIVOS"

TOTAL=$(wc -l < "$ARCHIVOS")

if [ "$TOTAL" -eq 0 ]; then
  echo "❌ No se encontraron archivos para empaquetar."
  rm -f "$ARCHIVOS"
  exit 1
fi

echo "   Archivos a incluir: $TOTAL"
echo ""

# --- Crear el ZIP ---
# -9: máxima compresión
# -@: leer lista desde stdin
tr '\n' '\0' < "$ARCHIVOS" | xargs -0 zip -9 -q "$OUTPUT_ZIP" -@

# Mostrar resultado
echo "✅ ZIP generado exitosamente:"
echo "   $(ls -lh "$OUTPUT_ZIP" | awk '{print $5}') — $(basename "$OUTPUT_ZIP")"
echo ""

# Mostrar preview de lo incluido
echo "📁 Preview de archivos incluidos:"
unzip -l "$OUTPUT_ZIP" | head -50
echo "   ... ($TOTAL archivos en total)"
echo ""

# Limpiar
rm -f "$ARCHIVOS"
