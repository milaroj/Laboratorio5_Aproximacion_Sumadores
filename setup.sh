#!/usr/bin/env bash
# =============================================================================
# setup.sh — Actividad 1
# Descarga los sumadores aproximados de EvoApproxLib, copia los .v al
# directorio hdl/ en la raiz del proyecto y elimina el resto.
#
# Uso: bash setup.sh
# =============================================================================

set -euo pipefail   # Aborta si algun comando falla, variable no definida, o pipe falla

# -----------------------------------------------------------------------------
# Configuracion
# -----------------------------------------------------------------------------
REPO_URL="https://github.com/ehw-fit/evoapproxlib.git"
SPARSE_PATH="adders/8_unsigned/pareto_pwr_ep"   # Subcarpeta de interes
TEMP_DIR="evoapproxlib_tmp"                      # Carpeta temporal de clonado
HDL_DIR="hdl"                                    # Destino final de los .v

# -----------------------------------------------------------------------------
# Paso 1: Crear el directorio hdl/ si no existe
# -----------------------------------------------------------------------------
echo "[1/4] Preparando directorio '$HDL_DIR/'..."
mkdir -p "$HDL_DIR"

# -----------------------------------------------------------------------------
# Paso 2: Clonar el repositorio con sparse checkout
#   --depth 1        : solo el commit mas reciente (evita descargar historial)
#   --filter=blob:none : no descarga archivos hasta que se soliciten
#   --sparse         : habilita sparse checkout (descarga parcial)
# -----------------------------------------------------------------------------
echo "[2/4] Clonando repositorio (sparse checkout)..."

if [ -d "$TEMP_DIR" ]; then
    echo "  Directorio temporal '$TEMP_DIR' ya existe, eliminandolo..."
    rm -rf "$TEMP_DIR"
fi

git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" "$TEMP_DIR"

# Dentro del repo temporal, indicar que solo se quiere la subcarpeta objetivo
cd "$TEMP_DIR"
git sparse-checkout set "$SPARSE_PATH"
cd ..

# -----------------------------------------------------------------------------
# Paso 3: Copiar unicamente los archivos .v RTL al directorio hdl/
#   Se excluyen los archivos *_pdk45.v (netlists para tecnologia PDK45,
#   no sintetizables directamente en FPGA Xilinx).
# -----------------------------------------------------------------------------
echo "[3/4] Copiando archivos .v a '$HDL_DIR/'..."

# Construir lista excluyendo variantes _pdk45
V_FILES=()
for f in "$TEMP_DIR/$SPARSE_PATH"/*.v; do
    [[ "$f" == *_pdk45.v ]] && continue
    V_FILES+=("$f")
done

if [ ${#V_FILES[@]} -eq 0 ]; then
    echo "ERROR: No se encontraron archivos .v en '$TEMP_DIR/$SPARSE_PATH'." >&2
    rm -rf "$TEMP_DIR"
    exit 1
fi

cp "${V_FILES[@]}" "$HDL_DIR/"
echo "  Archivos copiados:"
for f in "${V_FILES[@]}"; do
    echo "    - $(basename "$f")"
done

# -----------------------------------------------------------------------------
# Paso 4: Eliminar el repositorio temporal
# -----------------------------------------------------------------------------
echo "[4/4] Eliminando repositorio temporal..."
rm -rf "$TEMP_DIR"

echo ""
echo "Listo. Los archivos .v estan en '$HDL_DIR/':"
ls "$HDL_DIR/"
