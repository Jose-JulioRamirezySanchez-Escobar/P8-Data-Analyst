# P8-Data-Analyst
**Bootcamp IA P4 · Factoría F5 Madrid**  
**Proyecto:** Análisis y visualización de datos AirBnB (6 ciudades)  
**Repositorio:** https://github.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst

---

## Descripción

Análisis exploratorio de datos de alojamientos AirBnB en Madrid, Londres, Milán, Nueva York, Sydney y Tokio. El proyecto abarca desde la homogenización de datos crudos hasta la visualización avanzada, con cobertura de los niveles Esencial, Medio, Avanzado y Experto de la rúbrica de evaluación.

---

## Requisitos previos

- **Sistema operativo:** Windows 11 (probado con Git Bash) / Linux / macOS
- **Git:** instalado y configurado
- **Python:** no es necesario instalarlo manualmente — `uv` lo gestiona
- **uv:** gestor de paquetes (ver instalación abajo)

---

## Instalación paso a paso

### 1. Clonar el repositorio

```bash
cd ~/Proyectos
git clone https://github.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst.git
cd P8-Data-Analyst
```

### 2. Instalar uv

`uv` es el gestor de entornos y paquetes del proyecto. Sustituye a `pip` + `venv` con mayor velocidad y reproducibilidad.

```bash
# Windows (PowerShell — ejecutar una vez)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Linux / macOS / Git Bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Verificar instalación:
```bash
uv --version
# uv 0.x.x
```

### 3. Inicializar el proyecto

```bash
# Desde la raíz del repositorio
uv init          # crea pyproject.toml y .python-version (si no existen)
uv python pin 3.13   # fijar Python 3.13
```

### 4. Instalar todas las dependencias

```bash
uv add pandas numpy matplotlib seaborn plotly scikit-learn \
       openpyxl jupyterlab nbconvert scipy statsmodels \
       xgboost lightgbm ipywidgets requests pykakasi
```

El archivo `uv.lock` garantiza que todos los miembros del equipo usen exactamente las mismas versiones.

| Librería | Uso |
|---|---|
| `pandas` | Manipulación de datos tabulares |
| `numpy` | Operaciones numéricas |
| `matplotlib` / `seaborn` | Visualización estática |
| `plotly` | Visualización interactiva |
| `scikit-learn` | Preprocesado y modelos ML |
| `openpyxl` | Lectura de archivos `.xlsx` |
| `jupyterlab` | Entorno notebook en el navegador |
| `nbconvert` | Exportar notebooks a PDF/HTML |
| `scipy` | Tests estadísticos |
| `statsmodels` | Líneas de tendencia OLS en Plotly |
| `xgboost` / `lightgbm` | Modelos ensemble (fase experto) |
| `ipywidgets` | Widgets interactivos en notebooks |
| `requests` | Carga de datos desde URLs |
| `pykakasi` | Transliteración japonés → romaji |

### 5. Activar el entorno virtual

`uv` crea el `.venv` automáticamente. Para activarlo manualmente:

```bash
# Git Bash (Windows)
source .venv/Scripts/activate

# PowerShell (Windows)
.venv\Scripts\Activate.ps1

# Linux / macOS
source .venv/bin/activate
```

Verificar:
```bash
which python        # debe mostrar la ruta al .venv
python --version    # debe mostrar Python 3.13.x
```

Desactivar:
```bash
deactivate
```

> Con `uv run <comando>` no es necesario activar el entorno manualmente.

---

## Estructura del proyecto

```
P8-Data-Analyst/
├── data/
│   ├── raw/                    ← datasets originales (no modificar)
│   │   ├── NY_airbnb.csv
│   │   ├── madrid_airbnb.csv
│   │   ├── london_airbnb.csv
│   │   ├── milan_airbnb.csv
│   │   ├── sydney_airbnb.csv
│   │   ├── tokyo_airbnb.csv
│   │   └── *.xlsx              ← versiones más recientes
│   └── processed/              ← generado por los notebooks
│       ├── airbnb_homogenizado.csv
│       └── homogenizacion_metadata.txt
├── notebooks/
│   ├── 00_homogenizacion.ipynb ← EJECUTAR PRIMERO
│   └── 01_eda.ipynb            ← EJECUTAR SEGUNDO
├── dashboard/                  ← app Streamlit (nivel avanzado)
├── docs/                       ← documentación del proyecto
├── kanban/                     ← snapshots del tablero Kanban
├── .gitignore
├── .python-version
├── pyproject.toml
├── uv.lock
└── README.md
```

---

## Ejecución de los notebooks

### Opción A — Jupyter Lab en el navegador (recomendada)

```bash
# Lanzar Jupyter Lab (terminal queda libre)
LOG="jupyter_lab_$(date +%Y%m%d_%H%M%S).log"
uv run jupyter lab > "$LOG" 2>&1 &
echo "Jupyter Lab iniciado | PID: $! | Log: $LOG"
```

Se abrirá automáticamente en `http://localhost:8888/lab`.  
Si no se abre, copia la URL del log:
```bash
tail -f jupyter_lab_*.log
# buscar la línea: http://localhost:8888/lab?token=...
```

### Opción B — VSCode

1. Abre VSCode en la carpeta del proyecto: `code .`
2. Instala la extensión **Jupyter** (Microsoft)
3. Abre el notebook → haz clic en **Select Kernel** → selecciona `p8-data-analyst (3.13.x)`
4. `Run All Cells` o `Ctrl+Alt+R`

### Orden de ejecución

**Paso 1:** `notebooks/00_homogenizacion.ipynb`
- Descarga los 6 CSV desde GitHub
- Aplica todas las transformaciones de limpieza
- Genera `data/processed/airbnb_homogenizado.csv`
- Tiempo estimado: 3-8 minutos (descarga + procesado)

**Paso 2:** `notebooks/01_eda.ipynb`
- Carga `airbnb_homogenizado.csv`
- Genera todos los análisis y visualizaciones
- Tiempo estimado: 2-5 minutos

### Detener Jupyter Lab

```bash
kill %1          # primer proceso en background
# o
jobs             # listar procesos
kill %N          # donde N es el número del job
```

---

## Exportar notebooks a PDF

```bash
# HTML (sin dependencias extra)
uv run jupyter nbconvert --to html notebooks/00_homogenizacion.ipynb
uv run jupyter nbconvert --to html notebooks/01_eda.ipynb

# PDF via webpdf (requiere Chromium)
uv add "nbconvert[webpdf]"
uv run playwright install chromium
uv run jupyter nbconvert --to webpdf notebooks/01_eda.ipynb
```

---

## Datos

Los datasets se cargan directamente desde el repositorio de GitHub en tiempo de ejecución. No es necesario descargarlos manualmente.

| Dataset | Ciudad | Moneda | Registros crudos |
|---|---|---|---|
| `NY_airbnb.csv` | Nueva York | USD | 48.895 |
| `london_airbnb.csv` | Londres | GBP | 85.068 |
| `sydney_airbnb.csv` | Sydney | AUD | 36.662 |
| `madrid_airbnb.csv` | Madrid | EUR | 19.618 |
| `milan_airbnb.csv` | Milán | EUR | 18.322 |
| `tokyo_airbnb.csv` | Tokio | JPY | 11.466 |

Fuente original: [Google Drive — primer_proyecto_datos](https://drive.google.com/drive/folders/17sYr63LjEX30-3-KjXIaPP-bRwEmMqpf)

---

## Contribución (flujo de trabajo en equipo)

```bash
# 1. Crear rama personal
git checkout -b feature/nombre-de-la-tarea

# 2. Trabajar y commitear
git add archivos_modificados
git commit -m "feat: descripción del cambio"

# 3. Subir rama
git push origin feature/nombre-de-la-tarea

# 4. Abrir Pull Request en GitHub hacia develop
```

Convenciones de commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`

---

## Tecnologías

Python 3.13 · uv · Jupyter Lab · Pandas · Seaborn · Plotly · Scikit-learn · Streamlit

---

*Bootcamp IA P4 · Factoría F5 Madrid · 2025-2026*
