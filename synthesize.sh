#!/usr/bin/env bash
# =============================================================================
# synthesize.sh — Actividad 2
# Itera sobre los archivos .v en hdl/, sintetiza cada uno en Vivado en modo
# batch (sin interfaz grafica) y guarda el reporte de utilizacion como
# reports/<nombre>.log
#
# Prerequisito (Windows): Vivado instalado en C:\Xilinx\Vivado\2024.1
#   El script agrega automaticamente el bin al PATH si no esta disponible.
#   Ajusta la variable VIVADO_BIN si tu instalacion esta en otra ruta.
#
# Uso: bash synthesize.sh
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuracion
# -----------------------------------------------------------------------------
HDL_DIR="hdl"                   # Directorio con los .v (generado por setup.sh)
REPORTS_DIR="reports"           # Directorio de salida de reportes
PART="xc7a100tcsg324-1"         # FPGA objetivo: Nexys A7-100T
TCL_TMP=".synth_tmp.tcl"        # Archivo TCL temporal (se borra al terminar)
VIVADO_BIN="/c/Xilinx/Vivado/2024.1/bin"  # Ruta al directorio bin de Vivado (Windows)
VIVADO_CMD="vivado.bat"         # Ejecutable de Vivado (vivado.bat en Windows, vivado en Linux)

# -----------------------------------------------------------------------------
# Verificaciones previas
# -----------------------------------------------------------------------------
# Agregar Vivado al PATH si no esta disponible aun
if ! command -v "$VIVADO_CMD" &>/dev/null; then
    export PATH="$VIVADO_BIN:$PATH"
fi

if ! command -v "$VIVADO_CMD" &>/dev/null; then
    echo "ERROR: '$VIVADO_CMD' no encontrado en PATH ni en '$VIVADO_BIN'." >&2
    echo "  Verifica que VIVADO_BIN apunte al directorio bin de tu instalacion." >&2
    exit 1
fi

if [ ! -d "$HDL_DIR" ]; then
    echo "ERROR: Directorio '$HDL_DIR/' no encontrado." >&2
    echo "  Ejecuta primero: bash setup.sh" >&2
    exit 1
fi

V_FILES=("$HDL_DIR"/*.v)
if [ ! -e "${V_FILES[0]}" ]; then
    echo "ERROR: No hay archivos .v en '$HDL_DIR/'." >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Crear directorio de reportes
# -----------------------------------------------------------------------------
mkdir -p "$REPORTS_DIR"

# -----------------------------------------------------------------------------
# Sintetizar cada archivo .v
# -----------------------------------------------------------------------------
total=${#V_FILES[@]}
current=0

for vfile in "${V_FILES[@]}"; do
    current=$((current + 1))
    module=$(basename "$vfile" .v)          # Nombre del modulo = nombre del archivo sin .v
    report="$REPORTS_DIR/${module}.log"     # Reporte de salida

    echo "[$current/$total] Sintetizando: $module..."

    # Generar script TCL para este diseno
    cat > "$TCL_TMP" <<EOF
# Sintesis en modo no-proyecto para: $module
read_verilog $vfile
synth_design -top $module -part $PART
report_utilization -file $report
EOF

    # Ejecutar Vivado en modo batch
    #   -mode batch  : sin interfaz grafica
    #   -source      : archivo TCL a ejecutar
    #   -log         : log interno de Vivado (se guarda separado para no pisar el reporte)
    #   -journal     : archivo .jou de Vivado
    "$VIVADO_CMD" -mode batch \
           -source "$TCL_TMP" \
           -log    "$REPORTS_DIR/${module}_vivado.log" \
           -journal "$REPORTS_DIR/${module}.jou" \
        && echo "  -> $report" \
        || echo "  ADVERTENCIA: fallo la sintesis de $module"

done

# -----------------------------------------------------------------------------
# Limpieza
# -----------------------------------------------------------------------------
rm -f "$TCL_TMP"

echo ""
echo "Listo. Reportes generados en '$REPORTS_DIR/':"
ls "$REPORTS_DIR/"*.log 2>/dev/null | grep -v "_vivado.log" | while read -r f; do
    echo "  - $(basename "$f")"
done
