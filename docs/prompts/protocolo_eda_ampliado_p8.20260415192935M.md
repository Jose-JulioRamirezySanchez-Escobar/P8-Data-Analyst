# Protocolo EDA Ampliado — P8-Data-Analyst

> **Estado:** Borrador — Pendiente de presentación y aprobación por parte del equipo  
> **Enfoque:** Spec-Driven Development (SDD) — Solo especificación. No implementar.  
> **Ámbito:** Análisis exploratorio de datos orientado a interpretación y modelado descriptivo/predictivo sobre los datasets de las 6 ciudades (CSV).

---

## Índice

1. [Contexto y objetivo](#1-contexto-y-objetivo)
2. [Datasets de trabajo](#2-datasets-de-trabajo)
3. [Fase 0 — Inventario y mapeo de anomalías](#3-fase-0--inventario-y-mapeo-de-anomalías)
4. [Fase 1 — Homogenización de tipos de datos](#4-fase-1--homogenización-de-tipos-de-datos)
5. [Fase 2 — Datasets secundarios de descriptores](#5-fase-2--datasets-secundarios-de-descriptores)
6. [Fase 3 — Distinción y tratamiento: datos atípicos vs. outliers](#6-fase-3--distinción-y-tratamiento-datos-atípicos-vs-outliers)
7. [Fase 4 — Análisis comparativo entre datasets](#7-fase-4--análisis-comparativo-entre-datasets)
8. [Fase 5 — Análisis asistido por IA](#8-fase-5--análisis-asistido-por-ia)
9. [Fase 6 — Imputación de nulos mediante modelización predictiva](#9-fase-6--imputación-de-nulos-mediante-modelización-predictiva)
10. [Fase 7 — EDA final iterativo en ipynb](#10-fase-7--eda-final-iterativo-en-ipynb)
11. [Notas y erratas detectadas](#11-notas-y-erratas-detectadas)

---

## 1. Contexto y objetivo

Este protocolo define las especificaciones para un **EDA ampliado** aplicado al análisis e interpretación de datos de 6 ciudades. El propósito no es únicamente describir los datos, sino prepararlos para que el modelado posterior permita **extraer conclusiones significativas**.

La acción prioritaria es la **homogenización de los datos** antes de cualquier análisis o comparación. El modelado de uno o varios modelos está destinado a servir como herramienta de interpretación, no como fin en sí mismo.

El pipeline general sigue el esquema:

```
Ingesta CSV → Inventario/Mapeo → Homogenización → Descriptores → EDA iterativo → Modelado interpretativo
```

---

## 2. Datasets de trabajo

Se trabajará con los ficheros CSV correspondientes a las siguientes 6 ciudades:

| ID | Ciudad   | Fichero CSV       | Observaciones iniciales conocidas        |
|----|----------|-------------------|------------------------------------------|
| 1  | Milán    | `milan.csv`       | Formato de fecha `dd/mm/yy`             |
| 2  | Madrid   | `madrid.csv`      | Formato de fecha `yyyy-mm-dd`           |
| 3  | Londres  | `london.csv`      | Formato de fecha `yyyy-mm-dd`           |
| 4  | Nueva York | `ny.csv`        | Formato de fecha `yyyy-mm-dd`           |
| 5  | Sídney   | `sydney.csv`      | Formato de fecha `yyyy-mm-dd`           |
| 6  | Tokio    | `tokyo.csv`       | Formato de fecha `yyyy-mm-dd`; caracteres en alfabeto oriental |

> **SDD-001:** Los nombres de fichero y rutas definitivas deberán confirmarse antes de la implementación.

---

## 3. Fase 0 — Inventario y mapeo de anomalías

### Objetivo
Antes de cualquier transformación, **documentar y mapear** todas las anomalías detectadas en los datos. Este mapa de anomalías será el artefacto de referencia para las fases posteriores.

### Especificaciones

#### SDD-002 — Mapa de anomalías
Generar un registro estructurado (p. ej. `anomaly_map.json` o DataFrame auxiliar) que capture, para cada anomalía detectada:

| Campo            | Descripción                                              |
|------------------|----------------------------------------------------------|
| `dataset`        | Ciudad / fichero de origen                              |
| `row_index`      | Índice o rango de filas afectadas                       |
| `column`         | Nombre de la columna afectada                           |
| `anomaly_type`   | Categoría: `encoding`, `format`, `type`, `null`, `outlier`, `atypical`, `other` |
| `description`    | Descripción legible de la anomalía                      |
| `sample_values`  | Ejemplo(s) de los valores problemáticos                 |
| `proposed_action`| Acción recomendada según el protocolo                   |

#### SDD-003 — Caracteres en alfabeto oriental (Tokio)
- Confirmar que los caracteres detectados corresponden al **japonés** (y no a otro idioma CJK como chino o coreano).
- Registrar en el mapa de anomalías: dataset, columnas afectadas, muestra de valores.
- Especificar la estrategia de traducción: API de traducción, diccionario curado, o trasliteración según el tipo de dato (nombre propio vs. categoría vs. texto libre).
- La traducción deberá producir una columna nueva (`*_translated`) manteniendo el valor original.

#### SDD-004 — Búsqueda de otras características especiales
Además de las anomalías ya conocidas, el protocolo requiere una **exploración sistemática** en busca de:
- Codificaciones de caracteres no estándar (no UTF-8).
- Valores que mezclan tipos en la misma columna (p. ej. numérico + cadena de texto).
- Campos con separadores decimales inconsistentes (coma vs. punto).
- Columnas con valores constantes o cuasi-constantes (baja varianza).
- Columnas duplicadas o con nombres ambiguos.
- Cualquier otra particularidad no prevista inicialmente.

Todas las características encontradas deben incorporarse al mapa de anomalías.

---

## 4. Fase 1 — Homogenización de tipos de datos

### Objetivo
Transformar los datos a tipos consistentes, significativos y comparables entre todos los datasets.

### Especificaciones

#### SDD-005 — Fechas
Unificar todas las fechas al formato ISO 8601 (`yyyy-mm-dd`) como tipo `datetime`.

| Ciudad     | Formato origen | Transformación requerida              |
|------------|---------------|---------------------------------------|
| Milán      | `dd/mm/yy`    | Parsear con `dayfirst=True`; inferir siglo (precaución con años ambiguos) |
| Madrid     | `yyyy-mm-dd`  | Validar; ninguna transformación de formato |
| Londres    | `yyyy-mm-dd`  | Validar; ninguna transformación de formato |
| Nueva York | `yyyy-mm-dd`  | Validar; ninguna transformación de formato |
| Sídney     | `yyyy-mm-dd`  | Validar; ninguna transformación de formato |
| Tokio      | `yyyy-mm-dd`  | Validar; ninguna transformación de formato |

> **Nota de riesgo:** El formato `dd/mm/yy` de Milán es ambiguo para años de dos dígitos. Se deberá especificar la regla de pivot (p. ej. año ≥ 25 → 1900s, año < 25 → 2000s) y documentarla.

#### SDD-006 — Latitud y longitud
- Convertir latitud y longitud al tipo `float64`.
- Validar que los valores se encuentren dentro del bounding box geográfico esperado para cada ciudad (margen configurable, por defecto ±2°).
- Los registros con coordenadas fuera del rango esperado deberán ser marcados como `atypical` en el mapa de anomalías y **no eliminados** en esta fase.

| Ciudad     | Latitud esperada (aprox.) | Longitud esperada (aprox.) |
|------------|--------------------------|---------------------------|
| Milán      | 45.0 – 45.8              | 8.9 – 9.5                |
| Madrid     | 40.2 – 40.7              | -3.9 – -3.5              |
| Londres    | 51.3 – 51.7              | -0.5 – 0.3               |
| Nueva York | 40.5 – 40.9              | -74.3 – -73.7            |
| Sídney     | -34.1 – -33.7            | 150.9 – 151.4            |
| Tokio      | 35.5 – 35.9              | 139.5 – 139.9            |

#### SDD-007 — Monedas
- Identificar todas las columnas que representen valores monetarios en cada dataset.
- Convertir todos los valores a **euros (€)** aplicando el tipo de cambio correspondiente.
- Fuente del tipo de cambio: a definir por el equipo (p. ej. tipo de cambio fijo de referencia para la fecha del dataset, o tipo de cambio de una fecha acordada).
- Crear columna nueva `*_eur` conservando el valor original y la moneda de origen en metadatos o columna auxiliar.
- Registrar la tasa de conversión utilizada en el dataset secundario de descriptores (ver Fase 2).

---

## 5. Fase 2 — Datasets secundarios de descriptores

### Objetivo
Mantener la trazabilidad de las transformaciones y enriquecer los datos con metadatos estructurados.

### Especificaciones

#### SDD-008 — Estructura de datasets secundarios
Para cada dataset procesado, generar al menos un **dataset secundario de descriptores** con la siguiente información:

| Campo                | Descripción                                                      |
|----------------------|------------------------------------------------------------------|
| `field_id`           | Identificador único del campo/columna                           |
| `field_name`         | Nombre original de la columna                                   |
| `field_name_clean`   | Nombre normalizado                                              |
| `dtype_original`     | Tipo de dato en el CSV original                                 |
| `dtype_processed`    | Tipo de dato tras la homogenización                             |
| `transform_applied`  | Descripción de la transformación aplicada                       |
| `unit_original`      | Unidad original (p. ej. moneda, formato de fecha)               |
| `unit_processed`     | Unidad tras la transformación                                   |
| `null_count`         | Número de nulos antes del procesamiento                         |
| `anomaly_flags`      | Referencias al mapa de anomalías relacionadas                   |
| `notes`              | Notas adicionales                                               |

#### SDD-009 — Registro de tipos de cambio y factores de conversión
Crear un dataset auxiliar específico con los factores de conversión monetaria utilizados, incluyendo fecha de referencia y fuente.

---

## 6. Fase 3 — Distinción y tratamiento: datos atípicos vs. outliers

### Definiciones de referencia del protocolo

> **Dato atípico:** Valor no homogéneo en **características**. Se trata de una anomalía cualitativa: el tipo de dato, la codificación o la naturaleza del valor no corresponde con lo esperado para esa columna. Ejemplo: una cadena de texto en una columna numérica, un carácter oriental en un campo de nombre de ciudad latina, un valor en una moneda inesperada.

> **Outlier:** Valor no homogéneo en **magnitud**. Es una anomalía cuantitativa: el valor es del tipo correcto, pero cae fuera de un rango estadísticamente esperado. Ejemplo: una temperatura de 95 °C en una columna de temperatura ambiente, o un precio 10 veces superior al percentil 99.

### Especificaciones

#### SDD-010 — Detección de datos atípicos
- Aplicar reglas de validación de tipo y dominio por columna.
- Registrar en el mapa de anomalías con `anomaly_type = "atypical"`.
- No corregir automáticamente; marcar para revisión humana o asistida por IA.

#### SDD-011 — Detección de outliers
- Aplicar métodos estadísticos configurables:
  - Rango intercuartílico (IQR): valores fuera de `[Q1 - k·IQR, Q3 + k·IQR]`, con `k` configurable (por defecto 1.5).
  - Z-score: valores con `|z| > umbral` configurable (por defecto 3).
  - Métodos adicionales a considerar: Isolation Forest, LOF (Local Outlier Factor).
- Registrar en el mapa de anomalías con `anomaly_type = "outlier"`.
- Presentar en el EDA con visualizaciones específicas (boxplots, distribuciones).

#### SDD-012 — Presentación de observaciones sobre datos atípicos y outliers
- Incluir en el EDA una sección dedicada con:
  - Tablas resumen por dataset y columna.
  - Visualizaciones diferenciadas para datos atípicos (naturaleza) vs. outliers (magnitud).
  - Interpretación narrativa de los hallazgos.

---

## 7. Fase 4 — Análisis comparativo entre datasets

### Objetivo
Determinar si los valores que aparecen supuestamente repetidos entre datasets son realmente iguales, o si existen variaciones significativas entre ciudades.

### Especificaciones

#### SDD-013 — Identificación de campos comparables
- Mapear qué columnas son semánticamente equivalentes entre los 6 datasets (p. ej. `price`, `date`, `category`).
- Documentar diferencias en nombres de columna, unidades o escalas antes de comparar.

#### SDD-014 — Comparativa valor a valor
Para cada campo comparable:
- Calcular estadísticos descriptivos por ciudad: media, mediana, desviación típica, percentiles.
- Identificar si los valores de un campo son **prácticamente constantes** en todos los datasets (baja información) o si existen **diferencias significativas** entre ciudades (alta información).
- Señalar qué campos tienen valor analítico comparativo y cuáles son redundantes o no informativos.

#### SDD-015 — Visualizaciones comparativas
- Distribuciones superpuestas por ciudad.
- Matrices de correlación por dataset y comparativa entre datasets.
- Heatmaps de similitud entre ciudades por campo.

---

## 8. Fase 5 — Análisis asistido por IA

### Objetivo
Aprovechar la capacidad de los modelos de lenguaje (p. ej. Claude) para identificar patrones complejos a partir de anomalías detectadas humana o programáticamente, complementando el análisis con código Python en ipynb.

### Niveles de análisis

| Nivel       | Método                        | Alcance                                           |
|-------------|-------------------------------|---------------------------------------------------|
| Humano      | Inspección visual             | Detección superficial de irregularidades obvias  |
| Código simple | Python/ipynb              | Estudios estadísticos básicos, validaciones de tipo, conteos |
| IA          | LLM (p. ej. Claude)           | Detección de patrones sutiles, interpretación contextual, hipótesis sobre anomalías |

### Especificaciones

#### SDD-016 — Protocolo de entrada de datos a IA
- Definir el formato estándar para introducir datasets completos en el LLM:
  - CSV completo (para datasets de tamaño manejable).
  - Muestras representativas + estadísticos descriptivos + mapa de anomalías (para datasets grandes).
- Especificar el **prompt base** para el análisis IA, incluyendo:
  - Contexto del proyecto y las ciudades.
  - Anomalías ya detectadas (input humano o por ipynb).
  - Pregunta o hipótesis específica a investigar.
- Las salidas del análisis IA deben documentarse como observaciones en el EDA, indicando que su origen es asistido.

#### SDD-017 — Iteración humano–IA–código
El flujo de trabajo contempla ciclos iterativos:

```
Detección humana/ipynb → Formulación de hipótesis → Análisis IA → Nueva hipótesis → Validación con código → ...
```

Cada iteración debe quedar registrada en el cuaderno ipynb con celdas de markdown diferenciando origen humano, código y IA.

---

## 9. Fase 6 — Imputación de nulos mediante modelización predictiva

### Objetivo
Para valores nulos o imputables, proponer estimaciones basadas en modelos que identifiquen patrones predictivos a partir de otras características del registro.

### Advertencia
> ⚠️ **Valores semisintéticos:** Los valores imputados por modelo son estimaciones, no datos observados. A partir de esta fase, el dataset contiene **valores semisintéticos**. Esto debe documentarse explícitamente y tenerse en cuenta en cualquier análisis o conclusión posterior.

### Especificaciones

#### SDD-018 — Análisis de imputabilidad
Antes de imputar, evaluar para cada columna con nulos:
- Porcentaje de valores nulos.
- Correlación con otras columnas (¿existen predictores adecuados?).
- Mecanismo de nulidad: MCAR, MAR o MNAR (Missing Completely At Random, At Random, Not At Random).
- Decisión: imputar / eliminar fila / conservar nulo según criterio documentado.

#### SDD-019 — Modelos propuestos para imputación

| Tipo de dato objetivo | Modelos candidatos                                  | Comentarios                                   |
|-----------------------|-----------------------------------------------------|-----------------------------------------------|
| Numérico continuo     | Regresión lineal, KNN Imputer, Random Forest Regressor | KNN adecuado para relaciones no lineales locales |
| Numérico discreto     | KNN Imputer, Random Forest Classifier               | Tratar como clasificación si el rango es reducido |
| Categórico            | Moda condicional, Random Forest Classifier, MICE    | MICE para imputación múltiple                 |
| Temporal (fechas)     | Interpolación lineal, forward/backward fill         | Solo si la serie tiene orden temporal claro   |
| Coordenadas           | Clustering geográfico + mediana del cluster         | Usar solo si hay suficiente contexto espacial |

#### SDD-020 — Evaluación de la imputación
- Separar artificialmente un subconjunto de valores conocidos como ground truth.
- Medir el error de imputación (MAE, RMSE para numéricos; accuracy para categóricos).
- Documentar el modelo seleccionado y su métrica de evaluación en el dataset secundario de descriptores.

#### SDD-021 — Trazabilidad de valores imputados
- Crear una columna binaria auxiliar `*_imputed` (bool) para cada columna con imputaciones.
- Registrar en el dataset de descriptores el modelo y parámetros utilizados.

---

## 10. Fase 7 — EDA final iterativo en ipynb

### Objetivo
Producir un cuaderno ipynb que comunique de forma efectiva los patrones encontrados y haga que las conclusiones emanen naturalmente de la exploración iterada.

### Especificaciones

#### SDD-022 — Estructura del cuaderno EDA final

```
1. Portada y contexto del proyecto
2. Carga y vista rápida de los datasets (head, dtypes, shape)
3. Mapa de anomalías — resumen ejecutivo
4. Homogenización aplicada — registro de transformaciones
5. Análisis univariante por ciudad
6. Análisis bivariante y multivariante
7. Comparativa entre ciudades
8. Datos atípicos y outliers — visualizaciones y narrativa
9. Análisis asistido por IA — hallazgos y hipótesis
10. Imputación de nulos — modelos aplicados y evaluación
11. Patrones y tendencias emergentes
12. Conclusiones y próximos pasos
```

#### SDD-023 — Convenciones de celda
- Toda celda de código con efecto transformador debe ir seguida de una **celda markdown de interpretación** que explique el porqué y el resultado observado.
- Las observaciones de origen IA deben marcarse con la etiqueta `[IA-asistido]`.
- Las hipótesis no confirmadas deben marcarse con `[hipótesis]` hasta su validación.

#### SDD-024 — Iteración del EDA
El EDA se concibe como un proceso iterativo, no lineal:
- Cada iteración puede generar nuevas hipótesis que realimenten fases anteriores.
- El cuaderno debe reflejar este proceso: las conclusiones finales deben ser consecuencia demostrable de los análisis previos, no afirmaciones a priori.

---

## 11. Notas y erratas detectadas

### Errata — "número de bins"
> Se ha identificado el término **"número de bins"** como un posible gazapo en documentación previa del protocolo. Este término hace referencia a un parámetro de histogramas y no corresponde a ninguna especificación acordada en este protocolo. Se recomienda al equipo revisar el contexto en el que aparece y eliminarlo o sustituirlo por la especificación correcta.

---

*Documento generado como borrador SDD para revisión del equipo. No ejecutar ninguna implementación hasta aprobación formal.*
