# Protocolo EDA v2 — P8-Data-Analyst
**Estado:** Borrador · Pendiente de presentación y aprobación por el equipo  
**Alcance:** Solo redacción de protocolo — sin implementación  
**Enfoque:** Análisis de datos orientado a interpretación y extracción de conclusiones  
**Datasets:** CSV de 6 ciudades — Madrid, Londres, Milán, Nueva York, Sydney, Tokio  

---

## Principios del protocolo

1. **Homogenización primero.** Antes de cualquier análisis estadístico, todos los datasets deben hablar el mismo idioma: mismas unidades, mismos formatos, misma codificación. Un análisis sobre datos no homogéneos produce conclusiones falsas.

2. **EDA iterativo.** El EDA no es un paso único — es un ciclo. Cada iteración revela nuevas anomalías que generan nuevas preguntas que requieren nuevas exploraciones. El notebook documenta cada iteración con sus hallazgos y decisiones.

3. **Distinción entre dato atípico y outlier.**
   - **Dato atípico:** no es homogéneo en *características*. Problema de tipo, codificación o formato incorrecto. Ejemplo: latitud almacenada como string, fecha en formato incompatible, caracteres en alfabeto no esperado.
   - **Outlier:** no es homogéneo en *valores*. El tipo es el esperado, pero el valor está fuera del rango razonable para esa variable. Ejemplo: precio de 99.999 € para un alojamiento en Madrid.
   - El tratamiento es diferente: los datos atípicos se corrigen en la fase de homogenización; los outliers se analizan y se decide en la fase de limpieza.

4. **Modelado al servicio de la interpretación.** Si se entrena algún modelo en este proyecto, su propósito es reforzar las conclusiones extraídas del análisis — no el modelo en sí mismo.

5. **Valores semisintéticos — visibilidad obligatoria.** Cualquier valor imputado por modelización debe quedar marcado explícitamente en el dataset procesado. Las conclusiones extraídas de valores semisintéticos tienen menor certeza que las extraídas de datos observados y deben citarse como tales.

---

## FASE 0 — Auditoría de Datos Crudos

> **[SDD]** Antes de tocar los datos, generar un informe de auditoría automática por dataset que documente: estructura, tipos, nulos, valores únicos y anomalías detectables por código simple. Este informe es el punto de partida de todas las decisiones posteriores y debe guardarse como artefacto del proyecto.

### 0.1 Inventario de datasets

| Dataset | Ciudad | Moneda | Formato fecha | Observaciones conocidas |
|---|---|---|---|---|
| `madrid_airbnb.csv` | Madrid | EUR (€) | `yyyy-mm-dd` | — |
| `london_airbnb.csv` | Londres | GBP (£) | `yyyy-mm-dd` | `neighbourhood_group` vacío |
| `milan_airbnb.csv` | Milán | EUR (€) | `dd/mm/yy` | Sin `neighbourhood_group` |
| `NY_airbnb.csv` | Nueva York | USD ($) | `yyyy-mm-dd` | — |
| `sydney_airbnb.csv` | Sydney | AUD ($) | `yyyy-mm-dd` | `neighbourhood_group` vacío |
| `tokyo_airbnb.csv` | Tokio | JPY (¥) | `yyyy-mm-dd` | Caracteres japoneses; sin `availability_365` ni `calculated_host_listings_count` |

### 0.2 Mapeo de anomalías detectables

> **[SDD]** Generar para cada dataset una tabla de anomalías que indique: dataset, columna, fila de muestra, tipo de anomalía (dato atípico / outlier / nulo / formato) y severidad. Esta tabla es el artefacto de entrada de la fase de homogenización.

Tipos de anomalías a mapear sistemáticamente:

- **Caracteres en alfabeto no latino:** detectar en columnas `name`, `host_name`, `neighbourhood`. Confirmar si son japonés (Tokio), árabe, cirílico u otro. Decisión: ¿traducir, transliterar o mantener?
- **Tipos de dato incorrectos:** latitud/longitud almacenadas como string o con comas en lugar de puntos decimales.
- **Fechas en formato no estándar:** Milán usa `dd/mm/yy` — riesgo de inversión de día y mes si se parsea con configuración por defecto.
- **Valores fuera de rango geográfico:** latitud y longitud que no corresponden a la ciudad declarada (posible error de entrada o registro de otra ciudad).
- **Precios cero o negativos:** precios = 0 son errores evidentes; precios negativos imposibles.
- **Columnas ausentes por dataset:** Tokio no tiene `availability_365` ni `calculated_host_listings_count`. Registrar explícitamente qué columnas faltan en cada ciudad.

### 0.3 Estudio comparativo de estructura entre datasets

> **[SDD]** Generar una matriz de presencia/ausencia de columnas por dataset. Identificar: columnas comunes a todos, columnas presentes en algunos, columnas únicas de un solo dataset. Esta matriz determina qué análisis pueden hacerse de forma global y cuáles solo por ciudad.

Preguntas a responder:
- ¿Hay columnas que se llaman igual pero tienen contenido diferente entre ciudades?
- ¿Hay valores que parecen repetidos entre datasets (mismo `host_id` en ciudades distintas)?
- ¿Hay tendencias comunes que se repiten en todos los datasets? (distribución de `room_type`, rangos de precio, patrones de `minimum_nights`)

---

## FASE 1 — Homogenización

> **[SDD]** Esta fase transforma los datos crudos en un dataset consistente y comparable entre ciudades. Ningún análisis comparativo puede ejecutarse antes de completarla. El resultado es `airbnb_homogenizado.csv` con trazabilidad de cada transformación aplicada.

### 1.1 Normalización de fechas

> **[SDD]** Convertir todas las fechas a formato ISO 8601 (`yyyy-mm-dd`) usando parseo explícito por dataset para evitar ambigüedades.

Casos específicos:
- **Milán (`dd/mm/yy`):** parseo con `dayfirst=True`. Verificar que el año de dos dígitos se interpreta correctamente (¿2010 o 1910?).
- **Resto de ciudades (`yyyy-mm-dd`):** parseo estándar.
- Verificar rango razonable de fechas: `last_review` no debería ser posterior a la fecha de descarga del dataset.

### 1.2 Normalización de coordenadas geográficas

> **[SDD]** Validar que latitud y longitud son de tipo float y corresponden geográficamente a la ciudad declarada. Marcar como dato atípico (no outlier) cualquier coordenada fuera del bounding box de la ciudad.

Bounding boxes de referencia (aproximados):

| Ciudad | Latitud min | Latitud max | Longitud min | Longitud max |
|---|---|---|---|---|
| Madrid | 40.30 | 40.65 | -3.85 | -3.52 |
| Londres | 51.28 | 51.70 | -0.51 | 0.33 |
| Milán | 45.38 | 45.54 | 9.04 | 9.28 |
| Nueva York | 40.48 | 40.92 | -74.26 | -73.68 |
| Sydney | -34.17 | -33.57 | 150.52 | 151.35 |
| Tokio | 35.52 | 35.82 | 139.56 | 139.92 |

Registros fuera del bounding box → clasificar como **dato atípico geográfico** → investigar antes de eliminar (pueden ser alojamientos en área metropolitana legítimamente fuera del límite administrativo).

### 1.3 Conversión de monedas a EUR

> **[SDD]** Aplicar tipo de cambio a una fecha de referencia fija y documentarla. Crear columna `price_eur` adicional, manteniendo `price` original. Así el análisis comparativo usa `price_eur` y el análisis por ciudad puede usar `price` en moneda local.

Tipos de cambio a fijar (fecha de referencia acordada por el equipo):
- GBP → EUR (Londres)
- USD → EUR (Nueva York)
- AUD → EUR (Sydney)
- JPY → EUR (Tokio)

> ⚠️ Los tipos de cambio varían. Usar una fecha fija garantiza reproducibilidad. Documentar la fuente (ECB, Banco de España, etc.).

### 1.4 Tratamiento de caracteres japoneses (Tokio)

> **[SDD]** Detectar columnas con caracteres en rango Unicode japonés (hiragana, katakana, kanji). Confirmar que son japonés. Proponer estrategia: transliteración al alfabeto latino (romaji) para columnas como `name` y `neighbourhood`, o mantener original con columna paralela transliterada.

Columnas afectadas previsibles: `name`, `host_name`, `neighbourhood`.

Estrategia propuesta:
- Mantener columna original (`name_ja`)
- Añadir columna transliterada (`name_romaji`) usando librería `pykakasi` o traducción vía API
- Para el análisis, usar la columna transliterada

### 1.5 Homogenización de columnas faltantes

> **[SDD]** Para datasets que no tienen ciertas columnas (Tokio sin `availability_365`), decidir en equipo: ¿excluir esas columnas del análisis global? ¿imputar con valor nulo marcado? ¿excluir Tokio de ciertos análisis? Documentar la decisión antes de proceder.

### 1.6 Datasets secundarios de descriptores

> **[SDD]** Crear datasets auxiliares que actúen como diccionario de los datos procesados. Mínimo:
- `ciudades_metadata.csv`: ciudad, moneda original, tipo de cambio usado, fecha de referencia, fuente del dataset, fecha de descarga, número de registros crudos, número de registros tras limpieza
- `columnas_por_dataset.csv`: matriz de presencia/ausencia de columnas por ciudad
- `anomalias_detectadas.csv`: mapeo completo de anomalías (dataset, columna, tipo, severidad, decisión tomada)

Estos datasets secundarios son los **IDs y claves** que dan trazabilidad a todo el proceso.

---

## FASE 2 — Análisis Univariante

> **[SDD]** Analizar cada variable de forma independiente sobre el dataset homogenizado. Documentar distribución, anomalías residuales y decisiones de tratamiento. Aplicar por separado a cada ciudad y al dataset combinado.

### 2.1 Estadística descriptiva

- `describe()`: media, mediana, desviación estándar, percentiles. Ejecutar por ciudad y global.
- `info()`: tipos de dato y nulos tras homogenización.
- `value_counts()`: frecuencias de variables categóricas. Verificar si hay categorías con muy pocas observaciones (< 1% del total).

### 2.2 Gráfico de frecuencias — Variable objetivo

> **[SDD]** Antes de cualquier análisis, verificar el balance de la variable central del análisis (`room_type`, y secundariamente `city`). Un desequilibrio severo condiciona todas las técnicas posteriores y debe documentarse como limitación del dataset.

- ¿Están las categorías de `room_type` equilibradas globalmente y por ciudad?
- ¿Hay categorías que aparecen en algunas ciudades pero no en otras?
- Implicación para modelado: clases muy minoritarias requieren técnicas de balanceo si se entrena un clasificador.

### 2.3 Histogramas y KDE

> **[SDD]** Para cada variable numérica, generar histograma con el número de intervalos justificado (regla de Sturges, Scott o Freedman-Diaconis según el tamaño de la muestra) y superponer curva KDE. El histograma muestra la frecuencia discreta por intervalo; el KDE estima la densidad continua subyacente. Ambas representaciones son complementarias, no alternativas.

Variables a analizar: `price_eur`, `minimum_nights`, `number_of_reviews`, `reviews_per_month`, `availability_365` (donde exista).

Qué documentar por variable:
- ¿Distribución simétrica o sesgada? ¿En qué dirección?
- ¿Hay bimodalidad? (dos picos → posible mezcla de subpoblaciones)
- ¿Escalas muy diferentes entre variables? → señal de necesidad de escalado

### 2.4 Boxplots individuales y detección de outliers

> **[SDD]** Aplicar método IQR con k=1.5 (estándar Tukey) y k=3.0 (conservador). Documentar el número y porcentaje de outliers con cada umbral. La decisión final sobre qué umbral usar debe acordarse en equipo antes de la fase de limpieza.

Distinción crítica:
- **Outlier legítimo:** alojamiento de lujo con precio real de 2.000 €/noche → mantener con justificación
- **Outlier por error:** precio = 0 o precio = 999.999 → eliminar con documentación
- **Dato atípico residual:** precio almacenado como string con símbolo de moneda → ya corregido en homogenización

> ⚠️ Conexión con ML: outliers no tratados aumentan el riesgo de overfitting. Si la brecha entre métricas de entrenamiento y validación supera el 5%, revisar si los outliers están en el conjunto de entrenamiento.

---

## FASE 3 — Análisis Bivariante

> **[SDD]** Estudiar relaciones entre pares de variables. Objetivo: identificar qué variables tienen capacidad discriminante respecto a las variables de mayor interés analítico (`price_eur`, `room_type`, `city`).

### 3.1 Boxplot agrupado

Una caja por categoría, para cada variable numérica relevante.

- `price_eur` por `room_type` → ¿separan bien los precios según tipo de alojamiento?
- `price_eur` por `city` → ¿hay ciudades sistemáticamente más caras en términos reales (€)?
- `number_of_reviews` por `room_type`
- `minimum_nights` por `city`

Criterio de interpretación: si las cajas de dos categorías no se solapan, esa variable tiene alta capacidad discriminante.

### 3.2 KDE superpuesto por categoría

Varias curvas KDE en el mismo gráfico, una por valor de la variable categórica, con transparencia.

Complementa el boxplot mostrando la forma completa de la distribución por grupo. Detecta diferencias de forma, no solo de media o mediana.

### 3.3 Scatter plot con color por categoría

Dos variables numéricas en los ejes, coloreadas por categoría.

- `price_eur` vs. `number_of_reviews`, color = `room_type`
- `price_eur` vs. `minimum_nights`, color = `city`
- `latitude` vs. `longitude`, color = `room_type` → distribución geográfica por tipo

Criterio de interpretación: si los colores forman clusters visualmente separables, esas dos variables combinadas tienen poder discriminante.

### 3.4 Estudio comparativo de valores repetidos o con tendencias

> **[SDD]** Analizar si hay valores que se repiten sistemáticamente entre datasets de diferentes ciudades. Ejemplos a investigar:
- ¿Hay `host_id` que aparecen en más de una ciudad? (hosts internacionales)
- ¿Hay patrones de `minimum_nights` que se repiten globalmente (1, 2, 7, 30, 365)?
- ¿Hay precios "redondos" con frecuencia estadísticamente significativa? (señal de precios fijados manualmente)
- ¿Hay `neighbourhood` con nombres iguales en ciudades distintas? (problema de normalización de nombres)

Este análisis puede revelar patrones reales de comportamiento de los hosts o artefactos del proceso de recolección de datos de AirBnB.

---

## FASE 4 — Análisis Multivariante

> **[SDD]** Analizar el espacio completo de variables simultáneamente. Objetivo: detectar redundancias (multicolinealidad), interacciones complejas y estructuras de agrupamiento latentes.

### 4.1 Heatmap de correlación

Matriz de correlación de Pearson para variables numéricas. Ejecutar por ciudad y global.

- Pares con |r| > 0.7 → candidatos a eliminar uno (multicolinealidad)
- Variables con baja correlación con todo → pueden ser poco útiles para el modelo
- Diferencias entre ciudades en la estructura de correlación → señal de heterogeneidad

### 4.2 Pair plot (Matriz de Dispersión)

Cuadrícula de scatter plots para todas las combinaciones de variables numéricas, coloreados por categoría. Ejecutar sobre muestra representativa (3.000-5.000 filas) para no saturar memoria.

El histograma en la diagonal muestra la distribución univariante de cada variable. Los scatter plots fuera de la diagonal muestran relaciones bivariantes. Buscar: combinaciones donde los colores forman clusters separables.

### 4.3 Gráfico de Coordenadas Paralelas

Especialmente útil si los `.xlsx` de Madrid, Londres y Milán aportan columnas adicionales. Cada variable es un eje vertical; cada alojamiento es una línea que viaja por todos los ejes. Colorear por `room_type` o `city`.

Permite detectar cómo se comporta cada categoría a través de todas las dimensiones simultáneamente.

### 4.4 Análisis asistido por IA (Claude)

> **[SDD]** Diseñar un protocolo para introducir subconjuntos del dataset en Claude para análisis de patrones no detectables por código simple. El protocolo debe especificar:
- Tamaño máximo del subconjunto a introducir (limitado por ventana de contexto)
- Columnas incluidas en cada consulta
- Qué anomalías o patrones detectados en el ipynb se presentan como punto de partida
- Formato de la respuesta esperada (tabla de hallazgos, hipótesis generadas, código sugerido)

Este enfoque es iterativo: el código simple detecta anomalías superficiales → la IA profundiza en los patrones → el código implementa las hipótesis generadas → nueva iteración.

---

## FASE 5 — Tratamiento de Valores Nulos e Imputación por Modelización

> **[SDD]** Los valores nulos no se tratan de forma uniforme. Para cada columna con nulos, evaluar si la imputación es apropiada y qué tipo de modelo ofrece la mejor estimación. Documentar explícitamente qué valores son semisintéticos en el dataset procesado.

### 5.1 Clasificación de nulos por tipo

Antes de imputar, clasificar cada nulo:

| Tipo | Descripción | Tratamiento |
|---|---|---|
| **MCAR** (Missing Completely at Random) | La ausencia no depende de ninguna variable | Imputación simple o eliminación |
| **MAR** (Missing at Random) | La ausencia depende de otras variables observadas | Imputación por modelo |
| **MNAR** (Missing Not at Random) | La ausencia depende del propio valor ausente | Requiere análisis específico; imputación arriesgada |

Ejemplo en nuestro dataset: `reviews_per_month` es nulo cuando `number_of_reviews = 0`. Es un nulo **MCAR** con causa conocida → imputar con 0 es correcto. `last_review` nulo cuando no hay reviews → mismo caso.

### 5.2 Modelos de imputación propuestos

> **[SDD]** Para nulos de tipo MAR, proponer y comparar al menos dos modelos de imputación. El modelo elegido debe documentarse con su justificación. Los valores imputados deben marcarse con una columna flag (`columna_imputed = True/False`).

**Modelos simples (baseline):**
- Imputación por media/mediana: adecuada para distribuciones simétricas sin outliers
- Imputación por moda: para variables categóricas
- Imputación por valor constante (0, "Unknown"): cuando la ausencia tiene significado propio

**Modelos basados en similitud:**
- **KNN Imputer** (`sklearn.impute.KNNImputer`): imputa basándose en los k vecinos más similares en el espacio de las otras variables. Adecuado cuando hay correlación entre variables. Preserva mejor la distribución original que la media.
- **Imputación por segmento geográfico:** para `price_eur` nulo, imputar con la mediana del mismo `neighbourhood` y `room_type`. Más contextual que la mediana global.

**Modelos predictivos (valores semisintéticos):**
- **Regresión lineal/Ridge:** predecir el valor nulo a partir de las otras variables. Adecuado para variables continuas con relaciones lineales. Ejemplo: predecir `price_eur` nulo a partir de `room_type`, `neighbourhood`, `minimum_nights`.
- **Random Forest Regressor/Classifier:** para variables con relaciones no lineales o categóricas. Más robusto que la regresión lineal, sin asumir linealidad.
- **Iterative Imputer** (`sklearn.impute.IterativeImputer`): imputa iterativamente cada columna usando las demás como predictores. Equivalente a MICE (Multiple Imputation by Chained Equations). Es el enfoque más sofisticado y produce los valores semisintéticos de mayor calidad estadística.

> ⚠️ **Advertencia sobre valores semisintéticos:** cualquier análisis o conclusión basado en valores imputados por modelo tiene menor certeza que el basado en datos observados. Las conclusiones deben citarlos explícitamente. Si el porcentaje de valores semisintéticos supera el 10-15% en una variable, reconsiderar si esa variable es fiable para el análisis.

---

## FASE 6 — EDA Final e Iterativo

> **[SDD]** El EDA no termina tras la primera exploración. Cada hallazgo genera nuevas preguntas. El notebook debe estructurarse para facilitar iteraciones: cada iteración tiene su propia sección con fecha, hallazgo disparador y conclusiones.

### 6.1 Estructura del notebook EDA iterativo

```
Iteración 1 — EDA inicial sobre datos crudos
  → Hallazgos: anomalías identificadas, tipos incorrectos, nulos
  → Decisiones: homogenización necesaria

Iteración 2 — EDA sobre datos homogenizados
  → Hallazgos: distribuciones reales, outliers validados
  → Decisiones: tratamiento de outliers, imputación

Iteración 3 — EDA sobre datos limpios
  → Hallazgos: patrones, correlaciones, poder discriminante
  → Decisiones: variables relevantes para modelado

Iteración N — EDA posterior a primeros modelos
  → Hallazgos: features importance, errores del modelo
  → Decisiones: nuevas transformaciones, nuevas variables
```

### 6.2 Presentación efectiva de conclusiones

> **[SDD]** Las conclusiones deben emanar de lo observado, no preceder al análisis. Cada conclusión debe estar respaldada por al menos una visualización y un estadístico numérico. Las conclusiones especulativas (no respaldadas por datos) deben marcarse explícitamente como hipótesis pendientes de validación.

Formato propuesto para cada conclusión en el notebook:
```
### Conclusión X
**Observación:** [qué se ve en los datos]
**Evidencia:** [gráfico + estadístico]
**Interpretación:** [qué significa para el negocio]
**Certeza:** Alta / Media / Baja (si hay valores semisintéticos involucrados)
**Hipótesis derivada:** [qué habría que comprobar a continuación]
```

---

## Resumen del protocolo

| Fase | Objetivo | Artefacto de salida |
|---|---|---|
| 0 — Auditoría | Mapear anomalías y estructura | `anomalias_detectadas.csv`, `columnas_por_dataset.csv` |
| 1 — Homogenización | Datos comparables entre ciudades | `airbnb_homogenizado.csv`, `ciudades_metadata.csv` |
| 2 — Univariante | Conocer cada variable | Histogramas, KDE, boxplots, frecuencias |
| 3 — Bivariante | Relaciones y poder discriminante | Boxplots agrupados, KDE superpuesto, scatter plots |
| 4 — Multivariante | Redundancias e interacciones | Heatmap, pairplot, coordenadas paralelas |
| 5 — Imputación | Tratar nulos con trazabilidad | Dataset con flags de valores semisintéticos |
| 6 — EDA iterativo | Conclusiones respaldadas por datos | Notebook con secciones por iteración |

---

*Documento de protocolo — sin implementación. Pendiente de revisión y aprobación del equipo.*
