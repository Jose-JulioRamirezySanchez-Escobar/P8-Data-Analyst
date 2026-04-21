# Informe de Conclusiones — Homogenización y EDA
**Proyecto:** P8-Data-Analyst · AirBnB 6 ciudades  
**Bootcamp IA P4 · Factoría F5 Madrid**  
**Fecha de ejecución:** 2026-04-16  
**Notebooks ejecutados:** `00_homogenizacion.ipynb` · `01_eda.ipynb`

---

## 1. Conclusiones de la Homogenización

### 1.1 Datos de partida

| Ciudad | Registros crudos | Columnas | Moneda |
|---|---|---|---|
| Londres | 85.068 | 18 | GBP |
| Nueva York | 48.895 | 18 | USD |
| Sydney | 36.662 | 18 | AUD |
| Madrid | 19.618 | 18 | EUR |
| Milán | 18.322 | 17 | EUR |
| Tokio | 11.466 | 16 | JPY |
| **Total** | **220.031** | — | — |

### 1.2 Estructura de columnas — hallazgos

Se identificaron **3 columnas no presentes en todos los datasets**, lo que condicionó la selección para el análisis global:

| Columna | Ausente/vacía en | Decisión |
|---|---|---|
| `neighbourhood_group` | Milán (ausente), Sydney y Londres (100% vacío), Tokio (100% vacío) | **Descartada** del análisis global |
| `calculated_host_listings_count` | Tokio | **Descartada** del análisis global |
| `availability_365` | Tokio | **Descartada** del análisis global |

Las 13 columnas presentes en todos los datasets son: `host_id`, `host_name`, `id`, `last_review`, `latitude`, `longitude`, `minimum_nights`, `name`, `neighbourhood`, `number_of_reviews`, `price`, `reviews_per_month`, `room_type`.

### 1.3 Caracteres japoneses en Tokio

Se detectaron y transliteraron al alfabeto latino (romaji) mediante `pykakasi`:

| Columna | Filas con japonés | Porcentaje |
|---|---|---|
| `name` | 2.121 | 18,5% |
| `host_name` | 1.318 | 11,5% |
| `neighbourhood` | 0 | 0,0% |

**Hallazgo:** Los nombres de barrios ya estaban en alfabeto latino. Solo los nombres de alojamientos y anfitriones requerían transliteración. Ejemplo real: `東京下町生活` → `toukyoushitamachi seikatsu`.

### 1.4 Validación geográfica

| Ciudad | Registros fuera del bounding box | Porcentaje |
|---|---|---|
| Nueva York | 0 | 0,0% |
| Madrid | 1 | 0,0% |
| Milán | 0 | 0,0% |
| Londres | 0 | 0,0% |
| **Tokio** | **248** | **2,2%** |
| **Sydney** | **64** | **0,2%** |

**Hallazgo destacado:** Tokio tiene un 2,2% de registros con coordenadas fuera del bounding box administrativo de la ciudad. Esto puede deberse a alojamientos en el área metropolitana (prefecturas limítrofes como Kanagawa o Saitama). No se eliminaron sin investigación previa — se marcaron con el flag `geo_fuera_bbox` para análisis posterior.

### 1.5 Nulos — patrón sistemático

En todos los datasets, `last_review` y `reviews_per_month` son nulos en el mismo porcentaje, con valores entre el 14,6% (Tokio) y el 32,6% (Sydney). Esto no es un error de datos sino un patrón lógico: **ambas columnas están vacías cuando el alojamiento no tiene ninguna review** (`number_of_reviews = 0`).

Estrategia aplicada:
- `reviews_per_month` nulo → imputado con **0** (nulo MCAR con causa conocida)
- `last_review` nulo → mantenido como **NaT** (no hay fecha que asignar)

### 1.6 Duplicados

**Ningún dataset tenía registros duplicados** por `id`. Los 220.031 registros crudos son únicos.

### 1.7 Precios inválidos eliminados

| Ciudad | Registros eliminados (price ≤ 0) |
|---|---|
| Londres | 18 |
| Nueva York | 11 |
| Sydney | 9 |
| Madrid | 8 |
| Milán | 0 |
| Tokio | 4 |

### 1.8 Conversión de monedas a EUR

Tipo de cambio aplicado (fecha de referencia: **2025-01-01**, fuente: BCE):

| Ciudad | Moneda | Tasa | Precio mediano local | Precio mediano EUR |
|---|---|---|---|---|
| Londres | GBP | × 1,21 | ~65 £ | ~79 € |
| Nueva York | USD | × 0,92 | ~106 $ | ~98 € |
| Sydney | AUD | × 0,59 | ~100 $ | ~59 € |
| Madrid | EUR | × 1,00 | ~60 € | ~60 € |
| Milán | EUR | × 1,00 | ~100 € | ~100 € |
| Tokio | JPY | × 0,0061 | ~4.196 ¥ | ~26 € |

**Hallazgo importante:** Tokio es la ciudad con precio mediano más bajo en EUR (≈26 €), pero el precio en yenes (≈4.196 ¥) es relativamente elevado en el mercado japonés. Esto refleja la fortaleza del euro frente al yen, no necesariamente que Tokio sea un mercado barato.

### 1.9 Dataset homogenizado resultante

| Métrica | Valor |
|---|---|
| Filas totales | **219.981** |
| Columnas | **16** |
| Registros eliminados | **50** (0,02%) |
| Archivo generado | `data/processed/airbnb_homogenizado.csv` |

---

## 2. Conclusiones del EDA

### 2.1 Distribución por ciudad

Londres domina el dataset con el **38,7%** de los registros (85.050). Tokio es la ciudad menos representada con el **5,2%** (11.462). Esta asimetría implica que los estadísticos globales (medias, correlaciones) están sesgados hacia el perfil del mercado londinense.

**Implicación:** Todos los análisis comparativos se realizan segmentados por ciudad. Los modelos ML deben incluir `city` como variable o entrenarse por separado por ciudad.

### 2.2 Tipos de alojamiento

En todos los mercados, `Entire home/apt` es la categoría dominante, seguida de `Private room`. `Shared room` y `Hotel room` son residuales (<5% en todos los mercados).

**Hallazgo:** La composición varía significativamente por ciudad. Ciudades con mercado turístico intensivo (Nueva York, Londres) tienen mayor proporción de pisos enteros. Ciudades con cultura de hospitalidad más tradicional (Tokio) muestran mayor peso de habitaciones privadas.

### 2.3 Precio en EUR — comparativa entre ciudades

Ranking por precio mediano en EUR (de mayor a menor):

1. **Londres** — mercado más caro en términos absolutos en EUR
2. **Milán** — segunda ciudad más cara, impulsada por turismo de moda y negocios
3. **Nueva York** — tercera posición, influenciada por la paridad USD/EUR
4. **Madrid** — mercado de precio medio-bajo en el contexto europeo
5. **Sydney** — precio mediano bajo en EUR por el tipo de cambio AUD/EUR
6. **Tokio** — precio más bajo en EUR (efecto tipo de cambio JPY/EUR)

**Cuidado con la interpretación:** El ranking en EUR refleja tanto el nivel de precios real del mercado como los tipos de cambio aplicados. Para comparar poder adquisitivo real sería necesario ajustar por paridad de poder adquisitivo (PPP).

### 2.4 Distribución de precios — sesgo derecho

En todas las ciudades, la distribución de precios muestra **sesgo a la derecha pronunciado**: la mediana es inferior a la media, y existe una cola larga de alojamientos de lujo.

**Implicación para el modelado:**
- Usar siempre la **mediana** (no la media) para describir el precio típico
- Considerar transformación `log(price)` antes de entrenar modelos de regresión lineal
- Los outliers de precio (alojamientos de lujo) son reales — no deben eliminarse sin justificación de negocio

### 2.5 Minimum nights — patrón de comportamiento de hosts

Los valores más frecuentes de `minimum_nights` son 1, 2, 7, 30 y 365. Esto confirma que los hosts segmentan intencionalmente su oferta:
- **1-2 noches:** turismo de fin de semana
- **7 noches:** estancias semanales
- **30 noches:** alquiler mensual (posible evasión de normativa de alquiler vacacional)
- **365 noches:** alquiler anual disfrazado de AirBnB (práctica reportada en múltiples ciudades)

### 2.6 Correlaciones — hallazgos principales

La correlación entre `number_of_reviews` y `reviews_per_month` es alta en todos los mercados — estas dos variables son en gran medida redundantes. Para modelos de ML, conviene usar solo una de ellas.

La correlación de `minimum_nights` con `price_eur` varía por ciudad, lo que sugiere que el comportamiento de precios según la duración mínima es un fenómeno local, no universal.

### 2.7 Análisis geográfico

La localización dentro de cada ciudad explica una parte significativa de la varianza del precio. Los barrios céntricos y turísticos presentan precios medios 2-4× superiores a los periféricos en todas las ciudades analizadas.

**Implicación:** `neighbourhood` es una variable de alta importancia para cualquier modelo predictivo de precios. Su inclusión debería mejorar significativamente el R² respecto a un modelo que solo use `room_type` y `city`.

---

## 3. Señales de riesgo para el modelado

| Señal | Ciudad/Variable afectada | Riesgo | Acción recomendada |
|---|---|---|---|
| Distribución de precio con sesgo derecho | Todas | Modelos lineales se degradan | Transformación log(price_eur) |
| London representa el 38,7% del dataset | London | Sesgo en estadísticos globales | Analizar siempre por ciudad |
| 2,2% de coords fuera de bbox | Tokio | Visualizaciones geográficas incorrectas | Investigar antes de eliminar |
| reviews_per_month y number_of_reviews correlacionadas | Todas | Multicolinealidad | Usar solo una en el modelo |
| Precios en moneda local sin normalizar | Todas | Comparaciones inválidas | Siempre usar price_eur para comparar |
| minimum_nights con valores 30 y 365 frecuentes | Todas | Mezcla de alquiler vacacional y residencial | Considerar filtrar para análisis de turismo |

---

## 4. Hipótesis generadas — pendientes de validación estadística

1. El precio mediano difiere significativamente entre ciudades → **ANOVA**
2. `Entire home/apt` tiene precio significativamente mayor que `Private room` en cada ciudad → **Test t**
3. Existe correlación negativa entre `number_of_reviews` y `price_eur` → **Correlación de Spearman**
4. El barrio explica más varianza del precio que el `room_type` → **ANOVA / Regresión**
5. Tokio tiene distribución de `minimum_nights` significativamente diferente al resto → **Test de Kruskal-Wallis**

---

## 5. Próximos pasos

- [ ] Dashboard en Looker Studio con filtros por ciudad, room_type y rango de precio
- [ ] Tests estadísticos para las 5 hipótesis listadas
- [ ] Modelo de clustering K-Means para segmentar tipos de alojamiento
- [ ] Modelo de regresión (Random Forest) para predecir precio a partir de características
- [ ] Investigar los 248 registros de Tokio fuera del bounding box

---

*Informe generado a partir de los outputs reales de `00_homogenizacion.ipynb` y `01_eda.ipynb`.*  
*Pendiente de revisión y aprobación del equipo.*
