### Celda 1 — Markdown

# 00b — Comparación CSV vs XLSX · P8-Data-Analyst

**Objetivo:** Determinar si los archivos `.xlsx` aportan datos nuevos respecto a los `.csv` de la misma ciudad,
o si son actualizaciones parciales/completas del mismo dataset.

**Hipótesis:** Los datasets de Inside AirBnB son snapshots temporales. Un xlsx más reciente que su CSV
equivalente contendrá registros nuevos (alojamientos dados de alta), habrá perdido registros antiguos
(dados de baja) y puede haber registros comunes con valores actualizados (precio, disponibilidad).

**Ciudades a comparar:**
- Madrid: `madrid_airbnb.csv` (2021-05) vs `madrid_airbnb.xlsx` (2026-01)
- Londres: `london_airbnb.csv` (2022-08) vs `london_airbnb.xlsx` (2024-10-24) vs `london_airbnb(1).xlsx` (2024-10-11)
- Milán: `milan_airbnb.csv` (2021-08) vs `milan_airbnb.xlsx` (2024-10)

**Ciudades sin xlsx:** NY, Sydney, Tokyo → solo existe una versión.


### Celda 2 — Código [In 1]

```python
import pandas as pd
import numpy as np
import requests
from io import BytesIO
import warnings
warnings.filterwarnings('ignore')

BASE = 'https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/'

def load_csv(nombre):
    return pd.read_csv(BASE + nombre, low_memory=False)

def load_xlsx(nombre):
    r = requests.get(BASE + nombre)
    r.raise_for_status()
    return pd.read_excel(BytesIO(r.content), engine='openpyxl')

print('✅ Funciones de carga listas')
```

**Output Celda 2:**

```
✅ Funciones de carga listas
```


### Celda 3 — Código [In 2]

```python
# SDD: Cargar todos los datasets con ciudad y versión etiquetadas
print('Cargando datasets...')

datasets = {
    # (ciudad, version, formato, fecha_snapshot)
    'madrid_csv':    {'df': load_csv('madrid_airbnb.csv'),     'ciudad': 'Madrid',  'fecha': '2021-05'},
    'madrid_xlsx':   {'df': load_xlsx('madrid_airbnb.xlsx'),   'ciudad': 'Madrid',  'fecha': '2026-01'},
    'london_csv':    {'df': load_csv('london_airbnb.csv'),     'ciudad': 'London',  'fecha': '2022-08'},
    'london_xlsx':   {'df': load_xlsx('london_airbnb.xlsx'),   'ciudad': 'London',  'fecha': '2024-10-24'},
    'london_xlsx1':  {'df': load_xlsx('london_airbnb(1).xlsx'),'ciudad': 'London',  'fecha': '2024-10-11'},
    'milan_csv':     {'df': load_csv('milan_airbnb.csv'),      'ciudad': 'Milan',   'fecha': '2021-08'},
    'milan_xlsx':    {'df': load_xlsx('milan_airbnb.xlsx'),    'ciudad': 'Milan',   'fecha': '2024-10'},
    # Solo CSV — sin comparación xlsx
    'ny_csv':        {'df': load_csv('NY_airbnb.csv'),         'ciudad': 'New York','fecha': '2019-10'},
    'sydney_csv':    {'df': load_csv('sydney_airbnb.csv'),     'ciudad': 'Sydney',  'fecha': '2019-11'},
    'tokyo_csv':     {'df': load_csv('tokyo_airbnb.csv'),      'ciudad': 'Tokyo',   'fecha': '2019-09'},
}

for key, meta in datasets.items():
    df = meta['df']
    print(f"  {key:15} → {df.shape[0]:>6,} filas × {df.shape[1]:>2} cols | "
          f"cols: {list(df.columns)}")
```

**Output Celda 3:**

```
Cargando datasets...
  madrid_csv      → 19,618 filas × 16 cols | cols: ['id', 'name', 'host_id', 'host_name', 'neighbourhood_group', 'neighbourhood', 'latitude', 'longitude', 'room_type', 'price', 'minimum_nights', 'number_of_reviews', 'last_review', 'reviews_per_month', 'calculated_host_listings_count', 'availability_365']
  madrid_xlsx     → 19,618 filas × 16 cols | cols: ['id', 'name', 'host_id', 'host_name', 'neighbourhood_group', 'neighbourhood', 'latitude', 'longitude', 'room_type', 'price', 'minimum_nights', 'number_of_reviews', 'last_review', 'reviews_per_month', 'calculated_host_listings_count', 'availability_365']
  london_csv      → 85,068 filas × 16 cols | cols: ['id', 'name', 'host_id', 'host_name', 'neighbourhood_group', 'neighbourhood', 'latitude', 'longitude', 'room_type', 'price', 'minimum_nights', 'number_of_reviews', 'last_review', 'reviews_per_month', 'calculated_host_listings_count', 'availability_365']
  london_xlsx     → 85,068 filas × 16 cols | cols: ['id', 'name', 'host_id', 'host_name', 'neighbourhood_group', 'neighbourhood', 'latitude', 'longitude', 'room_type', 'price', 'minimum_nights', 'number_of_reviews', 'last_review', 'reviews_per_month', 'calculated_host_listings_count', 'availability_365']
  london_xlsx1    → 85,068 filas × 16 cols | cols: ['id', 'name', 'host_id', 'host_name', 'neighbourhood_group', 'neighbourhood', 'latitude', 'longitude', 'room_type', 'price', 'minimum_nights', 'number_of_reviews', 'last_review', 'reviews_per_month', 'calculated_host_listings_count', 'availability_365']
  milan_csv       → 18,322 filas × 15 cols | cols: ['id', 'name', 'host_id', 'host_name', 'neighbourhood', 'latitude', 'longitude', 'room_type', 'price', 'minimum_nights', 'number_of_reviews', 'last_review', 'reviews_per_month', 'calculated_host_listings_count', 'availability_365']
  milan_xlsx      → 18,322 filas × 15 cols | cols: ['id', 'name', 'host_id', 'host_name', 'neighbourhood', 'latitude', 'longitude', 'room_type', 'price', 'minimum_nights', 'number_of_reviews', 'last_review', 'reviews_per_month', 'calculated_host_listings_count', 'availability_365']
  ny_csv          → 48,895 filas × 16 cols | cols: ['id', 'name', 'host_id', 'host_name', 'neighbourhood_group', 'neighbourhood', 'latitude', 'longitude', 'room_type', 'price', 'minimum_nights', 'number_of_reviews', 'last_review', 'reviews_per_month', 'calculated_host_listings_count', 'availability_365']
  sydney_csv      → 36,662 filas × 16 cols | cols: ['id', 'name', 'host_id', 'host_name', 'neighbourhood_group', 'neighbourhood', 'latitude', 'longitude', 'room_type', 'price', 'minimum_nights', 'number_of_reviews', 'last_review', 'reviews_per_month', 'calculated_host_listings_count', 'availability_365']
  tokyo_csv       → 11,466 filas × 14 cols | cols: ['id', 'name', 'host_id', 'host_name', 'neighbourhood_group', 'neighbourhood', 'latitude', 'longitude', 'room_type', 'price', 'minimum_nights', 'number_of_reviews', 'last_review', 'reviews_per_month']
```


### Celda 4 — Markdown

## 1. Estructura — columnas por archivo

Antes de comparar registros, comparamos estructura. Si las columnas difieren entre CSV y XLSX,
la versión más reciente puede haber añadido o eliminado campos.


### Celda 5 — Código [In 3]

```python
# SDD: Comparación de columnas CSV vs XLSX por ciudad
pares = [
    ('madrid_csv',   'madrid_xlsx',  'Madrid'),
    ('london_csv',   'london_xlsx',  'London CSV vs XLSX'),
    ('london_xlsx1', 'london_xlsx',  'London XLSX(1) vs XLSX'),
    ('milan_csv',    'milan_xlsx',   'Milan'),
]

print('=== COMPARACIÓN DE COLUMNAS ===\n')
for key_a, key_b, nombre in pares:
    cols_a = set(datasets[key_a]['df'].columns)
    cols_b = set(datasets[key_b]['df'].columns)
    solo_a = cols_a - cols_b
    solo_b = cols_b - cols_a
    comunes = cols_a & cols_b
    fecha_a = datasets[key_a]['fecha']
    fecha_b = datasets[key_b]['fecha']
    print(f'--- {nombre} ---')
    print(f'  {key_a} ({fecha_a}): {len(cols_a)} columnas')
    print(f'  {key_b} ({fecha_b}): {len(cols_b)} columnas')
    print(f'  Comunes: {len(comunes)}')
    if solo_a: print(f'  Solo en {key_a}: {solo_a}')
    if solo_b: print(f'  Solo en {key_b}: {solo_b}')
    print()
```

**Output Celda 5:**

```
=== COMPARACIÓN DE COLUMNAS ===

--- Madrid ---
  madrid_csv (2021-05): 16 columnas
  madrid_xlsx (2026-01): 16 columnas
  Comunes: 16

--- London CSV vs XLSX ---
  london_csv (2022-08): 16 columnas
  london_xlsx (2024-10-24): 16 columnas
  Comunes: 16

--- London XLSX(1) vs XLSX ---
  london_xlsx1 (2024-10-11): 16 columnas
  london_xlsx (2024-10-24): 16 columnas
  Comunes: 16

--- Milan ---
  milan_csv (2021-08): 15 columnas
  milan_xlsx (2024-10): 15 columnas
  Comunes: 15
```


### Celda 6 — Markdown

## 2. Solapamiento de IDs — ¿cuántos alojamientos persisten entre versiones?

El campo `id` identifica unívocamente cada alojamiento. Comparando los sets de IDs entre versiones
obtenemos:
- **IDs solo en el CSV antiguo:** alojamientos que desaparecieron del mercado
- **IDs solo en el XLSX nuevo:** alojamientos nuevos dados de alta
- **IDs en ambos:** alojamientos que persisten — pueden tener valores actualizados


### Celda 7 — Código [In 4]

```python
# SDD: Solapamiento de IDs por ciudad
print('=== SOLAPAMIENTO DE IDs ===\n')

resultados_ids = {}
for key_a, key_b, nombre in pares:
    df_a = datasets[key_a]['df']
    df_b = datasets[key_b]['df']
    fecha_a = datasets[key_a]['fecha']
    fecha_b = datasets[key_b]['fecha']

    if 'id' not in df_a.columns or 'id' not in df_b.columns:
        print(f'  {nombre}: columna id no encontrada')
        continue

    ids_a = set(df_a['id'].astype(str))
    ids_b = set(df_b['id'].astype(str))
    solo_a = ids_a - ids_b    # desaparecidos
    solo_b = ids_b - ids_a    # nuevos
    comunes = ids_a & ids_b   # persisten

    resultados_ids[nombre] = {
        'total_a': len(ids_a), 'total_b': len(ids_b),
        'nuevos': len(solo_b), 'desaparecidos': len(solo_a),
        'comunes': len(comunes), 'ids_comunes': comunes
    }

    pct_nuevos = len(solo_b)/len(ids_b)*100
    pct_desap  = len(solo_a)/len(ids_a)*100
    pct_comun  = len(comunes)/max(len(ids_a),len(ids_b))*100

    print(f'--- {nombre} ---')
    print(f'  {key_a} ({fecha_a}): {len(ids_a):,} IDs únicos')
    print(f'  {key_b} ({fecha_b}): {len(ids_b):,} IDs únicos')
    print(f'  IDs comunes (persisten):    {len(comunes):>6,} ({pct_comun:.1f}%)')
    print(f'  IDs solo en CSV (desapar.): {len(solo_a):>6,} ({pct_desap:.1f}%)')
    print(f'  IDs solo en XLSX (nuevos):  {len(solo_b):>6,} ({pct_nuevos:.1f}%)')
    print()
```

**Output Celda 7:**

```
=== SOLAPAMIENTO DE IDs ===

--- Madrid ---
  madrid_csv (2021-05): 19,618 IDs únicos
  madrid_xlsx (2026-01): 19,618 IDs únicos
  IDs comunes (persisten):    19,618 (100.0%)
  IDs solo en CSV (desapar.):      0 (0.0%)
  IDs solo en XLSX (nuevos):       0 (0.0%)

--- London CSV vs XLSX ---
  london_csv (2022-08): 85,068 IDs únicos
  london_xlsx (2024-10-24): 85,068 IDs únicos
  IDs comunes (persisten):    85,068 (100.0%)
  IDs solo en CSV (desapar.):      0 (0.0%)
  IDs solo en XLSX (nuevos):       0 (0.0%)

--- London XLSX(1) vs XLSX ---
  london_xlsx1 (2024-10-11): 85,068 IDs únicos
  london_xlsx (2024-10-24): 85,068 IDs únicos
  IDs comunes (persisten):    85,068 (100.0%)
  IDs solo en CSV (desapar.):      0 (0.0%)
  IDs solo en XLSX (nuevos):       0 (0.0%)

--- Milan ---
  milan_csv (2021-08): 18,322 IDs únicos
  milan_xlsx (2024-10): 18,322 IDs únicos
  IDs comunes (persisten):    18,322 (100.0%)
  IDs solo en CSV (desapar.):      0 (0.0%)
  IDs solo en XLSX (nuevos):       0 (0.0%)
```


### Celda 8 — Markdown

## 3. Cambios en valores para IDs comunes

Para los alojamientos que existen en ambas versiones, ¿han cambiado sus valores?
Las columnas más relevantes para detectar cambios son: `price`, `minimum_nights`,
`availability_365`, `room_type`.


### Celda 9 — Código [In 5]

```python
# SDD: Análisis de cambios en valores para IDs comunes
COLS_SEGUIMIENTO = ['price', 'minimum_nights', 'room_type']
# availability_365 solo si existe en ambos

print('=== CAMBIOS EN VALORES PARA IDs COMUNES ===\n')

for key_a, key_b, nombre in pares:
    if nombre not in resultados_ids:
        continue
    res = resultados_ids[nombre]
    if res['comunes'] == 0:
        print(f'{nombre}: sin IDs comunes — no hay cambios que analizar\n')
        continue

    df_a = datasets[key_a]['df'].copy()
    df_b = datasets[key_b]['df'].copy()
    df_a['id'] = df_a['id'].astype(str)
    df_b['id'] = df_b['id'].astype(str)

    ids_c = res['ids_comunes']
    sub_a = df_a[df_a['id'].isin(ids_c)].set_index('id')
    sub_b = df_b[df_b['id'].isin(ids_c)].set_index('id')

    print(f'--- {nombre} ({res["comunes"]:,} IDs comunes) ---')
    cols_check = [c for c in COLS_SEGUIMIENTO if c in sub_a.columns and c in sub_b.columns]
    if 'availability_365' in sub_a.columns and 'availability_365' in sub_b.columns:
        cols_check.append('availability_365')

    for col in cols_check:
        try:
            diff = (sub_a[col] != sub_b[col]).sum()
            pct = diff / res['comunes'] * 100
            print(f'  {col:35}: {diff:>6,} cambios ({pct:.1f}%)')
        except Exception as e:
            print(f'  {col}: no comparable — {e}')
    print()
```

**Output Celda 9:**

```
=== CAMBIOS EN VALORES PARA IDs COMUNES ===

--- Madrid (19,618 IDs comunes) ---
  price                              :      0 cambios (0.0%)
  minimum_nights                     :      0 cambios (0.0%)
  room_type                          :      0 cambios (0.0%)
  availability_365                   :      0 cambios (0.0%)

--- London CSV vs XLSX (85,068 IDs comunes) ---
  price: no comparable — Can only compare identically-labeled Series objects
  minimum_nights: no comparable — Can only compare identically-labeled Series objects
  room_type: no comparable — Can only compare identically-labeled Series objects
  availability_365: no comparable — Can only compare identically-labeled Series objects

--- London XLSX(1) vs XLSX (85,068 IDs comunes) ---
  price: no comparable — Can only compare identically-labeled Series objects
  minimum_nights: no comparable — Can only compare identically-labeled Series objects
  room_type: no comparable — Can only compare identically-labeled Series objects
  availability_365: no comparable — Can only compare identically-labeled Series objects

--- Milan (18,322 IDs comunes) ---
  price                              :      0 cambios (0.0%)
  minimum_nights                     :      0 cambios (0.0%)
  room_type                          :      0 cambios (0.0%)
  availability_365                   :      0 cambios (0.0%)
```


### Celda 10 — Markdown

## 4. Resumen ejecutivo — ¿qué aporta cada XLSX?

Interpretación de los resultados para tomar decisiones sobre qué versión usar.


### Celda 11 — Código [In 6]

```python
# SDD: Resumen ejecutivo para el catálogo de datasets
print('=== RESUMEN EJECUTIVO ===\n')
print('Criterio de interpretación:')
print('  >80% IDs nuevos  → XLSX es una actualización mayor, aporta datos muy distintos')
print('  30-80% IDs nuevos → XLSX es una actualización parcial')
print('  <30% IDs nuevos  → XLSX es principalmente el mismo dataset con pequeños cambios')
print()

for nombre, res in resultados_ids.items():
    pct_nuevos = res['nuevos'] / res['total_b'] * 100 if res['total_b'] > 0 else 0
    if pct_nuevos > 80:
        tipo = '🔴 Actualización MAYOR — datasets muy distintos'
    elif pct_nuevos > 30:
        tipo = '🟡 Actualización PARCIAL — mezcla de datos nuevos y existentes'
    else:
        tipo = '🟢 Actualización MENOR — mayoría de datos coinciden'

    print(f'{nombre}')
    print(f'  {tipo}')
    print(f'  Nuevos: {res["nuevos"]:,} | Desaparecidos: {res["desaparecidos"]:,} | Comunes: {res["comunes"]:,}')
    print(f'  Recomendación: ', end='')
    if pct_nuevos > 50:
        print('usar XLSX como versión activa — aporta datos significativamente más recientes')
    else:
        print('evaluar si los cambios justifican migrar al XLSX')
    print()
```

**Output Celda 11:**

```
=== RESUMEN EJECUTIVO ===

Criterio de interpretación:
  >80% IDs nuevos  → XLSX es una actualización mayor, aporta datos muy distintos
  30-80% IDs nuevos → XLSX es una actualización parcial
  <30% IDs nuevos  → XLSX es principalmente el mismo dataset con pequeños cambios

Madrid
  🟢 Actualización MENOR — mayoría de datos coinciden
  Nuevos: 0 | Desaparecidos: 0 | Comunes: 19,618
  Recomendación: evaluar si los cambios justifican migrar al XLSX

London CSV vs XLSX
  🟢 Actualización MENOR — mayoría de datos coinciden
  Nuevos: 0 | Desaparecidos: 0 | Comunes: 85,068
  Recomendación: evaluar si los cambios justifican migrar al XLSX

London XLSX(1) vs XLSX
  🟢 Actualización MENOR — mayoría de datos coinciden
  Nuevos: 0 | Desaparecidos: 0 | Comunes: 85,068
  Recomendación: evaluar si los cambios justifican migrar al XLSX

Milan
  🟢 Actualización MENOR — mayoría de datos coinciden
  Nuevos: 0 | Desaparecidos: 0 | Comunes: 18,322
  Recomendación: evaluar si los cambios justifican migrar al XLSX
```


### Celda 12 — Código [In 7]

```python
# SDD: Tabla resumen para el catálogo de datasets (markdown)
import os
os.makedirs('data/processed', exist_ok=True)

lineas = ['# Comparación CSV vs XLSX por ciudad\n\n']
lineas.append('| Ciudad | Versión A | Versión B | IDs comunes | Nuevos en B | Desapar. de A | Significancia |\n')
lineas.append('|---|---|---|---|---|---|---|\n')

for (key_a, key_b, nombre), (_, res) in zip(pares, resultados_ids.items()):
    pct = res['nuevos']/res['total_b']*100 if res['total_b'] > 0 else 0
    sig = 'Alta' if pct > 50 else ('Media' if pct > 20 else 'Baja')
    lineas.append(
        f"| {nombre} | {datasets[key_a]['fecha']} ({res['total_a']:,}) "
        f"| {datasets[key_b]['fecha']} ({res['total_b']:,}) "
        f"| {res['comunes']:,} | {res['nuevos']:,} ({pct:.0f}%) "
        f"| {res['desaparecidos']:,} | {sig} |\n"
    )

ruta = 'data/processed/comparacion_csv_xlsx.md'
with open(ruta, 'w', encoding='utf-8') as f:
    f.writelines(lineas)

print(''.join(lineas))
print(f'✅ Guardado en: {ruta}')
```

**Output Celda 12:**

```
# Comparación CSV vs XLSX por ciudad

| Ciudad | Versión A | Versión B | IDs comunes | Nuevos en B | Desapar. de A | Significancia |
|---|---|---|---|---|---|---|
| Madrid | 2021-05 (19,618) | 2026-01 (19,618) | 19,618 | 0 (0%) | 0 | Baja |
| London CSV vs XLSX | 2022-08 (85,068) | 2024-10-24 (85,068) | 85,068 | 0 (0%) | 0 | Baja |
| London XLSX(1) vs XLSX | 2024-10-11 (85,068) | 2024-10-24 (85,068) | 85,068 | 0 (0%) | 0 | Baja |
| Milan | 2021-08 (18,322) | 2024-10 (18,322) | 18,322 | 0 (0%) | 0 | Baja |

✅ Guardado en: data/processed/comparacion_csv_xlsx.md
```


### Celda 13 — Markdown

## 5. Estructura completa de cada dataset (para el catálogo)

Output directo para completar `catalogo_datasets_data_dictionary.md`.


### Celda 14 — Código [In 8]

```python
# SDD: Ficha completa de cada dataset para el catálogo
print('=== FICHA DE CADA DATASET ===\n')

for key, meta in datasets.items():
    df = meta['df']
    print(f'--- {key} ({meta["ciudad"]} · {meta["fecha"]}) ---')
    print(f'  Registros: {df.shape[0]:,} | Columnas: {df.shape[1]}')
    print(f'  Nulos totales: {df.isnull().sum().sum():,}')
    print(f'  Columnas y tipos:')
    for col in df.columns:
        n_nulos = df[col].isnull().sum()
        pct_nulos = n_nulos / len(df) * 100
        dtype = str(df[col].dtype)
        n_uniq = df[col].nunique()
        nulos_str = f' [{n_nulos:,} nulos = {pct_nulos:.1f}%]' if n_nulos > 0 else ''
        print(f'    {col:40} {dtype:10} {n_uniq:>6} valores únicos{nulos_str}')
    print()
```

**Output Celda 14:**

```
=== FICHA DE CADA DATASET ===

--- madrid_csv (Madrid · 2021-05) ---
  Registros: 19,618 | Columnas: 16
  Nulos totales: 11,804
  Columnas y tipos:
    id                                       int64       19618 valores únicos
    name                                     str         18793 valores únicos [3 nulos = 0.0%]
    host_id                                  int64       11325 valores únicos
    host_name                                str          3900 valores únicos [527 nulos = 2.7%]
    neighbourhood_group                      str            21 valores únicos
    neighbourhood                            str           128 valores únicos
    latitude                                 float64      7536 valores únicos
    longitude                                float64      7595 valores únicos
    room_type                                str             4 valores únicos
    price                                    int64         544 valores únicos
    minimum_nights                           int64          81 valores únicos
    number_of_reviews                        int64         435 valores únicos
    last_review                              str          1590 valores únicos [5,637 nulos = 28.7%]
    reviews_per_month                        float64       682 valores únicos [5,637 nulos = 28.7%]
    calculated_host_listings_count           int64          51 valores únicos
    availability_365                         int64         366 valores únicos

--- madrid_xlsx (Madrid · 2026-01) ---
  Registros: 19,618 | Columnas: 16
  Nulos totales: 11,804
  Columnas y tipos:
    id                                       int64       19618 valores únicos
    name                                     object      18793 valores únicos [3 nulos = 0.0%]
    host_id                                  int64       11325 valores únicos
    host_name                                str          3900 valores únicos [527 nulos = 2.7%]
    neighbourhood_group                      str            21 valores únicos
    neighbourhood                            str           128 valores únicos
    latitude                                 float64      7536 valores únicos
    longitude                                float64      7595 valores únicos
    room_type                                str             4 valores únicos
    price                                    int64         544 valores únicos
    minimum_nights                           int64          81 valores únicos
    number_of_reviews                        int64         435 valores únicos
    last_review                              datetime64[us]   1590 valores únicos [5,637 nulos = 28.7%]
    reviews_per_month                        object        688 valores únicos [5,637 nulos = 28.7%]
    calculated_host_listings_count           int64          51 valores únicos
    availability_365                         int64         366 valores únicos

--- london_csv (London · 2022-08) ---
  Registros: 85,068 | Columnas: 16
  Nulos totales: 125,118
  Columnas y tipos:
    id                                       int64       85068 valores únicos
    name                                     str         82446 valores únicos [26 nulos = 0.0%]
    host_id                                  int64       53476 valores únicos
    host_name                                str         14573 valores únicos [12 nulos = 0.0%]
    neighbourhood_group                      float64         0 valores únicos [85,068 nulos = 100.0%]
    neighbourhood                            str            33 valores únicos
    latitude                                 float64     20713 valores únicos
    longitude                                float64     32079 valores únicos
    room_type                                str             4 valores únicos
    price                                    int64         881 valores únicos
    minimum_nights                           int64         107 valores únicos
    number_of_reviews                        int64         415 valores únicos
    last_review                              str          1818 valores únicos [20,006 nulos = 23.5%]
    reviews_per_month                        float64       944 valores únicos [20,006 nulos = 23.5%]
    calculated_host_listings_count           int64          86 valores únicos
    availability_365                         int64         366 valores únicos

--- london_xlsx (London · 2024-10-24) ---
  Registros: 85,068 | Columnas: 16
  Nulos totales: 125,118
  Columnas y tipos:
    id                                       int64       85068 valores únicos
    name                                     object      82436 valores únicos [26 nulos = 0.0%]
    host_id                                  int64       53476 valores únicos
    host_name                                object      14572 valores únicos [12 nulos = 0.0%]
    neighbourhood_group                      float64         0 valores únicos [85,068 nulos = 100.0%]
    neighbourhood                            str            33 valores únicos
    latitude                                 float64     20713 valores únicos
    longitude                                float64     29598 valores únicos
    room_type                                str             4 valores únicos
    price                                    int64         881 valores únicos
    minimum_nights                           int64         107 valores únicos
    number_of_reviews                        int64         415 valores únicos
    last_review                              datetime64[us]   1818 valores únicos [20,006 nulos = 23.5%]
    reviews_per_month                        object        954 valores únicos [20,006 nulos = 23.5%]
    calculated_host_listings_count           int64          86 valores únicos
    availability_365                         int64         366 valores únicos

--- london_xlsx1 (London · 2024-10-11) ---
  Registros: 85,068 | Columnas: 16
  Nulos totales: 125,118
  Columnas y tipos:
    id                                       int64       85068 valores únicos
    name                                     object      82436 valores únicos [26 nulos = 0.0%]
    host_id                                  int64       53476 valores únicos
    host_name                                object      14572 valores únicos [12 nulos = 0.0%]
    neighbourhood_group                      float64         0 valores únicos [85,068 nulos = 100.0%]
    neighbourhood                            str            33 valores únicos
    latitude                                 float64     20713 valores únicos
    longitude                                float64     29598 valores únicos
    room_type                                str             4 valores únicos
    price                                    int64         881 valores únicos
    minimum_nights                           int64         107 valores únicos
    number_of_reviews                        int64         415 valores únicos
    last_review                              datetime64[us]   1818 valores únicos [20,006 nulos = 23.5%]
    reviews_per_month                        object        954 valores únicos [20,006 nulos = 23.5%]
    calculated_host_listings_count           int64          86 valores únicos
    availability_365                         int64         366 valores únicos

--- milan_csv (Milan · 2021-08) ---
  Registros: 18,322 | Columnas: 15
  Nulos totales: 10,258
  Columnas y tipos:
    id                                       int64       18322 valores únicos
    name                                     str         18050 valores únicos [10 nulos = 0.1%]
    host_id                                  int64       12213 valores únicos
    host_name                                str          2917 valores únicos [124 nulos = 0.7%]
    neighbourhood                            str            87 valores únicos
    latitude                                 float64      7419 valores únicos
    longitude                                float64      9134 valores únicos
    room_type                                str             4 valores únicos
    price                                    int64         465 valores únicos
    minimum_nights                           int64          68 valores únicos
    number_of_reviews                        int64         421 valores únicos
    last_review                              str          2039 valores únicos [5,062 nulos = 27.6%]
    reviews_per_month                        float64       648 valores únicos [5,062 nulos = 27.6%]
    calculated_host_listings_count           int64          49 valores únicos
    availability_365                         int64         366 valores únicos

--- milan_xlsx (Milan · 2024-10) ---
  Registros: 18,322 | Columnas: 15
  Nulos totales: 10,261
  Columnas y tipos:
    id                                       int64       18322 valores únicos
    name                                     object      18049 valores únicos [12 nulos = 0.1%]
    host_id                                  int64       12213 valores únicos
    host_name                                str          2916 valores únicos [125 nulos = 0.7%]
    neighbourhood                            str            87 valores únicos
    latitude                                 float64      7419 valores únicos
    longitude                                object       9134 valores únicos
    room_type                                str             4 valores únicos
    price                                    int64         465 valores únicos
    minimum_nights                           int64          68 valores únicos
    number_of_reviews                        int64         421 valores únicos
    last_review                              datetime64[us]   2039 valores únicos [5,062 nulos = 27.6%]
    reviews_per_month                        object        603 valores únicos [5,062 nulos = 27.6%]
    calculated_host_listings_count           int64          49 valores únicos
    availability_365                         int64         366 valores únicos

--- ny_csv (New York · 2019-10) ---
  Registros: 48,895 | Columnas: 16
  Nulos totales: 20,141
  Columnas y tipos:
    id                                       int64       48895 valores únicos
    name                                     str         47905 valores únicos [16 nulos = 0.0%]
    host_id                                  int64       37457 valores únicos
    host_name                                str         11452 valores únicos [21 nulos = 0.0%]
    neighbourhood_group                      str             5 valores únicos
    neighbourhood                            str           221 valores únicos
    latitude                                 float64     19048 valores únicos
    longitude                                float64     14718 valores únicos
    room_type                                str             3 valores únicos
    price                                    int64         674 valores únicos
    minimum_nights                           int64         109 valores únicos
    number_of_reviews                        int64         394 valores únicos
    last_review                              str          1764 valores únicos [10,052 nulos = 20.6%]
    reviews_per_month                        float64       937 valores únicos [10,052 nulos = 20.6%]
    calculated_host_listings_count           int64          47 valores únicos
    availability_365                         int64         366 valores únicos

--- sydney_csv (Sydney · 2019-11) ---
  Registros: 36,662 | Columnas: 16
  Nulos totales: 60,554
  Columnas y tipos:
    id                                       int64       36662 valores únicos
    name                                     str         35857 valores únicos [12 nulos = 0.0%]
    host_id                                  int64       27219 valores únicos
    host_name                                str          7874 valores únicos [6 nulos = 0.0%]
    neighbourhood_group                      float64         0 valores únicos [36,662 nulos = 100.0%]
    neighbourhood                            str            38 valores únicos
    latitude                                 float64     36662 valores únicos
    longitude                                float64     36662 valores únicos
    room_type                                str             3 valores únicos
    price                                    int64         653 valores únicos
    minimum_nights                           int64          93 valores únicos
    number_of_reviews                        int64         286 valores únicos
    last_review                              str          1407 valores únicos [11,937 nulos = 32.6%]
    reviews_per_month                        float64       837 valores únicos [11,937 nulos = 32.6%]
    calculated_host_listings_count           int64          52 valores únicos
    availability_365                         int64         366 valores únicos

--- tokyo_csv (Tokyo · 2019-09) ---
  Registros: 11,466 | Columnas: 14
  Nulos totales: 14,836
  Columnas y tipos:
    id                                       int64       11466 valores únicos
    name                                     str         10810 valores únicos
    host_id                                  int64        2954 valores únicos
    host_name                                str          2054 valores únicos [16 nulos = 0.1%]
    neighbourhood_group                      float64         0 valores únicos [11,466 nulos = 100.0%]
    neighbourhood                            str            56 valores únicos
    latitude                                 float64      7295 valores únicos
    longitude                                float64      8140 valores únicos
    room_type                                str             3 valores únicos
    price                                    int64         371 valores únicos
    minimum_nights                           int64          30 valores únicos
    number_of_reviews                        int64         251 valores únicos
    last_review                              str           413 valores únicos [1,677 nulos = 14.6%]
    reviews_per_month                        float64       692 valores únicos [1,677 nulos = 14.6%]
```

