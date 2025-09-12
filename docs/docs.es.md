# Sistema de Pensamiento y Acción (SPA)

[![en](https://img.shields.io/badge/lang-en-informational?style=flat-square)](docs.md) [![es](https://img.shields.io/badge/lang-es-success?style=flat-square)](docs.es.md)

## Índice

1. [Descripción General](#descripción-general)
2. [¿Por qué usar SPA?](#por-qué-usar-spa)
3. [Objetivo del Sistema](#objetivo-del-sistema)
4. [Audiencia](#audiencia)
5. [Ventajas y Beneficios](#ventajas-y-beneficios)
6. [Requisitos y Herramientas](#requisitos-y-herramientas)
7. [Arquitectura General](#arquitectura-general)
8. [Ejemplo Básico de Uso](#ejemplo-básico-de-uso)
9. [Convenciones Internas](#convenciones-internas)
10. [Componentes del Sistema](#componentes-del-sistema)
11. [Workflow: Cómo funciona el sistema en conjunto](#workflow-cómo-funciona-el-sistema-en-conjunto)
12. [Proceso de Revisión](#proceso-de-revisión)
13. [Licencia](#licencia)

---

## Descripción General

El **Sistema de Pensamiento y Acción (SPA)** es una arquitectura modular para la organización personal, que integra la gestión del conocimiento, la planificación de objetivos y la ejecución de tareas. A diferencia de otros sistemas, SPA permite la creación de nuevo conocimiento a través de la fusión y maduración de ideas provenientes de distintas áreas vitales.

Está diseñado como una red funcional de componentes que interactúan de forma jerárquica y bidireccional, desde el pensamiento profundo hasta la acción cotidiana, pasando por un proceso constante de iteración.

---

## ¿Por qué usar SPA?

- Conecta lo que sabes con lo que haces.
- Organiza ideas, experiencias y aprendizajes en una red viva.
- Transforma conocimiento en objetivos concretos y tareas ejecutables.
- Permite descubrir relaciones entre áreas aparentemente no conectadas.
- Está diseñado para ser adaptado, iterado y compartido.

---

## Objetivo del Sistema

El objetivo de SPA es facilitar la **traducción de conocimiento personal en resultados tangibles** mediante objetivos definidos y tareas organizadas, partiendo desde un núcleo identitario y guiado por áreas clave en la vida de cada individuo.

---

## Audiencia

SPA está dirigido a cualquier persona interesada en mejorar su productividad personal. Es especialmente útil para quienes ya tienen familiaridad con metodologías como GTD, PARA, Zettelkasten, metodologías ágiles o sistemas de gestión personal.

---

## Ventajas y Beneficios

- Estructura modular tipo microservicios.
- Compatible con herramientas multiplataforma.
- Favorece la autoconciencia y la reflexión estructurada.
- Integra captura rápida, conocimiento profundo y acción programada.
- Flexible para artistas, ingenieros, estudiantes, escritores, emprendedores y más.

---

## Requisitos y Herramientas

SPA no depende de herramientas específicas, pero se recomienda el siguiente stack:

| Componente | Herramienta recomendada | Función |
|-----------|--------------------------|--------|
| Vault de conocimiento | Obsidian | Gestión estructurada de ideas y proyectos |
| Tareas estilo Kanban | Google Tasks (o Trello, Jira) | Seguimiento de tareas y objetivos |
| Calendario de time boxing | Google Calendar | Distribución diaria del tiempo y hábitos |
| Captura rápida / RAM | Google Keep | Registro ágil de ideas e información frecuente |

Otras herramientas pueden ser utilizadas si ofrecen funcionalidades equivalentes (vista de grafo, columnas kanban, integración de calendario, etc.).

---

## Arquitectura General

SPA funciona como una arquitectura por capas:

1. **Vault de Conocimiento (Capa profunda)**  
   Bóveda de ideas, aprendizajes, referencias y reflexiones. Aquí se definen:
   - Áreas de vida (e.g., salud, trabajo, arte)
   - Proyectos personales
   - Dominios de conocimiento que emergen con madurez

2. **Tareas (Capa intermedia)**  
   Las ideas se traducen en objetivos, y estos en tareas específicas.
   - Formato ágil con columnas: `To Do`, `In Progress`, `Blocked`, `Backlog`, `Projects`
   - Estimaciones tipo talla de playera (S, M, L, XL)

3. **Calendar (Capa de planificación)**  
   Utiliza las tareas, dominios y hábitos para crear bloques de tiempo en el calendario.

4. **Keep (Capa de memoria rápida y cache)**  
   - Guarda información crítica de uso recurrente (staff, contraseñas, claves)
   - Almacena ideas inmaduras antes de entrar al vault
   - Traduce conocimiento clave en bullets de acción rápida

---

## Ejemplo Básico de Uso

```
1. Comienzas con un nodo “core” que define quién eres.
2. Defines un área de tu vida: “Salud física”.
3. Dentro del área, creas un proyecto: “Correr un medio maratón”.
4. Este proyecto se registra en Tasks → columna “Projects”.
5. Desglosas tareas (entrenamientos, compra de equipo) → se colocan en Tasks con tallas.
6. Estas tareas se calendarizan en bloques diarios en Google Calendar.
7. En Keep guardas las rutas, entrenamientos, o suplementos frecuentes para consulta rápida.
8. Con el tiempo, ese proyecto puede convertirse en un dominio: “Carrera de fondo”.
```

---

## Convenciones Internas

- **Area - X** → Núcleo vital (Ej: `Area - Salud`)
- **Domain - X** → Especialización (Ej: `Domain - Nutrición`)
- **Project - X** → Aplicación o iniciativa concreta
- Estimaciones en tareas: `S`, `M`, `L`, `XL` (pueden reemplazarse por puntos, jelly beans, etc.)

---

## Componentes del Sistema

### 1. Vault (`/vault`)
- Organiza el conocimiento en notas markdown enlazadas.
- Soporta conexiones entre áreas, proyectos y dominios.
- Idealmente gestionado con vista de grafo (Obsidian).

### 2. Tasks (`/tasks`)
- Sistema Kanban personal.
- Estructura recomendada: `To Do`, `In Progress`, `Blocked`, `Backlog`, `Projects`.
- Incluye estimaciones por carga.

### 3. Calendar (`/calendar`)
- Implementa Time Boxing.
- Aloja hábitos, sesiones de trabajo profundo y revisiones.

### 4. Keep (`/keep`)
- Micro RAM del sistema.
- Funciona como entrada/salida del vault para datos rápidos.

---

## Workflow: Cómo funciona el sistema en conjunto

```
→ Keep: captura rápida de ideas →  
→ Vault: organiza, madura y conecta esas ideas en áreas, dominios y proyectos →  
→ Tasks: convierte ideas en acciones estimadas y organizadas →  
→ Calendar: agenda la ejecución de esas acciones en bloques de tiempo →  
↻ Revisión: retroalimenta todo el sistema con aprendizajes.
```

---

## Proceso de Revisión

Cada semana o ciclo, se realiza una “revisión de sprint”, que incluye:
- Reflexión sobre tareas completadas vs. bloqueadas
- Ajuste de objetivos y estimaciones
- Actualización del vault con aprendizajes relevantes
- Redistribución de tiempo en el calendario

No es un módulo, sino un hábito cíclico y sistemático.

---

## Licencia

Este sistema es de uso libre bajo los términos de la **Licencia MIT**.


## Authors

[![Contributors](https://img.shields.io/github/contributors-anon/leonardespi/spa?style=flat-square)](docs.es.md)  y tmbn [@leonardespi](https://www.github.com/leonardespi)  





