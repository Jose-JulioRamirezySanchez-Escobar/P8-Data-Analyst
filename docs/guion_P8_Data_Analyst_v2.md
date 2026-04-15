# Guión de Proyecto — P8-Data-Analyst
**Bootcamp IA P4 · Factoría F5 Madrid**
**Repositorio:** https://github.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst
**Fuentes:** RúbricaEvaluación + ResumenObjetivos
**Enfoque:** Gradual — Fase 0 → Esencial → Medio → Avanzado → Experto
**Estado:** Propuesta para revisión y aprobación del equipo

---

## Contexto del proyecto

Somos el departamento de datos de una StartUp del sector inmobiliario. AirBnB nos ha cedido datos de varias ciudades para que extraigamos todo el valor posible. El proyecto funciona como prueba de capacidad de cara a futuros contratos.

- **Nombre del proyecto:** `P8-Data-Analyst`
- **Equipo:** 4 o más personas
- **Lenguaje principal:** Python 3.13
- **Gestor de paquetes:** uv

---

## ⚙️ Entorno de desarrollo

### Versión de Python: 3.13 ✅

**¿Por qué 3.13?**
Es la versión instalada en la máquina de desarrollo (`uv` la detectó automáticamente al hacer `uv init`). Es la versión estable más reciente con soporte activo, mejoras de rendimiento respecto a 3.12, mensajes de error más claros, y compatibilidad total con todo el stack del proyecto. No hay razón para bajar a 3.12.

---

### Instalación del entorno con uv

#### 1. Instalar uv (una sola vez por máquina)

```bash
# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Linux / macOS / Git Bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### 2. Inicializar el proyecto (ya hecho)

```bash
cd ~/Proyectos/P8-Data-Analyst
uv init        # genera pyproject.toml, .python-version, uv.lock
```

#### 3. Instalar todas las librerías del proyecto

```bash
uv add pandas numpy matplotlib seaborn plotly scikit-learn \
       streamlit openpyxl jupyterlab nbconvert scipy \
       xgboost lightgbm ipywidgets
```

- `pandas` → manipulación de datos tabulares
- `numpy` → operaciones numéricas
- `matplotlib` / `seaborn` / `plotly` → visualización
- `scikit-learn` → preprocesado y modelos ML
- `openpyxl` → lectura de archivos `.xlsx`
- `jupyterlab` → entorno notebook en el navegador
- `nbconvert` → exportar notebooks a PDF/HTML
- `scipy` → tests estadísticos (fase avanzada)
- `xgboost` / `lightgbm` → modelos ensemble (fase experto)
- `ipywidgets` → widgets interactivos en notebooks

El archivo `uv.lock` **debe subirse al repositorio** para garantizar reproducibilidad.

---

### Activar el entorno virtual `.venv`

uv crea `.venv` automáticamente. Para activarlo manualmente:

```bash
# Git Bash (Windows)
source .venv/Scripts/activate

# PowerShell (Windows)
.venv\Scripts\Activate.ps1

# CMD (Windows)
.venv\Scripts\activate.bat

# Linux / macOS
source .venv/bin/activate
```

Verificar que está activo:
```bash
which python        # debe apuntar a .venv/Scripts/python
python --version    # debe mostrar Python 3.13.x
```

Desactivar:
```bash
deactivate
```

> Con `uv run <comando>` no es necesario activar el entorno — uv lo gestiona de forma transparente.

---

### Levantar Jupyter Lab sin bloquear la terminal (Git Bash, Windows 11)

```bash
# Lanzar en background con log con timestamp
LOG="jupyter_lab_$(date +%Y%m%d_%H%M%S).log"
uv run jupyter lab > "$LOG" 2>&1 &
echo "Jupyter Lab iniciado | PID: $! | Log: $LOG"
```

Para abrir directamente un notebook concreto:
```bash
LOG="jupyter_lab_$(date +%Y%m%d_%H%M%S).log"
uv run jupyter lab notebooks/01_eda_airbnb.ipynb > "$LOG" 2>&1 &
echo "Jupyter Lab iniciado | PID: $! | Log: $LOG"
```

Ver el log en tiempo real:
```bash
tail -f jupyter_lab_*.log
```

Detener Jupyter Lab:
```bash
kill %1          # mata el primer proceso en background
# o
jobs             # listar procesos en background
kill %N          # donde N es el número del job
```

---

### Exportar notebook a PDF

```bash
# Opción 1: via webpdf (requiere Chromium)
uv add "nbconvert[webpdf]"
uv run playwright install chromium
uv run jupyter nbconvert --to webpdf notebooks/01_eda_airbnb.ipynb

# Opción 2: HTML (más sencillo, sin dependencias extra)
uv run jupyter nbconvert --to html notebooks/01_eda_airbnb.ipynb
```

---

## Estructura de carpetas

```
P8-Data-Analyst/
├── data/
│   ├── raw/              ← datos originales (nunca modificar)
│   └── processed/        ← datos limpios para análisis
├── notebooks/
│   ├── 00_fase0_fuentes.ipynb
│   └── 01_eda_airbnb.ipynb
├── src/                  ← funciones reutilizables
├── dashboard/            ← app Streamlit
├── docs/
├── .gitignore
├── .python-version
├── pyproject.toml
├── uv.lock
└── README.md
```

**.gitignore mínimo:**
```
.venv/
__pycache__/
*.pyc
*.log
credentials.json
token.json
client_secret*.json
.ipynb_checkpoints/
data/processed/
```

---

## FASE 0 — Selección y preparación de fuentes de datos

> **[SDD — Spec-Driven Development]**
> Esta fase debe producir un documento de decisión aprobado por el equipo antes de escribir código de análisis. Criterios: versión más reciente por ciudad, formato preferido, columnas disponibles.

### Datasets disponibles y selección

| Ciudad | Archivo seleccionado | URL raw | Motivo |
|---|---|---|---|
| Madrid | `madrid_airbnb.xlsx` | [enlace](https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/madrid_airbnb.xlsx) | Más reciente (2026-01) |
| Londres | `london_airbnb.xlsx` | [enlace](https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/london_airbnb.xlsx) | Más reciente (2024-10-24) |
| Milán | `milan_airbnb.xlsx` | [enlace](https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/milan_airbnb.xlsx) | Más reciente (2024-10-08) |
| Sydney | `sydney_airbnb.csv` | [enlace](https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/sydney_airbnb.csv) | Única versión disponible |
| Nueva York | `NY_airbnb.csv` | [enlace](https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/NY_airbnb.csv) | Única versión disponible |
| Tokio | `tokyo_airbnb.csv` | [enlace](https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/tokyo_airbnb.csv) | Única versión disponible |

### Columnas confirmadas por dataset (CSV)

| Columna | NY | Madrid | Sydney | London | Milan | Tokyo |
|---|---|---|---|---|---|---|
| id | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| name | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| host_id | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| host_name | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| neighbourhood_group | ✅ | ✅ | ✅ (vacío) | ✅ (vacío) | ❌ | ✅ (vacío) |
| neighbourhood | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| latitude | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| longitude | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| room_type | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| price | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| minimum_nights | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| number_of_reviews | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| last_review | ✅ | ✅ | ✅ | ✅ | ✅ (formato DD/MM/YY) | ✅ |
| reviews_per_month | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| calculated_host_listings_count | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| availability_365 | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

**Observaciones importantes:**
- **Tokio** no tiene `calculated_host_listings_count` ni `availability_365`
- **Milán** no tiene `neighbourhood_group` y el formato de fecha en `last_review` es `DD/MM/YY`
- **Sydney y Londres** tienen `neighbourhood_group` vacío (sin valor)
- Los precios están en **moneda local** de cada ciudad — no son comparables directamente sin conversión

---

## 🟢 NIVEL ESENCIAL

### FASE 1 — Configuración del entorno y gestión del proyecto

> **[SDD]** Antes de tocar los datos, el equipo debe tener el entorno técnico y organizativo listo.

#### 1.1 Control de versiones — Git / GitHub

```bash
# Estructura de ramas (Gitflow)
git checkout -b develop            # rama de integración
git checkout -b feature/eda-tokyo  # feature por cada sección
```

Nomenclatura de commits:
```
feat: añadir EDA de precios por ciudad
fix: corregir encoding en milan_airbnb.csv
docs: actualizar README con instrucciones de ejecución
chore: añadir librerías scipy y xgboost
```

Nomenclatura de ramas:
```
feature/fase0-seleccion-datos
feature/eda-estadistica-descriptiva
feature/eda-visualizacion
feature/limpieza-preprocesado
feature/dashboard-looker
```

#### 1.2 Gestión del equipo — Kanban

Herramienta recomendada: **Trello** (gratuito) o **GitHub Projects**

Columnas mínimas: `Backlog | En progreso | En revisión | Hecho`

Roles sugeridos (equipo de 4+):
- Responsable de datos / EDA
- Responsable de visualización / dashboard
- Responsable de infraestructura (Git, Docker)
- Responsable de presentación y documentación

Ceremonias:
- **Daily** (~15 min): ¿qué hice? ¿qué hago? ¿hay bloqueos?
- **Actas de reunión**: documento compartido (Google Docs o Markdown en repo)
- **Estimación**: horas o puntos de historia por tarea antes de iniciar
- **Retrospectiva**: al final de cada fase

---

### FASE 2 — Carga y EDA inicial

> **[SDD]** El notebook `01_eda_airbnb.ipynb` implementa esta fase. Ver plantilla adjunta.

#### 2.1 Carga de datos

```python
import pandas as pd

# CSV
df_ny = pd.read_csv("data/raw/NY_airbnb.csv")
df_madrid = pd.read_csv("data/raw/madrid_airbnb.csv")
df_tokyo = pd.read_csv("data/raw/tokyo_airbnb.csv")
df_sydney = pd.read_csv("data/raw/sydney_airbnb.csv")
df_london = pd.read_csv("data/raw/london_airbnb.csv")
df_milan = pd.read_csv("data/raw/milan_airbnb.csv")

# XLSX (versiones más recientes)
df_madrid_v2 = pd.read_excel("data/raw/madrid_airbnb.xlsx", engine="openpyxl")
df_london_v2 = pd.read_excel("data/raw/london_airbnb.xlsx", engine="openpyxl")
df_milan_v2  = pd.read_excel("data/raw/milan_airbnb.xlsx",  engine="openpyxl")

# Añadir columna ciudad para poder combinar datasets
df_ny["city"]     = "New York"
df_madrid["city"] = "Madrid"
df_tokyo["city"]  = "Tokyo"
df_sydney["city"] = "Sydney"
df_london["city"] = "London"
df_milan["city"]  = "Milan"

# Dataset combinado (solo columnas comunes)
COLS_COMUNES = [
    "id", "name", "host_id", "host_name", "neighbourhood",
    "latitude", "longitude", "room_type", "price",
    "minimum_nights", "number_of_reviews", "last_review",
    "reviews_per_month", "city"
]
df_all = pd.concat(
    [df[COLS_COMUNES] for df in [df_ny, df_madrid, df_tokyo, df_sydney, df_london, df_milan]],
    ignore_index=True
)
```

#### 2.2 EDA — Estadística descriptiva

```python
df_all.describe()       # media, mediana, desviación estándar, percentiles
df_all.info()           # tipos de datos y conteo de nulos
df_all["room_type"].value_counts()      # frecuencias categóricas
df_all["city"].value_counts()
```

#### 2.3 Visualizaciones clave

```python
import seaborn as sns
import matplotlib.pyplot as plt

# Distribución de precios por ciudad
sns.histplot(data=df_all[df_all["price"] < 500], x="price", hue="city", bins=50)

# Boxplot de precio por tipo de alojamiento
sns.boxplot(data=df_all[df_all["price"] < 500], x="room_type", y="price")

# Barras de tipo de alojamiento
sns.countplot(data=df_all, x="room_type", order=df_all["room_type"].value_counts().index)
```

---

### FASE 3 — Limpieza y preprocesado

> **[SDD]** Toda decisión de limpieza debe documentarse en celda Markdown del notebook con justificación explícita.

```python
from sklearn.preprocessing import MinMaxScaler, LabelEncoder
import numpy as np

# Nulos
df_all["reviews_per_month"].fillna(0, inplace=True)
df_all["last_review"] = pd.to_datetime(df_all["last_review"], errors="coerce")

# Outliers de precio con IQR
Q1 = df_all["price"].quantile(0.25)
Q3 = df_all["price"].quantile(0.75)
IQR = Q3 - Q1
df_clean = df_all[df_all["price"].between(Q1 - 1.5*IQR, Q3 + 1.5*IQR)]

# Encoding
le = LabelEncoder()
df_clean["room_type_encoded"] = le.fit_transform(df_clean["room_type"])

# Escalado
scaler = MinMaxScaler()
df_clean[["price_scaled", "reviews_scaled"]] = scaler.fit_transform(
    df_clean[["price", "number_of_reviews"]]
)
```

---

## 🟡 NIVEL MEDIO

### FASE 4 — Visualizaciones avanzadas

> **[SDD]** Usar Plotly para gráficos interactivos. Seaborn para análisis estático de alta calidad.

```python
import plotly.express as px

# Mapa geográfico de alojamientos
fig = px.scatter_mapbox(
    df_clean, lat="latitude", lon="longitude",
    color="city", size="price", hover_name="name",
    mapbox_style="open-street-map", zoom=2
)
fig.show()

# Pairplot de variables numéricas
sns.pairplot(df_clean[["price", "minimum_nights", "number_of_reviews", "city"]], hue="city")

# Heatmap de correlaciones
sns.heatmap(df_clean[["price", "minimum_nights", "number_of_reviews", "reviews_per_month"]].corr(),
            annot=True, cmap="coolwarm")
```

### FASE 5 — Dashboard en Looker Studio

**Herramienta: Looker Studio** (gratuito, navegador, Google Workspace)

Proceso:
1. Exportar dataset limpio → Google Sheets: `df_clean.to_csv("data/processed/airbnb_clean.csv")`
2. Subir a Google Drive → conectar en Looker Studio
3. Diseñar con: KPIs de precio medio, mapa, barras por ciudad, filtros por room_type

---

## 🟠 NIVEL AVANZADO

### FASE 6 — Filtros interactivos — Streamlit

> **[SDD]** Crear `dashboard/app.py` con Streamlit. Debe poder ejecutarse con `uv run streamlit run dashboard/app.py`.

```python
# dashboard/app.py
import streamlit as st
import pandas as pd
import plotly.express as px

df = pd.read_csv("data/processed/airbnb_clean.csv")

ciudad = st.multiselect("Ciudad", df["city"].unique(), default=df["city"].unique())
precio_max = st.slider("Precio máximo", 0, int(df["price"].max()), 300)

df_filtered = df[(df["city"].isin(ciudad)) & (df["price"] <= precio_max)]
fig = px.scatter_mapbox(df_filtered, lat="latitude", lon="longitude",
                        color="city", mapbox_style="open-street-map", zoom=3)
st.plotly_chart(fig)
```

### FASE 7 — Docker

```dockerfile
# Dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN pip install uv && uv sync
COPY . .
EXPOSE 8501
CMD ["uv", "run", "streamlit", "run", "dashboard/app.py", "--server.port=8501"]
```

```bash
docker build -t p8-data-analyst .
docker run -p 8501:8501 p8-data-analyst
```

### FASE 8 — Hipótesis estadísticas

> **[SDD]** Cada hipótesis debe formularse antes de ejecutar el test. Documentar H0, H1, resultado y conclusión en Markdown.

```python
from scipy import stats

# H0: El precio medio en Madrid = precio medio en Londres
# H1: Son significativamente distintos
madrid_prices = df_clean[df_clean["city"] == "Madrid"]["price"]
london_prices = df_clean[df_clean["city"] == "London"]["price"]

t_stat, p_value = stats.ttest_ind(madrid_prices, london_prices)
print(f"t={t_stat:.3f}, p={p_value:.4f}")
# p < 0.05 → rechazar H0 → diferencia significativa
```

---

## 🔴 NIVEL EXPERTO

### FASE 9 — Machine Learning y Clustering

> **[SDD]** Definir variable objetivo antes de seleccionar el modelo. Documentar métrica de evaluación elegida y justificación.

```python
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

features = ["price_scaled", "reviews_scaled", "minimum_nights"]
X = df_clean[features].dropna()

# K-Means
kmeans = KMeans(n_clusters=4, random_state=42)
df_clean["cluster"] = kmeans.fit_predict(X)

# Visualización PCA
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X)
px.scatter(x=X_pca[:,0], y=X_pca[:,1], color=df_clean["cluster"].astype(str))
```

### FASE 10 — Datos externos

Fuentes recomendadas (gratuitas):
- **INE:** datos demográficos Madrid → [ine.es](https://www.ine.es)
- **datos.gob.es:** portal datos abiertos España
- **Eurostat:** comparativas europeas (Madrid, Londres, Milán)
- **OpenStreetMap/Nominatim:** distancia al centro de cada ciudad

### FASE 11 — Despliegue público

| Plataforma | Coste | Notas |
|---|---|---|
| **Streamlit Community Cloud** | Gratuito | Deploy desde GitHub en minutos |
| **Render** | Gratuito (básico) | Soporta Docker |
| **Azure Free Tier** | Gratuito 12 meses | Cubre criterio cloud de la rúbrica |

```bash
# Streamlit Community Cloud
# 1. Push del código a GitHub (ya hecho)
# 2. Ir a share.streamlit.io
# 3. Conectar repo → seleccionar dashboard/app.py → Deploy
```

---

## 📋 Resumen de entregables

| Nivel | Entregable | Herramientas |
|---|---|---|
| 🟢 Esencial | Notebook EDA + GitHub + Kanban + README | Python, Pandas, Seaborn, Git, Trello |
| 🟡 Medio | Dashboard + visualizaciones avanzadas | Looker Studio, Plotly |
| 🟠 Avanzado | App interactiva + Docker + hipótesis | Streamlit, Docker, Scipy |
| 🔴 Experto | ML/clustering + datos externos + deploy | Sklearn, KMeans, Streamlit Cloud |

---

## 📌 Observaciones para la propuesta al equipo

1. El **nivel esencial no es negociable** — base de todo lo demás
2. Los precios están en **moneda local** — no comparar directamente sin conversión o normalización
3. **Tokio** tiene menos columnas que el resto — tratar aparte o con columnas condicionales
4. **Milán CSV** tiene formato de fecha distinto (`DD/MM/YY`) — parsear con `dayfirst=True` o `errors='coerce'`
5. **Looker Studio** es la opción más pragmática para el dashboard (gratuito, navegador, sin instalación)
6. **K-Means** es la entrada más accesible al nivel experto dado el contexto del dataset

---

*Documento generado como propuesta de trabajo. Pendiente de revisión y aprobación del equipo.*
