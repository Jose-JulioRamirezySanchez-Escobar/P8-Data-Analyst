## Resumen

En `notebooks/00b_comparacion_csv_xlsx.ipynb` (Celda 9), la comparación
de valores entre versiones de un mismo dataset por ciudad falla en
Londres con `Can only compare identically-labeled Series objects`,
y devuelve `0 cambios` en Madrid y Milán de forma probablemente engañosa.

## Síntoma

Output de la Celda 9 del notebook:
--- Madrid (19,618 IDs comunes) ---
price: 0 cambios (0.0%)        ← sospechoso
--- London CSV vs XLSX (85,068 IDs comunes) ---
price: no comparable — Can only compare identically-labeled Series objects
--- Milan (18,322 IDs comunes) ---
price: 0 cambios (0.0%)        ← sospechoso

## Causa raíz

La comparación se hace con:
```python
diff = (a_common['price'] != b_common['price']).sum()
```

Pandas alinea Series por **índice** (no por valor de `id`). Tras filtrar
por `isin(common_ids)`, los índices de `a_common` y `b_common` no
coinciden. En Madrid/Milán el orden coincide por casualidad y la
comparación parece dar `0 cambios`, pero no es robusta. En Londres el
orden difiere y el error se hace explícito.

## Impacto

- La conclusión "Significancia: Baja" en
  `notebooks/data/processed/comparacion_csv_xlsx.md` puede estar
  **subreportando cambios reales** entre snapshots CSV y XLSX.
- Si el EDA asume "datasets idénticos", esa asunción no está validada.

## Fix propuesto

Sustituir comparación por índice por `merge(on='id')` con sufijos:

```python
merged = a_common[['id', 'price', 'minimum_nights', 'room_type',
                   'availability_365']].merge(
    b_common[['id', 'price', 'minimum_nights', 'room_type',
              'availability_365']],
    on='id', suffixes=('_a', '_b')
)
for col in ['price', 'minimum_nights', 'room_type', 'availability_365']:
    cambios = (merged[f'{col}_a'] != merged[f'{col}_b']).sum()
    pct = 100 * cambios / len(merged)
    print(f"  {col:35}: {cambios:>6,} cambios ({pct:.1f}%)")
```

Adicionalmente, normalizar dtypes antes de comparar `price` (CSV puede
traerlo como `"$45.00"`, XLSX como `45.0`):

```python
merged['price_a'] = pd.to_numeric(merged['price_a'], errors='coerce')
merged['price_b'] = pd.to_numeric(merged['price_b'], errors='coerce')
```

## Tareas

- [ ] Aplicar fix en Celda 9 de `notebooks/00b_comparacion_csv_xlsx.ipynb`
- [ ] Re-ejecutar notebook completo
- [ ] Regenerar `notebooks/data/processed/comparacion_csv_xlsx.md` con
      cifras revisadas
- [ ] Validar si la conclusión "Significancia: Baja" se mantiene

## Referencias

- Notebook afectado: `notebooks/00b_comparacion_csv_xlsx.ipynb` (Celda 9)
- Output dump consultable:
  https://github.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/blob/main/docs/promts/00b_comparacion_csv_xlsx.md
- Trazabilidad de la detección:
  https://github.com/Jose-JulioRamirezySanchez-Escobar/P8-Data-Analyst/blob/main/docs/GitPush.P8-Data-Analyst.parte3.de3.pp40-41.20260424110314V.pdf