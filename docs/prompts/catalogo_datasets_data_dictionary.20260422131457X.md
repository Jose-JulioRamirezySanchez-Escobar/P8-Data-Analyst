# Catálogo de Datasets — Data Dictionary
**P8-Data-Analyst · AirBnB 6 ciudades**  
**Repositorio:** https://github.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst  
**Datos generados por:** `00b_comparacion_csv_xlsx.ipynb` ejecutado el 2026-04-22  
**Carpeta raw:** https://github.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/tree/main/data/raw

---

## ⚠️ Conclusión principal: CSV y XLSX son el mismo dataset

El análisis comparativo (`00b_comparacion_csv_xlsx.ipynb`) demuestra que los archivos
`.xlsx` son exportaciones del **mismo snapshot** que los `.csv` correspondientes.
No son actualizaciones temporales con datos más recientes.

| Par comparado | IDs comunes | IDs nuevos | IDs desaparecidos | Cambios en valores |
|---|---|---|---|---|
| Madrid CSV (2021-05) vs XLSX (2026-01) | 19.618 (100%) | 0 | 0 | 0 en todos los campos |
| London CSV (2022-08) vs XLSX (2024-10-24) | 85.068 (100%) | 0 | 0 | Mismo contenido* |
| London XLSX(1) (2024-10-11) vs XLSX (2024-10-24) | 85.068 (100%) | 0 | 0 | Copias idénticas |
| Milan CSV (2021-08) vs XLSX (2024-10) | 18.322 (100%) | 0 | 0 | 0 en todos los campos |

*Los timestamps de los archivos reflejan cuándo se descargaron, no cuándo se capturaron los datos.

**Decisión para el proyecto:**
- Usar los **CSV** para el análisis global — más ligeros, sin dependencia de openpyxl
- Los XLSX pueden **archivarse** o eliminarse — no aportan datos adicionales
- `london_airbnb(1).xlsx` es copia exacta de `london_airbnb.xlsx` → **eliminar**

**Diferencia técnica entre CSV y XLSX del mismo dataset:**
- En el XLSX, `last_review` se lee como `datetime64[us]` (Excel parsea fechas automáticamente)
- En el CSV, `last_review` se lee como `str` (requiere parseo explícito con `pd.to_datetime`)
- En Milán XLSX, `longitude` se lee como `object` (posible problema de formato en el xlsx)

---

## Versiones activas recomendadas para el análisis

| Ciudad | Archivo recomendado | Motivo |
|---|---|---|
| Madrid | `madrid_airbnb.csv` | CSV y XLSX idénticos; CSV más ligero |
| Londres | `london_airbnb.csv` | CSV y XLSX idénticos; CSV más ligero |
| Milán | `milan_airbnb.csv` | CSV y XLSX idénticos; CSV más ligero |
| Nueva York | `NY_airbnb.csv` | Única versión disponible |
| Sydney | `sydney_airbnb.csv` | Única versión disponible |
| Tokio | `tokyo_airbnb.csv` | Única versión disponible |

---

## Fichas de datasets

---

### NY_airbnb.csv

| Dataset | Tamaño | Fecha descarga | Snapshot estimado |
|---|---|---|---|
| NY_airbnb.csv | 7.077.973 bytes | 2019-10-27 | 2019-10 |

**Enlace raw:**  
https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/NY_airbnb.csv

| Registros | Columnas | Moneda | Nulos totales |
|---|---|---|---|
| 48.895 | 16 | USD | 20.141 |

| Campo | Tipo | Valores únicos | Nulos | Descripción |
|---|---|---|---|---|
| id | int64 | 48.895 | 0 | Identificador único del alojamiento |
| name | str | 47.905 | 16 (0,0%) | Nombre del anuncio |
| host_id | int64 | 37.457 | 0 | Identificador único del anfitrión |
| host_name | str | 11.452 | 21 (0,0%) | Nombre del anfitrión |
| neighbourhood_group | str | 5 | 0 | Borough de NY (Manhattan, Brooklyn, Queens, Bronx, Staten Island) |
| neighbourhood | str | 221 | 0 | Barrio específico |
| latitude | float64 | 19.048 | 0 | Latitud geográfica |
| longitude | float64 | 14.718 | 0 | Longitud geográfica |
| room_type | str | 3 | 0 | Tipo de alojamiento (Entire home/apt, Private room, Shared room) |
| price | int64 | 674 | 0 | Precio por noche en USD |
| minimum_nights | int64 | 109 | 0 | Noches mínimas requeridas |
| number_of_reviews | int64 | 394 | 0 | Total de reseñas |
| last_review | str | 1.764 | 10.052 (20,6%) | Fecha última reseña (yyyy-mm-dd) — nulo cuando sin reseñas |
| reviews_per_month | float64 | 937 | 10.052 (20,6%) | Media reseñas/mes — nulo cuando sin reseñas |
| calculated_host_listings_count | int64 | 47 | 0 | Anuncios activos del anfitrión |
| availability_365 | int64 | 366 | 0 | Días disponibles en los próximos 365 días |

---

### madrid_airbnb.csv

| Dataset | Tamaño | Fecha descarga | Snapshot estimado |
|---|---|---|---|
| madrid_airbnb.csv | 2.801.783 bytes | 2021-05-22 | 2021-05 |

**Enlace raw:**  
https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/madrid_airbnb.csv

| Registros | Columnas | Moneda | Nulos totales |
|---|---|---|---|
| 19.618 | 16 | EUR | 11.804 |

| Campo | Tipo | Valores únicos | Nulos | Descripción |
|---|---|---|---|---|
| id | int64 | 19.618 | 0 | Identificador único del alojamiento |
| name | str | 18.793 | 3 (0,0%) | Nombre del anuncio |
| host_id | int64 | 11.325 | 0 | Identificador único del anfitrión |
| host_name | str | 3.900 | 527 (2,7%) | Nombre del anfitrión |
| neighbourhood_group | str | 21 | 0 | Distrito de Madrid (Chamartín, Latina, Arganzuela…) |
| neighbourhood | str | 128 | 0 | Barrio específico del distrito |
| latitude | float64 | 7.536 | 0 | Latitud geográfica |
| longitude | float64 | 7.595 | 0 | Longitud geográfica |
| room_type | str | 4 | 0 | Tipo de alojamiento |
| price | int64 | 544 | 0 | Precio por noche en EUR |
| minimum_nights | int64 | 81 | 0 | Noches mínimas requeridas |
| number_of_reviews | int64 | 435 | 0 | Total de reseñas |
| last_review | str | 1.590 | 5.637 (28,7%) | Fecha última reseña (yyyy-mm-dd) |
| reviews_per_month | float64 | 682 | 5.637 (28,7%) | Media reseñas/mes |
| calculated_host_listings_count | int64 | 51 | 0 | Anuncios activos del anfitrión |
| availability_365 | int64 | 366 | 0 | Días disponibles en los próximos 365 días |

### madrid_airbnb.xlsx

| Dataset | Tamaño | Fecha descarga |
|---|---|---|
| madrid_airbnb.xlsx | 1.972.142 bytes | 2026-01-14 |

**Enlace raw:**  
https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/madrid_airbnb.xlsx

| Registros | Columnas | Moneda | Nulos totales |
|---|---|---|---|
| 19.618 | 16 | EUR | 11.804 |

> ⚠️ **Mismo contenido que madrid_airbnb.csv.** 100% de IDs coinciden, 0 cambios en valores.  
> Diferencia técnica: `last_review` se lee como `datetime64[us]` (Excel parsea fechas automáticamente).  
> **Recomendación: usar el CSV para el análisis. El XLSX puede archivarse.**

---

### london_airbnb.csv

| Dataset | Tamaño | Fecha descarga | Snapshot estimado |
|---|---|---|---|
| london_airbnb.csv | 11.578.155 bytes | 2022-08-16 | 2022-08 |

**Enlace raw:**  
https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/london_airbnb.csv

| Registros | Columnas | Moneda | Nulos totales |
|---|---|---|---|
| 85.068 | 16 | GBP | 125.118 |

| Campo | Tipo | Valores únicos | Nulos | Descripción |
|---|---|---|---|---|
| id | int64 | 85.068 | 0 | Identificador único del alojamiento |
| name | str | 82.446 | 26 (0,0%) | Nombre del anuncio |
| host_id | int64 | 53.476 | 0 | Identificador único del anfitrión |
| host_name | str | 14.573 | 12 (0,0%) | Nombre del anfitrión |
| neighbourhood_group | float64 | 0 | 85.068 (100%) | ⚠️ Vacío en este dataset |
| neighbourhood | str | 33 | 0 | Borough de Londres (Lambeth, Islington…) |
| latitude | float64 | 20.713 | 0 | Latitud geográfica |
| longitude | float64 | 32.079 | 0 | Longitud geográfica |
| room_type | str | 4 | 0 | Tipo de alojamiento |
| price | int64 | 881 | 0 | Precio por noche en GBP |
| minimum_nights | int64 | 107 | 0 | Noches mínimas requeridas |
| number_of_reviews | int64 | 415 | 0 | Total de reseñas |
| last_review | str | 1.818 | 20.006 (23,5%) | Fecha última reseña (yyyy-mm-dd) |
| reviews_per_month | float64 | 944 | 20.006 (23,5%) | Media reseñas/mes |
| calculated_host_listings_count | int64 | 86 | 0 | Anuncios activos del anfitrión |
| availability_365 | int64 | 366 | 0 | Días disponibles en los próximos 365 días |

### london_airbnb.xlsx y london_airbnb(1).xlsx

| Dataset | Tamaño | Fecha descarga |
|---|---|---|
| london_airbnb.xlsx | 8.262.897 bytes | 2024-10-24 |
| london_airbnb(1).xlsx | 8.230.750 bytes | 2024-10-11 |

**Enlace raw (versión principal):**  
https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/london_airbnb.xlsx

| Registros | Columnas | Moneda | Nulos totales |
|---|---|---|---|
| 85.068 | 16 | GBP | 125.118 |

> ⚠️ **Mismo contenido que london_airbnb.csv.** 100% de IDs coinciden.  
> `london_airbnb.xlsx` y `london_airbnb(1).xlsx` son **copias idénticas** (mismos 85.068 registros, mismo contenido).  
> **Recomendación: usar el CSV. Eliminar london_airbnb(1).xlsx. El XLSX puede archivarse.**

---

### milan_airbnb.csv

| Dataset | Tamaño | Fecha descarga | Snapshot estimado |
|---|---|---|---|
| milan_airbnb.csv | 2.393.568 bytes | 2021-08-26 | 2021-08 |

**Enlace raw:**  
https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/milan_airbnb.csv

| Registros | Columnas | Moneda | Nulos totales |
|---|---|---|---|
| 18.322 | 15 | EUR | 10.258 |

| Campo | Tipo | Valores únicos | Nulos | Descripción |
|---|---|---|---|---|
| id | int64 | 18.322 | 0 | Identificador único del alojamiento |
| name | str | 18.049 | 10 (0,1%) | Nombre del anuncio |
| host_id | int64 | 12.213 | 0 | Identificador único del anfitrión |
| host_name | str | 2.916 | 124 (0,7%) | Nombre del anfitrión |
| neighbourhood | str | 87 | 0 | Barrio en mayúsculas (NAVIGLI, SARPI…) — **sin neighbourhood_group** |
| latitude | float64 | 7.419 | 0 | Latitud geográfica |
| longitude | float64 | 9.134 | 0 | Longitud geográfica |
| room_type | str | 4 | 0 | Tipo de alojamiento |
| price | int64 | 465 | 0 | Precio por noche en EUR |
| minimum_nights | int64 | 68 | 0 | Noches mínimas requeridas |
| number_of_reviews | int64 | 421 | 0 | Total de reseñas |
| last_review | str | 2.039 | 5.062 (27,6%) | Fecha última reseña — ⚠️ **formato dd/mm/yy** (distinto al resto) |
| reviews_per_month | float64 | 648 | 5.062 (27,6%) | Media reseñas/mes |
| calculated_host_listings_count | int64 | 49 | 0 | Anuncios activos del anfitrión |
| availability_365 | int64 | 366 | 0 | Días disponibles en los próximos 365 días |

> ⚠️ `neighbourhood_group` ausente — columna no disponible en este dataset.  
> ⚠️ `last_review` en formato `dd/mm/yy` — parsear con `dayfirst=True`.

### milan_airbnb.xlsx

| Dataset | Tamaño | Fecha descarga |
|---|---|---|
| milan_airbnb.xlsx | 1.779.197 bytes | 2024-10-08 |

**Enlace raw:**  
https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/milan_airbnb.xlsx

| Registros | Columnas | Moneda | Nulos totales |
|---|---|---|---|
| 18.322 | 15 | EUR | 10.261 |

> ⚠️ **Mismo contenido que milan_airbnb.csv.** 100% de IDs coinciden, 0 cambios en valores.  
> Diferencia técnica: `longitude` se lee como `object` en el XLSX (posible problema de formato interno).  
> `last_review` se lee como `datetime64[us]` — el xlsx evita el problema del formato `dd/mm/yy`.  
> **Recomendación: usar el CSV con `dayfirst=True`. El XLSX puede archivarse.**

---

### sydney_airbnb.csv

| Dataset | Tamaño | Fecha descarga | Snapshot estimado |
|---|---|---|---|
| sydney_airbnb.csv | 5.504.518 bytes | 2019-11-17 | 2019-11 |

**Enlace raw:**  
https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/sydney_airbnb.csv

| Registros | Columnas | Moneda | Nulos totales |
|---|---|---|---|
| 36.662 | 16 | AUD | 60.554 |

| Campo | Tipo | Valores únicos | Nulos | Descripción |
|---|---|---|---|---|
| id | int64 | 36.662 | 0 | Identificador único del alojamiento |
| name | str | 35.857 | 12 (0,0%) | Nombre del anuncio |
| host_id | int64 | 27.219 | 0 | Identificador único del anfitrión |
| host_name | str | 7.874 | 6 (0,0%) | Nombre del anfitrión |
| neighbourhood_group | float64 | 0 | 36.662 (100%) | ⚠️ Vacío en este dataset |
| neighbourhood | str | 38 | 0 | Suburbio de Sydney (Manly, Balmain…) |
| latitude | float64 | 36.662 | 0 | Latitud geográfica (valores negativos — hemisferio sur) |
| longitude | float64 | 36.662 | 0 | Longitud geográfica |
| room_type | str | 3 | 0 | Tipo de alojamiento |
| price | int64 | 653 | 0 | Precio por noche en AUD |
| minimum_nights | int64 | 93 | 0 | Noches mínimas requeridas |
| number_of_reviews | int64 | 286 | 0 | Total de reseñas |
| last_review | str | 1.407 | 11.937 (32,6%) | Fecha última reseña (yyyy-mm-dd) |
| reviews_per_month | float64 | 837 | 11.937 (32,6%) | Media reseñas/mes |
| calculated_host_listings_count | int64 | 52 | 0 | Anuncios activos del anfitrión |
| availability_365 | int64 | 366 | 0 | Días disponibles en los próximos 365 días |

> ⚠️ `neighbourhood_group` vacío — no utilizable.  
> ⚠️ 0,2% de registros con coordenadas fuera del bounding box de Sydney.

---

### tokyo_airbnb.csv

| Dataset | Tamaño | Fecha descarga | Snapshot estimado |
|---|---|---|---|
| tokyo_airbnb.csv | 1.738.173 bytes | 2019-09-10 | 2019-09 |

**Enlace raw:**  
https://raw.githubusercontent.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/main/data/raw/tokyo_airbnb.csv

| Registros | Columnas | Moneda | Nulos totales |
|---|---|---|---|
| 11.466 | 14 | JPY | 14.836 |

| Campo | Tipo | Valores únicos | Nulos | Descripción |
|---|---|---|---|---|
| id | int64 | 11.466 | 0 | Identificador único del alojamiento |
| name | str | 10.810 | 0 | Nombre del anuncio — ⚠️ 18,5% contiene caracteres japoneses |
| host_id | int64 | 2.954 | 0 | Identificador único del anfitrión |
| host_name | str | 2.054 | 16 (0,1%) | Nombre del anfitrión — ⚠️ 11,5% contiene caracteres japoneses |
| neighbourhood_group | float64 | 0 | 11.466 (100%) | ⚠️ Vacío en este dataset |
| neighbourhood | str | 56 | 0 | Barrio en romaji (Shibuya Ku, Sumida Ku…) |
| latitude | float64 | 7.295 | 0 | Latitud geográfica |
| longitude | float64 | 8.140 | 0 | Longitud geográfica |
| room_type | str | 3 | 0 | Tipo de alojamiento |
| price | int64 | 371 | 0 | Precio por noche en JPY |
| minimum_nights | int64 | 30 | 0 | Noches mínimas requeridas |
| number_of_reviews | int64 | 251 | 0 | Total de reseñas |
| last_review | str | 413 | 1.677 (14,6%) | Fecha última reseña (yyyy-mm-dd) |
| reviews_per_month | float64 | 692 | 1.677 (14,6%) | Media reseñas/mes |

> ⚠️ **Faltan `calculated_host_listings_count` y `availability_365`** — no disponibles en este dataset.  
> ⚠️ 2,2% de registros con coordenadas fuera del bounding box administrativo de Tokio.  
> ⚠️ `name` y `host_name` con caracteres japoneses — transliterados por `00_homogenizacion.ipynb`.

---

## Resumen comparativo de todos los datasets

| Dataset | Ciudad | Registros | Cols | Moneda | Fecha snapshot | Versión recomendada |
|---|---|---|---|---|---|---|
| NY_airbnb.csv | Nueva York | 48.895 | 16 | USD | 2019-10 | ✅ Única disponible |
| madrid_airbnb.csv | Madrid | 19.618 | 16 | EUR | 2021-05 | ✅ Usar CSV |
| madrid_airbnb.xlsx | Madrid | 19.618 | 16 | EUR | 2021-05 | 📦 Archivar |
| london_airbnb.csv | Londres | 85.068 | 16 | GBP | 2022-08 | ✅ Usar CSV |
| london_airbnb.xlsx | Londres | 85.068 | 16 | GBP | 2022-08 | 📦 Archivar |
| london_airbnb(1).xlsx | Londres | 85.068 | 16 | GBP | 2022-08 | 🗑️ Eliminar (copia exacta) |
| milan_airbnb.csv | Milán | 18.322 | 15 | EUR | 2021-08 | ✅ Usar CSV |
| milan_airbnb.xlsx | Milán | 18.322 | 15 | EUR | 2021-08 | 📦 Archivar |
| sydney_airbnb.csv | Sydney | 36.662 | 16 | AUD | 2019-11 | ✅ Única disponible |
| tokyo_airbnb.csv | Tokio | 11.466 | 14 | JPY | 2019-09 | ✅ Única disponible |
| **TOTAL** | **6 ciudades** | **219.981*** | — | — | — | |

*Tras eliminar precios inválidos y registros sin coordenadas.

---

*Catálogo generado a partir de los outputs reales de `00b_comparacion_csv_xlsx.ipynb` · 2026-04-22*  
*P8-Data-Analyst · Bootcamp IA P4 · Factoría F5 Madrid*
