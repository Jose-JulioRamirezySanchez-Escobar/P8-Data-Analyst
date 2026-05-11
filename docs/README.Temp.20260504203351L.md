# P8 — Análisis del Mercado AirBnB

> Análisis comparativo del mercado de alojamientos turísticos AirBnB en seis ciudades globales: **Sydney, Nueva York, Madrid, Londres, Milán y Tokio**.
>
> Proyecto del **Bootcamp IA P6 — Factoría F5 Madrid**.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#7-licencia)
[![Status](https://img.shields.io/badge/status-en%20desarrollo-blue.svg)](#5-roadmap-y-estado-del-proyecto)
[![Bootcamp](https://img.shields.io/badge/Factor%C3%ADa%20F5-Bootcamp%20IA%20P6-orange.svg)](https://factoriaf5.org/)

---

## Tabla de contenidos

1. [Descripción del proyecto](#1-descripción-del-proyecto)
2. [Equipo y roles (Scrum)](#2-equipo-y-roles-scrum)
3. [Stack tecnológico](#3-stack-tecnológico)
4. [Entregables y enlaces externos](#4-entregables-y-enlaces-externos)
5. [Roadmap y estado del proyecto](#5-roadmap-y-estado-del-proyecto)
6. [Cómo contribuir (propuesta)](#6-cómo-contribuir-propuesta)
7. [Licencia](#7-licencia)
8. [Sobre este documento](#8-sobre-este-documento)

---

## 1. Descripción del proyecto

P8 es un proyecto de análisis de datos cuyo objetivo es estudiar el mercado de alojamientos turísticos de AirBnB a nivel internacional, a partir de un conjunto de datos público que cubre seis ciudades de referencia:

| Ciudad     | Continente   |
| ---------- | ------------ |
| Sydney     | Oceanía      |
| Nueva York | Norteamérica |
| Madrid     | Europa       |
| Londres    | Europa       |
| Milán      | Europa       |
| Tokio      | Asia         |

El equipo aborda el problema desde tres frentes complementarios:

- **Análisis exploratorio de datos (EDA)** y homogeneización de los datasets de las distintas ciudades.
- **Visualización y reporting** mediante dashboards profesionales.
- **Aplicación web** para presentar los hallazgos de forma interactiva.

Las preguntas de negocio guía incluyen, entre otras: comparación de precios medios entre ciudades, distribución por barrio, rentabilidad relativa, peso del segmento *superhost* frente a hosts regulares y patrones de disponibilidad.

> La descripción detallada de cada uno de los frentes (metodología, decisiones técnicas, hallazgos) corresponde a sus autores y vive en los entregables enlazados en la sección 4.

---

## 2. Equipo y roles (Scrum)

| Persona | Rol           |
| ------- | ------------- |
| Juanma  | Product Owner |
| Naiza   | Scrum Master  |
| Andy    | Data Analyst  |
| JJ      | Data Analyst  |
| Pal     | Data Analyst  |

> Los nombres de pila pueden completarse con apellidos y handles de GitHub si el equipo así lo decide.

---

## 3. Stack tecnológico

El proyecto combina varias áreas y herramientas. Cada miembro del equipo es referente de las tecnologías de su frente.

### Análisis de datos

- **Python 3.13** como lenguaje base.
- **Jupyter Lab** para los notebooks de homogeneización y EDA.
- **Pandas** para manipulación tabular.
- **Seaborn** y **Plotly** para visualización exploratoria (gráficos estáticos e interactivos).
- **uv** como gestor de entornos y dependencias.

### Visualización y reporting

- **Power BI Desktop** y **Power BI web** como herramienta principal del entregable de reporting.
- **Looker Studio** queda contemplado como plan alternativo de futuro (no implementado en esta iteración).

### Aplicación web (frontend)

- **React** con **TypeScript**.
- **Vite** como servidor de desarrollo y empaquetador.
- **Tailwind CSS** para estilos.
- **Recharts** y **Leaflet** para gráficos y mapas.
- Repositorio externo, ver sección 4.

### Gestión del proyecto

- **Git** y **GitHub** para control de versiones.
- **GitHub Projects (Kanban)** para seguimiento de tareas.
- Flujo de trabajo basado en ramas: `feature/*` → `develop` → `main`.

---

## 4. Entregables y enlaces externos

Los entregables principales del proyecto están repartidos en distintos repositorios y soportes. Este README los inventaría y enlaza; **la documentación técnica de cada uno reside en su propia ubicación y bajo la responsabilidad de su autor o autora**.

### Repositorio del equipo (este repositorio)

- **URL:** <https://github.com/Bootcamp-IA-P6/P8_Data_Analysis>
- **Función:** punto de entrada al proyecto y coordinación general.

### Frontend — Aplicación web del Dashboard

- **Repositorio:** <https://github.com/Delo-sangeles/Data_Analysis>
- **Stack:** React + TypeScript + Vite + Tailwind + Recharts + Leaflet.
- **Autora de referencia:** Naiza.
- **Documentación técnica de instalación y uso:** disponible en el `README.md` del propio repositorio del frontend.

### Presentación Power BI

- **Enlace:** <https://drive.google.com/file/d/1i-yYdaCaJXoN9tgTbRrr-hGYlZb4Lhlo/view?usp=sharing>
- **Autor de referencia:** Juanma.
- **Requisitos para visualización:**
  - **Power BI Desktop** (solo Windows) o **Power BI Web**.
  - Es necesario disponer de una cuenta de Microsoft / Power BI con acceso adecuado para abrir el archivo en su formato nativo, según la opción que se utilice.

### Tablero Kanban del proyecto

- **URL:** <https://github.com/orgs/Bootcamp-IA-P6/projects/46/views/1>
- **Uso:** seguimiento de issues, asignación de tareas y estado actual del trabajo.

---

## 5. Roadmap y estado del proyecto

El estado actualizado del proyecto, las tareas en curso y el desglose por issues se mantienen en el **tablero Kanban** del proyecto:

> <https://github.com/orgs/Bootcamp-IA-P6/projects/46/views/1>

Las grandes áreas de trabajo del proyecto son:

- Homogeneización de los datasets de las seis ciudades.
- Análisis exploratorio de datos (EDA).
- Construcción de dashboards en Power BI.
- Desarrollo de la aplicación web del frontend.
- Documentación, presentación final y entrega.

> Cada área tiene una o varias issues asociadas en el tablero, con personas responsables asignadas.

---

## 6. Cómo contribuir (propuesta)

Esta sección recoge una **propuesta abierta** de convenciones de trabajo. Las decisiones definitivas las toma el equipo y pueden modificar lo aquí expuesto.

### Flujo de ramas (Git Flow simplificado)

- `main` → rama estable, solo recibe merges desde `develop` para releases o entregas.
- `develop` → rama de integración del trabajo del equipo.
- `feature/<descripción-corta>` → rama de trabajo individual o de pareja para una issue concreta.

Flujo recomendado para una contribución:

1. Crear una rama `feature/<descripción>` desde `develop`.
2. Trabajar y hacer commits en la rama feature.
3. Abrir una **Pull Request** hacia `develop`.
4. Solicitar revisión a al menos una persona del equipo.
5. Tras aprobación, integrar en `develop`.
6. Las integraciones a `main` se acuerdan en equipo y se asocian a entregas o hitos.

### Convenciones de commits (propuesta)

- Mensajes claros y en imperativo: *"Añade gráfico de precios por barrio"*, *"Corrige cálculo de mediana en Madrid"*.
- Un commit por unidad lógica de cambio cuando sea razonable.
- Se valora el uso de prefijos tipo *Conventional Commits* (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`) si el equipo así lo decide.

### Pull Requests

- Título descriptivo y enlace a la issue del Kanban si aplica.
- Descripción breve de qué cambia y por qué.
- Capturas de pantalla cuando el cambio sea visual.

> Tanto el formato de mensajes como la plantilla de PR son **propuestas**. Cualquier ajuste debe acordarse con el equipo.

---

## 7. Licencia

Este proyecto se distribuye bajo licencia **MIT**.

```
MIT License

Copyright (c) 2026 Bootcamp IA P4 — Factoría F5 Madrid

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

> Nota: si el equipo decide adoptar otra licencia, esta sección debe actualizarse antes de la entrega final.

---

## 8. Sobre este documento

- **Tipo:** Propuesta de README de proyecto.
- **Autor de la propuesta:** JJ.
- **Rama:** [`v_01`](https://github.com/Bootcamp-IA-P6/P8_Data_Analysis/tree/v_01).
- **Estado:** sujeto a revisión y aprobación del equipo.
- **Alcance:** documento de presentación general del proyecto P8. La descripción técnica detallada de cada módulo (frontend, dashboards Power BI, notebooks de análisis) corresponde a sus autores y vive en los entregables enlazados en la sección 4.
- **Idioma:** castellano. Una versión en inglés podría plantearse en una iteración futura si el equipo lo considera oportuno.
