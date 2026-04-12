#!/usr/bin/env bash
# =============================================================================
# parse_reports.sh — Actividad 3
# Lee los reportes .log generados por synthesize.sh en reports/ y crea un
# archivo results.csv con las columnas:
#   design,slice_luts,slice_registers
#
# Uso: bash parse_reports.sh
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuracion
# -----------------------------------------------------------------------------
REPORTS_DIR="reports"
OUTPUT_CSV="results.csv"

# -----------------------------------------------------------------------------
# Verificaciones previas
# -----------------------------------------------------------------------------
if [ ! -d "$REPORTS_DIR" ]; then
    echo "ERROR: Directorio '$REPORTS_DIR/' no encontrado." >&2
    echo "  Ejecuta primero: bash synthesize.sh" >&2
    exit 1
fi

LOG_FILES=("$REPORTS_DIR"/*.log)

if [ ! -e "${LOG_FILES[0]}" ]; then
    echo "ERROR: No se encontraron archivos .log en '$REPORTS_DIR/'." >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Crear encabezado del CSV
# -----------------------------------------------------------------------------
echo "design,slice_luts,slice_registers" > "$OUTPUT_CSV"

# -----------------------------------------------------------------------------
# Procesar cada reporte
# -----------------------------------------------------------------------------
for logfile in "${LOG_FILES[@]}"; do
    filename="$(basename "$logfile")"

    # Saltar logs internos de Vivado tipo *_vivado.log
    if [[ "$filename" == *_vivado.log ]]; then
        continue
    fi

    design="${filename%.log}"

    # -------------------------------------------------------------------------
    # Extraer Slice LUTs
    # Busca la fila que contiene "Slice LUTs" y toma la primera cifra encontrada
    # -------------------------------------------------------------------------
    luts="$(grep -m1 "Slice LUTs" "$logfile" | grep -oE '[0-9,]+' | head -n1 | tr -d ',')"

    # -------------------------------------------------------------------------
    # Extraer Slice Registers
    # Busca la fila que contiene "Slice Registers" y toma la primera cifra encontrada
    # -------------------------------------------------------------------------
    regs="$(grep -m1 "Slice Registers" "$logfile" | grep -oE '[0-9,]+' | head -n1 | tr -d ',')"

    # Si no se encontro algun dato, poner NA para no romper el CSV
    luts="${luts:-NA}"
    regs="${regs:-NA}"

    echo "$design,$luts,$regs" >> "$OUTPUT_CSV"
    echo "Procesado: $design -> LUTs=$luts, Registers=$regs"
done

echo ""
echo "Listo. Archivo generado: '$OUTPUT_CSV'"
