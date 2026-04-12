#run_all.sh

set -euo pipefail #Tratamiento de errores(comandos, variables y pipes)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (reset)

log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    case "$level" in
        INFO)  echo -e "${CYAN}[${timestamp}] [INFO]  ${message}${NC}" ;;
        WARN)  echo -e "${YELLOW}[${timestamp}] [WARN]  ${message}${NC}" ;;
        ERROR) echo -e "${RED}[${timestamp}] [ERROR] ${message}${NC}" ;;
        OK)    echo -e "${GREEN}[${timestamp}] [OK]    ${message}${NC}" ;;
        *)     echo "[${timestamp}] ${message}" ;;
    esac
}

run_script() {
    local script="$1"
    local script_path

    script_path="$(dirname "$0")/${script}"

    if [[ ! -f "$script_path" ]]; then
        log ERROR "No se encontró el script: ${script_path}"
        exit 1
    fi

    if [[ ! -x "$script_path" ]]; then
        log WARN "${script} no tiene permisos de ejecución. Aplicando chmod +x..."
        chmod +x "$script_path"
    fi

    log INFO "Ejecutando: ${script} ..."
    bash "$script_path"

    log OK "${script} finalizó exitosamente."
}

log INFO "============================================================"
log INFO " Iniciando flujo completo - Laboratorio 5"
log INFO "============================================================"

# Paso 1: Configuración del entorno y descarga del repositorio
log INFO "--- Paso 1/3: Setup del proyecto ---"
run_script "setup.sh"

# Paso 2: Síntesis de los archivos .v con Vivado
log INFO "--- Paso 2/3: Síntesis de sumadores aproximados ---"
run_script "synthesize.sh"

# Paso 3: Parseo de reportes y generación del CSV con métricas
log INFO "--- Paso 3/3: Extracción de métricas y generación de CSV ---"
run_script "parse_reports.sh"

log INFO "============================================================"
log OK " Flujo completo finalizado sin errores."
log INFO "============================================================"