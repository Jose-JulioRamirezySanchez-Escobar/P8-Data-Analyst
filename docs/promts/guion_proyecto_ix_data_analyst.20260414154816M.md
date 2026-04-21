# Guión de Proyecto — Proyecto IX: Data Analyst
**Bootcamp IA P4 · Factoría F5 Madrid**  
**Fuentes:** RúbricaEvaluación + ResumenObjetivos  
**Enfoque:** Gradual — Esencial → Medio → Avanzado → Experto  
**Estado:** Propuesta para revisión y aprobación del equipo  

---

## Contexto del proyecto

Somos el departamento de datos de una StartUp del sector inmobiliario. AirBnB nos ha cedido datos de varias ciudades para que extraigamos todo el valor posible. El proyecto funciona como prueba de capacidad de cara a futuros contratos. Cuanto más valor encontremos (patrones, outliers, hipótesis, insights de negocio), mejor.

- **Dataset:** AirBnB ciudades — formato `.csv`
- **Equipo:** 4 o más personas
- **Lenguaje principal:** Python
- **Entrega:** Repositorio GitHub + Notebook + Dashboard + Presentación técnica + Demo en vivo + Kanban

---

## 🟢 NIVEL ESENCIAL — Base del proyecto
> Este nivel es obligatorio y debe quedar perfectamente ejecutado antes de avanzar.

---

### FASE 1 — Configuración del entorno y gestión del proyecto

**Objetivo:** Tener el equipo organizado y el entorno técnico listo antes de tocar los datos.

#### 1.1 Control de versiones — Git / GitHub
- Crear repositorio remoto en **GitHub**
- Conectar repositorio local al remoto: `git remote add origin <url>`
- Definir estructura de ramas siguiendo **Gitflow**:
  - `main` → código estable / entregable
  - `develop` → integración continua del equipo
  - `feature/<nombre>` → cada funcionalidad o sección del análisis
  - `hotfix/<nombre>` → correcciones urgentes
- Nomenclatura de commits (ejemplo): `feat: añadir limpieza de nulos en precio`, `docs: actualizar README`
- Abrir **Issues en GitHub** para cada tarea asignable
- Nomenclatura de ramas (ejemplo): `feature/eda-precios`, `feature/dashboard-looker`

#### 1.2 Gestión del equipo — Kanban
- Herramienta recomendada: **Trello** (gratuito, visual, colaborativo) o **GitHub Projects** (integrado con Issues)
- Columnas mínimas del tablero: `Backlog | En progreso | En revisión | Hecho`
- Definir **roles** dentro del equipo (ejemplos):
  - Responsable de datos / EDA
  - Responsable de visualización / dashboard
  - Responsable de infraestructura / Git
  - Responsable de presentación y documentación
- Realizar **Dailies** (reuniones diarias breves ~15 min): ¿qué hice ayer? ¿qué hago hoy? ¿hay bloqueos?
- Levantar **actas de reunión** (documento compartido, Google Docs o Markdown en el repo)
- Hacer **estimación de tareas** (horas o puntos de historia) antes de iniciar cada sprint
- Hacer **retrospectiva** al final de cada fase: ¿qué fue bien? ¿qué mejorar?
- **Burndown chart**: representación del trabajo restante vs. tiempo (Trello Power-Up o manual)

#### 1.3 Documentación
- Crear `README.md` en la raíz del repositorio con:
  - Descripción del proyecto
  - Tecnologías usadas
  - Instrucciones de instalación y ejecución
  - Estructura de carpetas
- Usar **celdas Markdown** en el notebook para documentar cada paso del análisis

---

### FASE 2 — Carga y exploración inicial de los datos

**Objetivo:** Conocer el dataset antes de transformarlo.

#### 2.1 Carga del CSV
- Librería: **Pandas** → `pd.read_csv()`
- Revisar encoding si hay caracteres especiales: `encoding='utf-8'` o `'latin-1'`
- Comprobar estructura: `df.shape`, `df.columns`, `df.dtypes`, `df.head()`

#### 2.2 Análisis Exploratorio de Datos (EDA)
El EDA es el núcleo del nivel esencial. Debe ser detallado y bien documentado.

**Estadística descriptiva:**
- `df.describe()` → media, mediana, desviación estándar, percentiles
- `df.info()` → tipos de datos y nulos
- `df.value_counts()` → frecuencias en variables categóricas

**Distribución de variables:**
- Histogramas: `matplotlib` / `seaborn.histplot()`
- Boxplots para ver dispersión y outliers: `seaborn.boxplot()`
- Gráficos de barras para variables categóricas: `seaborn.countplot()`

**Detección de outliers:**
- Método IQR (rango intercuartílico): valores fuera de `[Q1 - 1.5*IQR, Q3 + 1.5*IQR]`
- Visualización con boxplot
- Decisión documentada: ¿eliminar, imputar o mantener con justificación?

**Correlaciones:**
- Matriz de correlación: `df.corr()`
- Heatmap: `seaborn.heatmap()`
- Identificar variables con alta correlación entre sí o con la variable objetivo

**Patrones generales:**
- Distribución geográfica si hay columnas de ciudad/barrio
- Relación precio vs. otras variables (tipo de alojamiento, número de habitaciones, valoraciones)

---

### FASE 3 — Limpieza y preprocesado de datos

**Objetivo:** Obtener un dataset limpio y listo para análisis y modelado.

#### 3.1 Limpieza básica
- Identificar y tratar **valores nulos**:
  - Eliminar filas/columnas si el porcentaje de nulos es alto: `df.dropna()`
  - **Imputar** si el dato es recuperable:
    - Media/mediana para numéricas: `df.fillna(df.mean())`
    - Moda para categóricas: `df.fillna(df.mode()[0])`
    - Imputación avanzada: `sklearn.impute.KNNImputer` o `SimpleImputer`
- Eliminar **duplicados**: `df.drop_duplicates()`
- Corregir tipos de datos: `pd.to_numeric()`, `pd.to_datetime()`
- Limpiar strings: espacios, mayúsculas, caracteres especiales → `str.strip()`, `str.lower()`

#### 3.2 Técnicas de preprocesado
- **Normalización / Escalado** (necesario para ML posterior):
  - `MinMaxScaler` → escala entre 0 y 1
  - `StandardScaler` → media 0, desviación estándar 1
  - Librería: `sklearn.preprocessing`
- **Codificación de variables categóricas:**
  - `LabelEncoder` → para variables ordinales (bajo, medio, alto)
  - `OneHotEncoder` / `pd.get_dummies()` → para variables nominales sin orden (tipo de habitación, ciudad)

#### 3.3 Conclusiones documentadas
- Cada decisión de limpieza debe quedar explicada en celda Markdown del notebook
- Registrar el tamaño del dataset antes y después de limpiar

---

## 🟡 NIVEL MEDIO — Visualización avanzada y dashboard

---

### FASE 4 — Visualizaciones avanzadas

**Objetivo:** Ir más allá de los gráficos básicos del EDA.

- **Plotly** → gráficos interactivos (hover, zoom, filtros visuales)
  - `plotly.express` para gráficos rápidos
  - `plotly.graph_objects` para control total
- **Seaborn avanzado:**
  - `pairplot()` → relaciones entre todas las variables numéricas
  - `heatmap()` con anotaciones
  - `FacetGrid` → comparar distribuciones entre ciudades o grupos
- **Segmentación por ciudad / grupo de usuarios:**
  - Filtrar por ciudad y comparar métricas clave (precio medio, ocupación, valoración)
  - Identificar diferencias estadísticas entre segmentos

---

### FASE 5 — Dashboard en Looker Studio (Google)

**Herramienta elegida: Looker Studio**
- Gratuito, ejecutable en navegador, integrado con Google Workspace
- Alternativa a PowerBI sin coste de licencia ni instalación
- Permite conectar con Google Sheets, Google Drive, BigQuery, CSV

**Proceso:**
1. Exportar dataset limpio a **Google Sheets** o subir CSV a **Google Drive**
2. Crear fuente de datos en Looker Studio conectando el archivo
3. Diseñar el dashboard con:
   - Métricas clave (KPIs): precio medio, número de alojamientos, valoración media
   - Gráficos de barras, líneas, mapas geográficos
   - Tablas comparativas por ciudad
4. El dashboard debe estar orientado a **perfil de negocio** (no técnico)

**Contenido mínimo del dashboard:**
- Distribución de precios por ciudad
- Tipos de alojamiento más frecuentes
- Relación precio / valoración
- Top barrios o zonas por precio o demanda

---

## 🟠 NIVEL AVANZADO — Interactividad, Docker e hipótesis estadísticas

---

### FASE 6 — Filtros interactivos en el panel

**Tecnologías recomendadas:**
- **Streamlit** → aplicación web en Python, muy rápida de desarrollar
  - `pip install streamlit`
  - Permite crear sliders, dropdowns, multiselect conectados a gráficos Plotly/Matplotlib
  - Se ejecuta en el navegador: `streamlit run app.py`
- **Dash (Plotly)** → más potente, orientado a dashboards de datos complejos
- Looker Studio ya incluye filtros interactivos nativos si se queda en esa herramienta

**Filtros recomendados:**
- Selección de ciudad
- Rango de precios (slider)
- Tipo de alojamiento
- Rango de valoración

---

### FASE 7 — Dockerización

**Objetivo:** Empaquetar la aplicación para que cualquier miembro del equipo (o evaluador) pueda ejecutarla sin instalar dependencias.

**Conceptos clave:**
- **Docker Image:** foto del entorno con todo instalado
- **Docker Container:** instancia en ejecución de esa imagen
- **Dockerfile:** instrucciones para construir la imagen
- **docker-compose.yml:** orquestar múltiples servicios (app + base de datos)

**Estructura mínima del Dockerfile (ejemplo para Streamlit):**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8501
CMD ["streamlit", "run", "app.py", "--server.port=8501"]
```

**Comandos esenciales:**
```bash
docker build -t proyecto-airbnb .
docker run -p 8501:8501 proyecto-airbnb
```

---

### FASE 8 — Hipótesis estadísticas

**Objetivo:** Validar con datos las conclusiones del EDA.

**Proceso:**
1. Formular hipótesis a partir del EDA (ejemplos):
   - "El precio medio en Madrid es significativamente mayor que en Barcelona"
   - "Las valoraciones altas están correlacionadas con precios más bajos"
2. Elegir el test estadístico adecuado:
   - **t-test** (`scipy.stats.ttest_ind`) → comparar medias de dos grupos
   - **ANOVA** (`scipy.stats.f_oneway`) → comparar medias de más de dos grupos
   - **Chi-cuadrado** (`scipy.stats.chi2_contingency`) → relación entre variables categóricas
   - **Correlación de Pearson/Spearman** → relación entre variables numéricas
3. Interpretar el **p-valor**:
   - p < 0.05 → se rechaza la hipótesis nula (hay diferencia significativa)
   - p ≥ 0.05 → no hay evidencia suficiente para rechazarla
4. Documentar cada hipótesis con su resultado en el notebook

---

## 🔴 NIVEL EXPERTO — ML, datos externos y despliegue público

---

### FASE 9 — Machine Learning y Clustering

**Selección de variables (Feature Selection):**
- Correlación con variable objetivo: `df.corr()`
- `sklearn.feature_selection.SelectKBest`
- Importancia de variables con RandomForest: `feature_importances_`

**Modelos simples recomendados:**
- **Regresión lineal** (`LinearRegression`) → predecir precio
- **Decision Tree** (`DecisionTreeRegressor/Classifier`)
- **Logistic Regression** → si se define una variable objetivo binaria

**Modelos de ensemble:**
- **RandomForest** → robusto, buena interpretabilidad
- **GradientBoosting / XGBoost / LightGBM** → alta precisión
- Librería: `sklearn.ensemble`, `xgboost`, `lightgbm`

**Clustering (no supervisado):**
- **K-Means** (`sklearn.cluster.KMeans`) → agrupar alojamientos por características similares
- **DBSCAN** → útil si hay clusters de forma irregular o ruido geográfico
- Visualización de clusters: `seaborn`, `plotly`, reducción dimensional con **PCA** o **t-SNE**

**Métricas de evaluación:**
- Regresión: MAE, MSE, R²
- Clasificación: accuracy, precision, recall, F1
- Clustering: silhouette score

---

### FASE 10 — Integración de datos externos

**Fuentes de datos complementarios (gratuitas):**
- **INE (Instituto Nacional de Estadística):** datos demográficos por ciudad/barrio → [ine.es](https://www.ine.es)
- **Idealista / Fotocasa API** (si disponible): precios de mercado inmobiliario de referencia
- **OpenStreetMap / Nominatim:** datos geográficos (distancia al centro, transporte)
- **datos.gob.es:** portal de datos abiertos del Gobierno de España
- **Eurostat:** datos económicos europeos comparables entre ciudades

**Proceso de integración:**
- Unir por columna de ciudad/barrio: `pd.merge()`
- Cuidado con distintos niveles de granularidad (ciudad vs. barrio vs. código postal)

---

### FASE 11 — Despliegue público

**Opciones gratuitas o de bajo coste:**

| Plataforma | Tecnología | Coste | Notas |
|---|---|---|---|
| **Streamlit Community Cloud** | Streamlit | Gratuito | Ideal para este proyecto, deploy desde GitHub |
| **Render** | Docker / Python | Gratuito (tier básico) | Soporta Docker directamente |
| **Railway** | Docker | Gratuito (límite horas) | Fácil conexión con GitHub |
| **Hugging Face Spaces** | Streamlit / Gradio | Gratuito | Comunidad ML, buena visibilidad |
| **Azure / AWS Free Tier** | Docker + Cloud | Gratuito (12 meses) | Cubre el criterio de cloud de la rúbrica |

**Recomendación para este proyecto:**
- **Streamlit Community Cloud** para el dashboard interactivo (gratis, deploy desde GitHub en minutos)
- **Azure Free Tier** si se quiere cubrir el criterio de cloud de la rúbrica (competencia 4)

---

## 📋 Resumen de entregables por nivel

| Nivel | Entregable clave | Herramientas |
|---|---|---|
| 🟢 Esencial | Notebook EDA documentado + GitHub + Kanban | Python, Pandas, Seaborn, Matplotlib, Git, Trello |
| 🟡 Medio | Dashboard funcional + visualizaciones avanzadas | Looker Studio, Plotly, Seaborn |
| 🟠 Avanzado | App interactiva + Docker + hipótesis validadas | Streamlit, Docker, Scipy |
| 🔴 Experto | Modelo ML + datos externos + despliegue | Sklearn, XGBoost, Streamlit Cloud / Azure |

---

## 📌 Observaciones para la propuesta al equipo

1. **El nivel esencial no es negociable** — todo lo demás se construye encima. Si el EDA y la documentación no están bien, el resto no tiene base.
2. **Looker Studio** es la opción más pragmática para el dashboard sin coste. Si el equipo prefiere PowerBI, requiere Windows y licencia para publicar.
3. **Docker** puede ser intimidante al principio, pero el Dockerfile para Streamlit es muy sencillo. Vale la pena incluirlo en el nivel avanzado.
4. **El clustering** (K-Means) es más accesible que los modelos supervisados para un primer acercamiento al nivel experto, y encaja bien con el contexto (segmentar tipos de alojamiento o perfiles de precio).
5. **Streamlit Community Cloud** es la forma más rápida de tener un despliegue público sin coste y conectado directamente al repositorio de GitHub.

---

*Documento generado como propuesta de trabajo. Pendiente de revisión y aprobación por el equipo.*
