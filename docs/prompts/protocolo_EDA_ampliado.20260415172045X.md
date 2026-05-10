# Protocolo EDA Ampliado — P8-Data-Analyst
**Fuentes:** Guión v2 + Kanban del equipo  
**Alcance:** Solo fases de Análisis Exploratorio de Datos  
**Nota:** Este documento amplía y reordena el EDA del guión v2 sin reemplazarlo.

---

## Visión general del protocolo

El EDA se estructura en tres niveles de análisis progresivos.  
Cada nivel construye sobre el anterior y alimenta las decisiones de las fases siguientes (limpieza, preprocesado, modelado).

```
Univariante → conocer cada variable por separado
     ↓
Bivariante  → entender cómo se relacionan dos variables
     ↓
Multivariante → detectar patrones en el espacio completo de variables
     ↓
Conclusiones → hipótesis, decisiones de limpieza, señales de riesgo para el modelo
```

> **Conexión EDA → ML (nota importante del equipo):**  
> Los outliers detectados en el EDA no son solo un problema de datos — son un riesgo directo de **overfitting**. Si los boxplots muestran muchos valores atípicos y no se tratan, el modelo tenderá a memorizarlos. El EDA visual es el seguro preventivo contra un overfitting superior al 5%.

---

## BLOQUE 1 — Análisis Univariante (Perfilado de Variables)

> **Objetivo:** Conocer la distribución individual de cada variable antes de relacionarlas.  
> Detectar problemas en la fuente: escalas dispares, sesgos, nulos, clases desbalanceadas.

---

### 1.1 Estadística descriptiva base ✅ (ya en guión v2)

- `df.describe()` → media, mediana, desviación estándar, percentiles
- `df.info()` → tipos de datos y conteo de nulos
- `df.value_counts()` → frecuencias en variables categóricas
- Resumen de nulos por columna con porcentaje

---

### 1.2 Gráfico de Frecuencias — Variable Objetivo 🆕

**¿Qué es?** Un gráfico de barras o countplot sobre la variable que se quiere predecir o que actúa como eje central del análisis. En nuestro caso: `room_type` (tipo de alojamiento) o `city`.

**¿Por qué?** Para verificar si las clases están **balanceadas** o si hay un sesgo importante. Un dataset con 90% de "Entire home/apt" y 10% del resto puede hacer que un modelo aprenda a predecir siempre la clase mayoritaria con alta accuracy aparente pero pésima utilidad real.

**Variables objetivo en nuestro dataset:**
- `room_type` → variable categórica principal (Entire home/apt, Private room, Shared room, Hotel room)
- `city` → segmentación geográfica

**Qué observar:**
- ¿Están las categorías equilibradas o hay dominancia clara?
- ¿Hay categorías con muy pocas observaciones (< 1% del total)?
- ¿Difiere el balance por ciudad?

---

### 1.3 Histogramas y KDE — Variables Numéricas 🆕 (amplía guión v2)

**¿Qué es?** El histograma divide el rango de valores en intervalos y cuenta observaciones. El **KDE (Kernel Density Estimation)** superpone una curva continua suavizada que estima la función de densidad de probabilidad real.

**¿Por qué el KDE además del histograma?** El histograma depende del número de bins elegido — puede ocultar o exagerar patrones. El KDE es independiente de esa elección y muestra la forma real de la distribución con más claridad.

**Qué observar:**
- ¿Distribución normal (campana) o sesgada a la derecha (típico en precios)?
- ¿Hay bimodalidad? (dos picos → puede indicar dos subpoblaciones mezcladas)
- ¿Escalas muy diferentes entre variables? → señal de que el escalado es necesario antes del modelo

**Variables a analizar:**
- `price` → esperamos sesgo derecho fuerte
- `minimum_nights` → posible distribución muy concentrada con cola larga
- `number_of_reviews` → distribución tipo Pareto (pocos con muchas, muchos con pocas)
- `reviews_per_month` → ídem

---

### 1.4 Boxplots Individuales ✅ (ya en guión v2, ampliado)

**¿Qué es?** Resumen visual de Q1, mediana, Q3 y bigotes (±1.5×IQR). Los puntos fuera de los bigotes son outliers.

**¿Por qué individualmente antes que agrupados?** El boxplot individual permite cuantificar el problema de outliers en cada variable de forma aislada, antes de introducir el factor grupo. Es el diagnóstico previo a la decisión de tratamiento.

**Qué documentar por variable:**
- Número y porcentaje de outliers
- Si los outliers son simétricos o unilaterales (solo por arriba → sesgo derecho)
- Decisión tomada: eliminar / imputar / mantener con justificación

---

## BLOQUE 2 — Análisis Bivariante (Capacidad de Discriminación)

> **Objetivo:** Entender cómo se relacionan dos variables entre sí, y especialmente cómo cada variable numérica se comporta según las categorías clave.  
> Esta es la fase donde se identifica qué variables tienen **poder discriminante** — es decir, cuáles separan bien los grupos.

---

### 2.1 Boxplot Agrupado (Comparativo) 🆕

**¿Qué es?** Un boxplot por cada categoría de una variable objetivo, para una variable numérica. Por ejemplo: distribución de `price` separada por `room_type`.

**¿Por qué?** Si las cajas de dos categorías **no se solapan**, esa variable numérica es un excelente predictor de la categoría. Si se solapan totalmente, la variable aporta poco poder discriminante.

**Combinaciones relevantes en nuestro dataset:**
- `price` por `room_type` → ¿difieren los precios según tipo de alojamiento?
- `price` por `city` → ¿hay ciudades sistemáticamente más caras?
- `number_of_reviews` por `room_type` → ¿los alojamientos completos tienen más reviews?
- `minimum_nights` por `city` → ¿hay diferencias en la política de noches mínimas?

**Qué observar:**
- Solapamiento entre cajas (mucho solapamiento = variable poco discriminante)
- Outliers en cada grupo por separado
- Diferencias en la mediana entre grupos

---

### 2.2 KDE Plot Superpuesto por Categoría 🆕

**¿Qué es?** Varias curvas KDE en el mismo gráfico, una por categoría, con transparencia para ver solapamiento.

**¿Por qué?** Complementa el boxplot agrupado mostrando la **forma completa** de la distribución por grupo, no solo sus estadísticos resumidos. Permite ver si la diferencia entre grupos es de media, de forma, de varianza, o de todo.

**Ejemplo de lectura:** Si la curva KDE de `price` para "Entire home/apt" está desplazada claramente a la derecha respecto a "Private room", esa variable tiene alta capacidad discriminante. Si las curvas se superponen casi completamente, la variable no ayudará al modelo a distinguir entre tipos.

---

### 2.3 Scatter Plot con Color por Categoría 🆕

**¿Qué es?** Gráfico de dispersión con dos variables numéricas en los ejes, coloreando cada punto según su categoría.

**¿Por qué?** Permite ver si los grupos son **linealmente separables** en el espacio de dos variables. Si los colores forman clusters visualmente distinguibles, un modelo simple (regresión logística, SVM lineal) podría funcionar bien. Si los colores se mezclan aleatoriamente, se necesitan modelos más complejos o más variables.

**Combinaciones relevantes:**
- `price` vs. `number_of_reviews`, color = `room_type`
- `price` vs. `minimum_nights`, color = `city`
- `latitude` vs. `longitude`, color = `room_type` → distribución geográfica por tipo

---

## BLOQUE 3 — Análisis Multivariante (Reducción de Ruido y Redundancias)

> **Objetivo:** Detectar redundancias entre predictores (multicolinealidad) y entender interacciones complejas entre múltiples variables simultáneamente.

---

### 3.1 Heatmap de Correlación ✅ (ya en guión v2, ampliado)

**¿Qué es?** Matriz cuadrada donde cada celda muestra la correlación entre dos variables (Pearson para numéricas). Codificada en color: rojo = correlación positiva, azul = negativa, blanco = sin correlación.

**¿Por qué es fundamental?** Detecta **multicolinealidad**: si dos variables están altamente correlacionadas (|r| > 0.85), aportan información casi idéntica. Incluir ambas en un modelo puede hacerlo **inestable** (los coeficientes se vuelven poco fiables) y añade ruido sin añadir información.

**Qué observar:**
- Pares con |r| > 0.7 → candidatos a eliminar uno de los dos
- Correlación de cada variable con `price` → ranking de relevancia para el modelo
- ¿Hay variables con correlación cercana a 0 con todo? → pueden ser poco útiles

---

### 3.2 Pair Plot (Matriz de Dispersión) ✅ (ya en guión v2, ampliado)

**¿Qué es?** Cuadrícula de scatter plots para todas las combinaciones posibles de variables numéricas. La diagonal muestra la distribución de cada variable individual (histograma o KDE).

**¿Por qué?** Es la "foto de satélite" del dataset: permite ver de un vistazo qué combinaciones de variables **separan mejor los grupos**. Identifica relaciones no lineales que el heatmap (que solo mide correlación lineal) no detecta.

**Uso práctico:** Con datasets grandes, ejecutar sobre una muestra (3.000-5.000 filas) y colorear por `room_type` o `city`. Buscar pares de variables donde los colores forman clusters distinguibles.

---

### 3.3 Gráfico de Coordenadas Paralelas 🆕 (opcional)

**¿Qué es?** Cada variable numérica es un eje vertical. Cada observación es una línea que "viaja" de izquierda a derecha pasando por el valor que toma en cada eje. Las líneas se colorean por categoría.

**¿Por qué?** Muy útil cuando hay muchas variables numéricas (más de 4-5) y el pair plot se vuelve demasiado denso. Permite ver cómo se comporta cada categoría a través de **todas las dimensiones simultáneamente**. Si las líneas de una categoría siguen un patrón diferente al de otra, esa diferencia es una señal para el modelo.

**Cuándo usarlo en nuestro proyecto:** Si al explorar los `.xlsx` de Madrid, Londres y Milán aparecen más columnas numéricas que los CSV históricos. Es el complemento natural al pair plot para datasets con muchas variables.

---

## BLOQUE 4 — Conclusiones y Conexión con Fases Siguientes

> **Objetivo:** Documentar los hallazgos del EDA de forma que guíen las decisiones de limpieza, preprocesado y modelado.  
> Este bloque es obligatorio en el notebook — sin él el EDA no está completo.

### 4.1 Checklist de hallazgos a documentar

- [ ] Balance de clases en `room_type` y `city`: ¿hay sesgo?
- [ ] Variables con distribución muy sesgada que requieren transformación (log, sqrt)
- [ ] Variables con outliers que requieren tratamiento → decisión documentada
- [ ] Pares de variables con alta correlación → candidatos a eliminar
- [ ] Variables con mejor poder discriminante según boxplots agrupados y KDE superpuesto
- [ ] Combinaciones de variables visualmente separables en scatter plots → candidatos para el modelo

### 4.2 Señales de riesgo para el modelo (conexión EDA → ML)

| Señal detectada en EDA | Riesgo en ML | Acción preventiva |
|---|---|---|
| Muchos outliers sin tratar | Overfitting > 5% | Tratar outliers antes de entrenar |
| Clases muy desbalanceadas | Accuracy alta pero modelo inútil | Oversampling (SMOTE) o class_weight |
| Alta multicolinealidad | Modelo inestable | Eliminar una de las variables redundantes |
| Escalas muy dispares | Variables de mayor escala dominan | Escalado MinMax o StandardScaler |
| Distribuciones muy sesgadas | Algunos modelos asumen normalidad | Transformación log o sqrt |

### 4.3 Hipótesis a validar en fases siguientes

Formular aquí las hipótesis generadas por el EDA, antes de ejecutar tests estadísticos:

```
H1: El precio medio difiere significativamente entre ciudades
H2: Los alojamientos con más reviews tienen precios más bajos
H3: El tipo de alojamiento es el predictor más importante del precio
H4: Las variables del dataset de Tokio (sin availability_365) son suficientes para clustering
```

---

## Resumen del protocolo completo

| Bloque | Análisis | Herramienta | Estado |
|---|---|---|---|
| 1.1 | Estadística descriptiva | `describe()`, `info()`, `value_counts()` | ✅ en guión v2 |
| 1.2 | Frecuencias variable objetivo | `countplot` por `room_type` / `city` | 🆕 añadir |
| 1.3 | Histogramas + KDE por variable | `histplot` + `kdeplot` | 🆕 ampliar |
| 1.4 | Boxplots individuales + IQR | `boxplot` + función IQR | ✅ en guión v2 |
| 2.1 | Boxplot agrupado por categoría | `boxplot(x=categoría, y=numérica)` | 🆕 añadir |
| 2.2 | KDE superpuesto por categoría | `kdeplot(hue=categoría)` | 🆕 añadir |
| 2.3 | Scatter plot con color | `scatterplot(hue=categoría)` | 🆕 añadir |
| 3.1 | Heatmap de correlación | `heatmap(corr())` | ✅ en guión v2 |
| 3.2 | Pair plot | `pairplot(hue=categoría)` | ✅ en guión v2 |
| 3.3 | Coordenadas paralelas | `parallel_coordinates` (Plotly) | 🆕 opcional |
| 4.x | Conclusiones y señales de riesgo | Celdas Markdown + tabla | 🆕 añadir |

---

*Protocolo para uso interno del equipo. Pendiente de implementación en notebook `01_eda_airbnb.ipynb`.*
