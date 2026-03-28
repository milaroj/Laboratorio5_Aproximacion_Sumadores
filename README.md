# Laboratorio 5 — Síntesis de Sumadores Aproximados

**Semana #6: 25/Marzo/2026**
**Taller de Diseño Digital — EL3313: I Semestre 2026**
**Profesor: Luis G. León-Vega, Ph.D**

---

## Integrantes

| Nombre | Carné |
|---|---|
| Angie Hernández Mairena | 2021093932 |
| Brayan Solís Rojas | 2020168427 |
| Milagro Rojas Sánchez | 2020412342 |

---

## Descripción

Este proyecto automatiza la síntesis de sumadores aproximados de 8 bits de la librería
[EvoApproxLib](https://github.com/ehw-fit/evoapproxlib) sobre una FPGA Nexys A7
(`xc7a100tcsg324-1`), y recolecta métricas de utilización de recursos.

## Repositorio

[https://github.com/milaroj/Laboratorio5_Aproximacion_Sumadores](https://github.com/milaroj/Laboratorio5_Aproximacion_Sumadores)

---

## Scripts

| Script | Actividad | Descripción |
|---|---|---|
| `setup.sh` | 1 | Descarga los `.v` del repo EvoApproxLib a `hdl/` |
| `synthesize.sh` | 2 | Sintetiza cada `.v` en Vivado y genera reportes `.log` |
| `parse_reports.sh` | 3 | Parsea los `.log` y genera `results.csv` |
| `run_all.sh` | 4 | Invoca los tres scripts anteriores en orden |

## Uso

```bash
bash run_all.sh
```

O paso a paso:

```bash
bash setup.sh        # Descarga los sumadores
bash synthesize.sh   # Sintetiza y genera reportes
bash parse_reports.sh # Genera results.csv
```

---

## Resultados

Los resultados de síntesis se encuentran en `results.csv` con las columnas:
- `design`: nombre del archivo `.v`
- `slice_luts`: LUTs utilizados
- `slice_registers`: Registros utilizados
