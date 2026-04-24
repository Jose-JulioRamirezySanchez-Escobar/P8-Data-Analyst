# Especificaciones: Conversión de Notebooks Jupyter a Documento Imprimible
**Estado:** Análisis de requisitos — sin implementación  
**Autor:** Jose-Julio Ramírez y Sánchez-Escobar  
**Proyecto:** P8-Data-Analyst · Bootcamp IA P4 · Factoría F5 Madrid

---

## 1. Objetivo

Transformar archivos `.ipynb` (JSON) en documentos con formato editorial
adecuado para impresión en A4 y edición en Word 365 / LibreOffice Writer,
preservando la naturaleza del cuaderno: celdas Markdown, celdas de código
con colores de sintaxis, outputs tabulares, gráficas y mapas.

---

## 2. Requisitos funcionales identificados

### 2.1 Estructura del documento

- Cada celda del notebook debe ocupar al menos una página completa.
  Una celda puede extenderse a varias páginas, pero **no puede quedar
  cortada** entre página y página.
- Número de celda visible, tipo de celda (Markdown / Code / Output)
  y título descriptivo generado para cada celda.
- Numeración de líneas en celdas de código.
- Índice con referencias internas navegables (marcadores / bookmarks).

### 2.2 Formato por tipo de celda

| Tipo de celda | Requisito de formato |
|---|---|
| Markdown | Renderizado completo: encabezados, negrita, tablas, listas, bloque de código inline |
| Código Python | Fuente monoespaciada (Consolas 7pt o equivalente), colores de sintaxis Python, fondo diferenciado |
| Output — texto | Fuente monoespaciada, fondo diferenciado del código |
| Output — tabla DataFrame | Tabla formateada, reescalada a ancho de página, con encabezado de columnas |
| Output — gráfica estática | Imagen vectorial (SVG/EMF) si es posible; si es mapa de bits, resolución ≥150 DPI; subtítulo indexado |
| Output — gráfica interactiva Plotly | Exportar como imagen estática para el documento imprimible |
| Output — mapa geográfico | Captura estática con subtítulo y nota de interactividad perdida |

### 2.3 Página y maquetación

- Tamaño: A4 (210×297 mm) con márgenes configurables.
- Encabezado: campo nombre de archivo, fecha de ejecución, versión.
- Pie de página: número de página, total de páginas, proyecto.
- Los campos de encabezado/pie deben ser:
  - **Editables** desde dentro y fuera del documento (campos de Word / variables de LibreOffice Writer).
  - **Actualizables en bloque** bajo demanda (actualizar campos en Word: `Ctrl+A → F9`).
  - No sincronizables de forma simultánea (no se requiere enlace en tiempo real).

### 2.4 Índices y referencias

- Tabla de contenido automática basada en los títulos de celda.
- Lista de figuras (gráficas y mapas) con subtítulos y números de página.
- Lista de tablas (DataFrames) con subtítulos y números de página.
- Marcadores internos accesibles por el usuario (navegación directa a cualquier celda).

---

## 3. Análisis de la cadena de conversión

### 3.1 Ruta recomendada

```
.ipynb (JSON)
    ↓ nbconvert
.html (intermedio con CSS)
    ↓ pandoc / importación en Word
.docx (editable en Word 365 / LibreOffice Writer)
    ↓ exportar desde el procesador
.pdf (destino final paginado)
```

### 3.2 Por qué esta ruta y no otras

| Alternativa | Ventaja | Limitación |
|---|---|---|
| `nbconvert → PDF` directo | Un paso | Requiere LaTeX (complejo en Windows); poco control sobre el layout; colores de sintaxis limitados |
| `nbconvert → HTML → Word` | HTML preserva colores CSS; Word puede importar HTML | Word no importa CSS correctamente; las tablas y gráficas pueden perder formato |
| `nbconvert → LaTeX → PDF` | Máximo control tipográfico | Curva de aprendizaje alta; difícil de editar después |
| `nbconvert → HTML → pandoc → docx` | Pandoc convierte bien Markdown y tablas; docx editable | Los colores de sintaxis se pierden en pandoc; las gráficas Plotly requieren pre-exportación |
| `Quarto` | Diseñado para documentos científicos desde notebooks; soporta Word y PDF | Requiere instalación separada; curva de aprendizaje |

### 3.3 El problema de los colores de sintaxis

Los colores de sintaxis Python en un `.docx` requieren que cada token del
código esté formateado individualmente con su color. Esto no lo hace
ninguna herramienta de conversión automática de forma satisfactoria.

**Opciones reales:**

1. **Aceptar código sin colores en el docx** — solución práctica para uso en Word/LibreOffice.
2. **Convertir directamente a HTML con `nbconvert --to html`** — el HTML sí tiene colores CSS completos; se visualiza en navegador y se imprime desde él con buen resultado.
3. **Usar `nbconvert --to webpdf`** — genera PDF directamente desde el HTML con Chromium; preserva colores y layout pero el docx no es el destino.

### 3.4 El problema de las gráficas interactivas Plotly

Los gráficos Plotly son HTML/JavaScript interactivos — no tienen representación
estática en el `.ipynb` a menos que se haya ejecutado el notebook y guardado
los outputs. Para el documento imprimible es necesario:

1. Ejecutar el notebook y guardar con outputs (`File → Save`).
2. Usar `plotly.io.write_image()` para exportar cada figura como SVG o PNG
   antes de la conversión del documento.
3. O aceptar que en el PDF aparecerá la versión estática que Plotly guarda
   como fallback en el notebook.

---

## 4. Preguntas abiertas — pendientes de respuesta

> Estas preguntas deben resolverse antes de definir la implementación.

**La pregunta es →** ¿Cuál es el destino prioritario del documento?

Con las siguientes opciones:
- a) PDF directamente (sin edición posterior en Word/LibreOffice)
- b) Documento editable `.docx` que luego se exporta a PDF
- c) Ambos de forma independiente

---

**La pregunta es →** ¿Los colores de sintaxis son imprescindibles en el documento final?

Con las siguientes opciones:
- a) Sí, el código debe verse con colores Python en el documento impreso
- b) No, el código puede ir en fuente monoespaciada sin colores (más fácil de lograr)
- c) Solo en la versión HTML/PDF generada desde el navegador; en el .docx no es necesario

---

**La pregunta es →** ¿Las gráficas Plotly deben aparecer como imágenes estáticas en el documento?

Con las siguientes opciones:
- a) Sí, exportar cada gráfica como imagen antes de convertir
- b) Sí, pero solo si el notebook ya tiene los outputs guardados
- c) No, basta con una nota indicando que la gráfica es interactiva y no imprimible

---

**La pregunta es →** ¿Qué herramienta usarás principalmente para editar el documento resultante?

Con las siguientes opciones:
- a) Word 365 (Windows)
- b) LibreOffice Writer
- c) Solo visualización y PDF — sin edición posterior

---

## 5. Propuesta de implementación por fases (a validar)

### Fase 1 — Solución mínima viable (PDF con colores desde navegador)

```bash
# Genera HTML con colores de sintaxis y outputs completos
uv run jupyter nbconvert --to html notebooks/00b_comparacion_csv_xlsx.ipynb

# Abrir en Firefox e imprimir a PDF desde el navegador
# Firefox → Archivo → Imprimir → Guardar como PDF
# Permite: colores, tablas, gráficas, layout limpio
# No permite: edición posterior, campos dinámicos, índices navegables
```

**Resultado:** PDF funcional con colores. Sin campos editables. Sin índice.

### Fase 2 — Documento editable con pandoc

```bash
# HTML → docx via pandoc (colores de sintaxis limitados)
uv add pandoc
uv run jupyter nbconvert --to html notebooks/00b_comparacion_csv_xlsx.ipynb
pandoc notebooks/00b_comparacion_csv_xlsx.html -o docs/00b_comparacion_csv_xlsx.docx
```

**Resultado:** `.docx` editable en Word/LibreOffice. Sin colores de sintaxis.
Las gráficas Plotly pueden no aparecer.

### Fase 3 — Solución completa con Quarto (máximo control)

Quarto es la herramienta diseñada exactamente para este problema.
Requiere instalación separada y adaptar el notebook al formato `.qmd`.
Genera `.docx` y `.pdf` con control completo sobre layout, índices,
numeración de celdas y campos de página.

Documentación: https://quarto.org/docs/output-formats/ms-word.html

---

## 6. Resumen de limitaciones reales

| Requisito | Factibilidad | Observación |
|---|---|---|
| Colores de sintaxis en .docx | ⚠️ Difícil | Solo con Quarto o procesado token a token |
| Colores de sintaxis en PDF | ✅ Posible | Via nbconvert HTML + impresión desde navegador |
| Tablas formateadas | ✅ Posible | nbconvert HTML + pandoc |
| Gráficas estáticas | ✅ Posible | Requiere pre-exportar con plotly.io |
| Mapas geográficos | ⚠️ Parcial | Solo captura estática; interactividad se pierde |
| Campos de encabezado/pie editables | ✅ En .docx | Campos de Word / estilos de LibreOffice |
| Actualización de campos en bloque | ✅ En .docx | Ctrl+A → F9 en Word |
| Índice con marcadores navegables | ✅ En .docx | Requiere estilos de Título correctamente aplicados |
| Celdas sin corte de página | ⚠️ Complejo | Requiere CSS `page-break-inside: avoid` o configuración en Quarto |
| Subtítulos indexados por figura | ✅ En .docx | Requiere procesado post-conversión |

---

*Documento de especificaciones — sin implementación. Pendiente de respuestas a las preguntas de la sección 4.*
