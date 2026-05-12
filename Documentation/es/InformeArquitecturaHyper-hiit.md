Informe de Arquitectura hyper//hiit
====================================

>    Rev. 45 (12/05/26)

&nbsp;

Tabla de contenidos
-------------------

[1. Fundamentos de la Arquitectura de Array Estructurado
](#1-fundamentos-de-la-arquitectura-de-array-estructurado)

[2. Agrupamiento Visual Dinámico vía subsistema_id
](#2-agrupamiento-visual-dinámico-vía-subsistema_id)

[3. Gestión del Flujo de Misión: Módulos de Transición y Descanso
](#3-gestión-del-flujo-de-misión-módulos-de-transición-y-descanso)

[4. Versatilidad de Datos: El Campo unidad_tipo
](#4-versatilidad-de-datos-el-campo-unidad_tipo)

[5. Cálculo Automático de Métricas de Protocolo
](#5-cálculo-automático-de-métricas-de-protocolo)

[6. Ejemplo de Implementación:](#6-ejemplo-de-implementación)

- [Protocolo INFERNO_SEQUENCE](#protocolo-inferno_sequence)

[7. Arquitectura Jerárquica del Sistema](#7-arquitectura-jerárquica-del-sistema)

[8. Modelo de Datos: Tablas Maestras y Relacionales](#8-modelo-de-datos-tablas-maestras-y-relacionales)

- [Tabla: Modules](#tabla-modules)

- [Tabla: directives](#tabla-directives)

- [Tabla: protocols](#tabla-protocols)

- [Tabla de mapeo: directive_protocols](#tabla-de-mapeo-directive_protocols)

- [Tabla de mapeo: protocol_structure](#tabla-de-mapeo-protocol_structure)

- [Tabla: ranks](#tabla-ranks)

- [Tabla session_history](#tabla-session_history)

[9. Lógica del Array Estructurado y Procesamiento de Datos
](#9-lógica-del-array-estructurado-y-procesamiento-de-datos)

- [Algoritmos de Cálculo de Métricas
](#algoritmos-de-cálculo-de-métricas)

[10. Arquitectura del fichero JSON](#10-arquitectura-del-fichero-json)

[11. Reglas de UX y Diseño de Interfaz (Mission Flow)
](#11-reglas-de-ux-y-diseño-de-interfaz-mission-flow)

- [Flujo de Misión (Mission Flux)](#flujo-de-misión-mission-flux)

- [Indicadores de Rango (RANK labels)](#indicadores-de-rango-rank-labels)

- [Visualización de Eficiencia y Progresión
](#visualización-de-eficiencia-y-progresión)

- [Requisitos Visuales del Sistema (System Footer)
](#requisitos-visuales-del-sistema-system-footer)

[12. Ejemplo de Implementación de Protocolo
](#12-ejemplo-de-implementación-de-protocolo)

- [Implementación Técnica](#implementación-técnica)

[13. Listado preliminar de protocolos por directiva
10](#13-listado-preliminar-de-protocolos-por-directiva)

- [A. FAT_BURNING (Metabolic acceleration protocol)
](#fat_burning-metabolic-acceleration-protocol)

- [B. CARDIO_ENHANCEMENT (Cardiovascular optimization system)
](#cardio_enhancement-cardiovascular-optimization-system)

- [C. STRENGTH_MATRIX (Muscular fortification sequence)
](#strength_matrix-muscular-fortification-sequence)

- [D. ENDURANCE_GRID (Stamina amplification framework)
](#endurance_grid-stamina-amplification-framework)

- [E. NEURAL_FLOW (Neural-synaptic synchronization)
](#neural_flow-neural-synaptic-synchronization)

[14. Métricas de Evolución:](#14-métricas-de-evolución)

- [Algoritmo de IMPROVEMENT
](algoritmo-de-improvement)

   - [A. Principio de Cálculo (Rolling Window)
](a-principio-de-cálculo-rolling-window)

   - [B. Fórmula del Índice de Potencia (Puntuación de Sesión)
](b-fórmula-del-índice-de-potencia-puntuación-de-sesión)

   - [C. Factor de Velocidad Relativa (Speed Factor)
](c-factor-de-velocidad-relativa-speed-factor)

   - [D. Generación del Porcentaje de IMPROVEMENT
](d-generación-del-porcentaje-de-improvement)

- [Algoritmo de EFFICIENCY
](algoritmo-de-efficiency)

   - [A. Fundamento de la Eficiencia Táctica
](a-fundamento-de-la-eficiencia-táctica)

   - [B. Cálculo Semanal (Dashboard Integration)
](b-cálculo-semanal-dashboard-integration)

   - [C. Jerarquía Visual y UX
](c-jerarquía-visual-y-ux)

   - [D. Implementación de Baja Latencia
](d-implementación-de-baja-latencia)

- [AVG_SESSIONS y AVG_CALORIES
](avg_sessions-y-avg_calories)

   - [A. Definición y Cálculo Matemático
](a-definición-y-cálculo-matemático)

   - [B. Implementación Técnica
](b-implementación-técnica)

[Hoja de ruta de versiones](#hoja-de-ruta-de-versiones)

- [v0.1: Core Terminal & Shell](#v01)

- [v0.2: Sistema de Navegación de Directivas](#v02)

- [v0.3: Gestión de Protocolos & Scroll](#v03)

- [v0.4: Motor de Ejecución (MVP)](#v04)

- [v0.5: Feedback en Tiempo Real](#v05)

- [v0.6: Evolution Metrics & Histórico](#v06)

- [v0.7: Achievement Matrix and Personal Record](#v07)

- [v0.8: Audio Uplink & Media Control](#v08)

- [v0.9: CORE_CONFG & ARCHITECHT](#v09)

- [v1.0: Full System Online](#v10)

&nbsp;

&nbsp;

# 1. Fundamentos de la Arquitectura de Array Estructurado

El esqueleto operativo del sistema hyper//hiit se articula mediante una
arquitectura de array estructurado basada en un mapeo relacional de alta
densidad. Esta elección no es meramente estética; es la solución óptima
para un terminal de rendimiento táctico que requiere una reducción
drástica de la carga cognitiva del usuario bajo condiciones de fatiga
extrema.

El uso de esta estructura garantiza las siguientes ventajas competitivas:

-   **Escalabilidad sin Cambios de Código:**
    > La adición de nuevos ejercicios
    > o módulos tácticos solo requiere una nueva entrada en la tabla de
    > mapeo, sin necesidad de modificar el motor de renderizado en
    > C++.

-   **Integración de Baja Latencia con el Backend:**
    > El motor en C++
    > procesa el array de forma nativa, asegurando una sincronización
    > biométrica en tiempo real (Neural Sync).

-   **Legibilidad Táctica:**
    > La estructura de datos permite una jerarquía
    > visual limpia, priorizando la información crítica para mantener el
    > rendimiento bajo presión física.

# 2. Agrupamiento Visual Dinámico vía subsistema_id

El campo subsistema_id actúa como el motor de segmentación del sistema. La
interfaz utiliza esta clave para generar automáticamente separadores y
cabeceras dinámicas (como **SUBSYSTEM_01** o **PHASE_A**), eliminando la
necesidad de tablas visuales predefinidas y rígidas.

Esta funcionalidad permite que la directiva activa (como
**FAT_BURNING** o **STRENGTH_MATRIX**) mantenga la estética "cyberpunk"
característica: una interfaz modular donde cada fase del entrenamiento se
presenta como un objetivo táctico segmentado. Este diseño facilita la
navegación visual rápida durante protocolos de alta intensidad en los que la
atención del usuario es limitada.

# 3. Gestión del Flujo de Misión: Módulos de Transición y Descanso

Una de las decisiones de arquitectura de UX más estratégicas ha sido la
integración de períodos de descanso y transiciones mediante un module_id
especializado. Desde la perspectiva de sistemas, esto permite que el
backend gestione una **máquina de estados única** para toda la misión,
evitando la complejidad de gestionar estados de "pausa" y "actividad" como
lógicas separadas.

Las ventajas de este diseño incluyen:

-   **Integridad Cronométrica:**
    > El cronómetro de la misión es continuo,
    > garantizando una telemetría precisa de la sesión completa.

-   **Continuidad del Flujo:**
    > El usuario recibe instrucciones claras de
    > **"REST"** o **"TRANSIT"** como parte orgánica de la secuencia,
    > evitando romper el ritmo operativo.

# 4. Versatilidad de Datos: El Campo unidad_tipo

El campo unidad_tipo es fundamental para el rigor de la base de
datos y su alineación con la sincronización biométrica. Este
atributo define la naturaleza de la variable numérica, permitiendo que el
sistema interprete correctamente el esfuerzo requerido para cada módulo.

|               |              |                                               |
|---------------|--------------|-----------------------------------------------|
| Valor Numérico | unidad_tipo | Interpretación del Sistema                    |
| 30            | repeticiones  | Ejecución física de 30 unidades (ej: Burpees)  |
| 30            | segundos      | Duración temporal de 30s (ej: Plancha o Descanso) |

# 5. Cálculo Automático de Métricas de Protocolo

El backend de C++ realiza una extracción de datos en tiempo real del
array para generar las métricas de ejecución que se muestran en la
interfaz de usuario:

1.  **MODULES:**
    > Realiza un conteo simple de las entradas (filas) del
    > array asignadas a un protocolo específico.

2.  **DURATION:**
    > Ejecuta la suma del producto de cada valor de
    > repetición por su **tiempo base** correspondiente. Este "tiempo base"
    > se recupera mediante una búsqueda relacional en la base de datos
    > utilizando el module_id como clave primaria, garantizando una
    > estimación temporal exacta.

# 6. Ejemplo de Implementación: 

-   ## Protocolo INFERNO_SEQUENCE

Basado en la telemetría de la interfaz actual bajo la directiva
**FAT_BURNING**, así se renderiza la jerarquía de datos:

-   **PROTOCOL HEADER:** INFERNO_SEQUENCE

    -   **Metadatos:** Duration: 20:00 \| Modules: 8 \| Completion: 85%

-   **SUBSYSTEM_01 (Warm-up):**

    -   30x Burpees, 30x Situps, 30x Jacks.

-   **TRANSIT_LINK (Module_ID: REST):**

    -   60s Rest.

-   **SUBSYSTEM_02 (Peak Intensity):**

    -   60x Burpees, 60x Situps, 60x Jacks.

-   **TRANSIT_LINK (Module_ID: REST):**

    -   60s Rest.

-   **SUBSYSTEM_03 (Cool-down):**

    -   30x Burpees, 30x Situps, 30x Jacks.

Este documento establece la especificación de ingeniería para el terminal
de alta tecnología **hyper//hiit**. Como Lead Solutions Architect,
el objetivo es garantizar una estructura de datos robusta bajo una
interfaz de tipo *Tactical Overlay* que maximice la eficiencia
operativa del usuario final.

# 7. Arquitectura Jerárquica del Sistema

La arquitectura del sistema se ha diseñado como una pila jerárquica de
cuatro niveles, optimizada para el procesamiento en tiempo real por el motor
de datos de C++.

-   **Level 1: Directive:**
    > El nodo superior del árbol. Define el
    > propósito de la misión (ej: FAT_BURNING o STRENGTH_MATRIX). El
    > sistema mantiene un estado de ACTIVE_DIRECTIVE para filtrar los
    > protocolos disponibles en la interfaz.

-   **Level 2: Protocol:**
    > Secuencias operativas vinculadas a una
    > *Directive*. Ejemplos verificados: INFERNO_SEQUENCE (8 módulos),
    > TORCH_PROTOCOL (6 módulos).

-   **Level 3: Subsystem:**
    > Segmentación lógica del flujo de datos. Permite
    > agrupar módulos en fases (Warm-up, Peak, Cool-down) facilitando un
    > "Agrupamiento Visual Dinámico" en la UI sin sobrecargar la base de
    > datos relacional.

-   **Level 4: Module:**
    > La unidad atómica de ejecución. Representa una
    > acción física (Burpees) o un estado del sistema (REST).

# 8. Modelo de Datos: Tablas Maestras y Relacionales

Para garantizar la integridad del *Neural Link* y la persistencia de datos,
se aplican los siguientes esquemas SQL:

### Tabla: Modules

Contiene la definición base de cada unidad de entrenamiento, así como la zona
de trabajo, la efectividad y el coeficiente de fatiga.

```sql
CREATE TABLE IF NOT EXISTS modules (
        module_id INTEGER PRIMARY KEY,
        mod_name VARCHAR(100),
        target_zone VARCHAR(50), -- Target area (e.g., FULL BODY)
        difficulty INT -- 1: Begginer \| 2: Intermediate \| 3: Advanced
        mod_description TEXT,
        mod_instructions TEXT,
        mod_safety TEXT,
        mod_equipment TEXT,
        unit_type INTEGER NOT NULL, -- 0: SECONDS \| 1: REPS \| 2: BREATH \| 3: METERS
        rep_time FLOAT,
        met_factor FLOAT, -- Efficiency constant
        fatigue_rate FLOAT, -- Performance tier 1
);
```

>   **Unit_type:**  
>   0: segundos  
>   1: repeticiones  
>   2: respiraciones  
>   3: metros

### Tabla: directives

Contiene la definición de cada una de las directivas a seguir para
conseguir el objetivo establecido.

```sql

CREATE TABLE IF NOT EXISTS directives (
        dir_id INTEGER PRIMARY KEY AUTOINCREMENT,
        dir_name TEXT NOT NULL,
        dir_description TEXT,
        dir_icon TEXT,
        dir_color TEXT
);

```

### Tabla: protocols

Contiene la información base de los protocolos sin incluir su
estructura de módulos, que se enlazará en otra tabla.

```sql

CREATE TABLE IF NOT EXISTS protocols (
        protocol_id INTEGER PRIMARY KEY AUTOINCREMENT,
        protocol_name TEXT NOT NULL,
        estimated_duration INTEGER,
        module_count INTEGER,
        rank TEXT,
        personal_best INTEGER
);

```

### Tabla de mapeo: directive_protocols

Contiene la relación entre los protocolos y las directivas que los incluyen.

```sql

CREATE TABLE IF NOT EXISTS directives_protocols (
        dp_mapping_id INTEGER PRIMARY KEY AUTOINCREMENT,
        dir_id INTEGER,
        protocol_id INTEGER,
        FOREIGN KEY(dir_id) REFERENCES directives(dir_id),
        FOREIGN KEY(protocol_id) REFERENCES protocols(protocol_id)
);

```

### Tabla de mapeo: protocol_structure

Contiene la estructura ejecutiva de los protocolos, definiendo en un listado único
todos los módulos de un protocolo.

```sql

CREATE TABLE IF NOT EXISTS protocol_structure (
        p_map_id INTEGER PRIMARY KEY AUTOINCREMENT,
        protocol_id INTEGER,
        subsystem INTEGER,
        s_order INT,
        module_id INTEGER,
        quantity INT,
        unit_type INT,
        UNIQUE (protocol_id, protocol_order),
        FOREIGN KEY (protocol_id) REFERENCES protocols(protocol_id),
        FOREIGN KEY (module_id) REFERENCES modules(module_id)
);

```

> **Nota Técnica sobre unit_type:** Este campo es crítico para la lógica
> del backend. Determina si el valor quantity debe interpretarse como un
> entero de repeticiones (ej: 30 Burpees) o como un contador de tiempo en
> segundos (ej: 60 segundos de Plank o de transición).

### Tabla: ranks

Contiene los nombres de los distintos niveles (normalmente tres) de los protocolos
y se importará desde el json.

```sql

CREATE TABLE IF NOT EXISTS ranks(
        rank_level INTEGER PRIMARY KEY,
        rank_name TEXT NOT NULL UNIQUE
);

```

### Tabla: session_history

Contiene la información de las sesiones ejecutadas y datos para las
métricas y estadísticas.

```sql

CREATE TABLE session_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    protocol_id INTEGER,
    session_timestamp INTEGER,
    session_duration INTEGER,
    modules_duration TEXT,
    calories_burned REAL,   -- StringList of module timelapse
    session_speed REAL,     -- Speed Index vs Ghost
    met_score REAL,         -- Accumulated MET * reps volume
    FOREIGN KEY(protocol_id) REFERENCES protocols(protocol_id)
);

```

# 9. Lógica del Array Estructurado y Procesamiento de Datos

El backend de C++ genera un array dinámico que la interfaz utiliza para
renderizar el flujo de misión.

## Algoritmos de Cálculo de Métricas

Las siguientes fórmulas se aplican para procesar los datos antes de la
visualización:

-   **MODULE_COUNT:**
    > Count = Total_Entries(Array) where protocol_id ==
    > active_protocol *(Ejemplo: INFERNO_SEQUENCE devuelve 8).*

-   **DURATION:**
    > TotalDuration = Σ (quantity_i \* base_time_i) *Donde
    > base_time* *se recupera de la tabla de Modules* *para cada
    > module_id.*

-   **FATIGUE_RATE:**
    > Es un porcentaje para calcular el tiempo total
    > aproximado del módulo multiplicando este por el número de repeticiones
    > y el resultado por el tiempo de repetición. Cuando se importa desde JSON se
    > pasa de porcentaje a multiplicador (6.5% = 1,065). Por ejemplo:
    > module_time = estimated_duration \* (quantity \* fatigue_rate)

-   **MET_FACTOR:**
    > Es una unidad que se utiliza para medir la
    > intensidad de la actividad física y el consumo de oxígeno. Por
    > definición, 1 MET equivale al consumo de energía de una persona en
    > reposo absoluto (el metabolismo basal). Para calcular las
    > kilocalorías (kcal) que se queman durante una actividad, se utiliza la
    > siguiente fórmula estándar: Calories = MET \* kg \* hours

El uso de subsystem_id permite inyectar separadores visuales en la UI de forma
automática, marcando las transiciones entre fases de intensidad sin
necesidad de lógica adicional en el frontend.

# 10. Arquitectura del fichero JSON

Para cargar y/o exportar los datos de una manera más sencilla
utilizaremos un fichero con formato **JSON** con la siguiente estructura
de ejemplo:

```json

{
   "modules":[
      {
         "module_name":"Rest",
         "difficulty":0,
         "target_zone":"REST",
         "description":"Take your time to rest",
         "instructions":"Take your time to rest",
         "safety_info":"Take your time to rest",
         "equipment":[
            "NONE"
         ],
         "unit_type":"seconds",
         "met_factor":12,
         "fatigue_rate":6.5,
         "rep_time":1
      },
      {
         "module_name":"Burpees",
         "difficulty":1,
         "target_zone":"FULL_BODY",
         "module_description":"Plank, push-up and jump",
         "instructions":"...",
         "safety_info":"Keep core tight",
         "equipment":[
            "NONE"
         ],
         "unit_type":"reps",
         "met_factor":12,
         "fatigue_rate":6.5,
         "rep_time":3.7
      },
      {
         "module_name":"Sit-ups",
         "difficulty":1,
         "target_zone":"CORE_FLEX",
         "module_description":"...",
         "instructions":"...",
         "safety_info":"Keep core tight",
         "equipment":[
            "NONE"
         ],
         "unit_type":"reps",
         "met_factor":4,
         "fatigue_rate":2,
         "rep_time":2.5
      },
      {
         "module_name":"Squats",
         "difficulty":1,
         "module_description":"...",
         "instructions":"...",
         "safety_info":"Keep core tight",
         "equipment":[
            "NONE"
         ],
         "target_zone":"LOWER_KNEE",
         "unit_type":"reps",
         "met_factor":8,
         "fatigue_rate":3,
         "rep_time":3.25
      }
   ],
   "directives":[
      {
         "directive_name":"FAT_BURNING",
         "directive_description":"Metabolic acceleration protocol",
         "directive_icon":"\\ue0d2",
         "directive_color":"#BF00FF"
      },
      {
         "directive_name":"CARDIO_ENHANCEMENT",
         "directive_description":"Cardiovascular optimization system",
         "directive_icon":"\\ue0f2",
         "directive_color":"#00FFF9"
      }
   ],
   "protocols":[
      {
         "protocol_name":"ARES_STRIKE",
         "estimated_duration":1200,
         "module_count":8,
         "rank":"ADVANCED",
         "personal_best":85,
         "target_directives":[
            "FAT_BURNING",
            "CARDIO_ENHANCEMENT"
         ],
         "structure":[
            {
               "order":1,
               "subsystem":1,
               "module":"Burpees",
               "quantity":30,
               "unit":"reps"
            },
            {
               "order":2,
               "subsystem":1,
               "module":"Sit-ups",
               "quantity":30,
               "unit":"reps"
            },
            {
               "order":3,
               "subsystem":1,
               "module":"Squats",
               "quantity":30,
               "unit":"reps"
            }
         ]
      }
   ],
   "ranks": [
     {
       "rank_level": 1,
       "rank_name": "NEWBIE"
     },
     {
       "rank_level": 2,
       "rank_name": "ADVANCED"
     },
     {
       "rank_level": 3,
       "rank_name": "ROOT"
     }
   ]
}
```

# 11. Reglas de UX y Diseño de Interfaz (Mission Flow)

La interfaz se ha concebido como una *Neural Interface* de alto contraste,
siguiendo la estética cyberpunk funcional.

### Flujo de Misión (Mission Flux)

Para mantener la inmersión total y la sincronización, el contador global
de la misión nunca se detiene. Esto se consigue mediante lo siguiente:

-   Inyección de module_id especiales de tipo **REST** o **TRANSIT**.

-   Durante estos módulos, la UI muestra avisos de recuperación o preparación, pero el reloj de misión permanece activo.

### Indicadores de Rango (RANK labels)

El sistema clasifica la dificultad y el perfil de acceso en tres niveles:

-   newbie: Usuarios en fase de iniciación.

-   advanced: Nivel de élite (verificado en la vista STRENGTH_MATRIX de la versión actual).

-   root: Máximo dominio del sistema.

### Visualización de Eficiencia y Progresión

-   **Barra de Progreso:** 
    > Renderiza el estado actual de la misión. Debe
    > incluir un marcador vertical que represente el **Personal Record
    > (PR)** para permitir una comparativa en tiempo real.

-   **Eficiencia:** 
    > El sistema calcula el rendimiento actual respecto a la
    > mejor marca (ej: 89% EFFICIENCY).

### Requisitos Visuales del Sistema (System Footer)

Toda interfaz debe mostrar de forma permanente las métricas de estado
del sistema al pie de página:

-   **NEURAL_SYNC:** % de sincronización del usuario.

-   **LATENCY:** Tiempo de respuesta (Requisito: \<1ms).

-   **BUILD:** Versión del entorno, consultar documento "Hoja de ruta de versiones".

# 12. Ejemplo de Implementación de Protocolo

Estructura de un array de protocolo completo segmentado por subsistemas:

-   **SUBSYSTEM_01 (Warm-up/Initial):**

    -   30x Burpees

    -   30x Situps

    -   30x Jacks

-   **TRANSIT_LINK:**

    -   60s Rest (*Módulo de tipo transición*)

-   **SUBSYSTEM_02 (Peak Intensity):**

    -   60x Burpees

    -   60x Situps

    -   60x Jacks

-   **TRANSIT_LINK:**

    -   60s Rest

-   **SUBSYSTEM_03 (Cool-down):**

    -   30x Burpees

    -   30x Situps

    -   30x Jacks

Este modelo de array permite que el backend alimente la UI con datos
precisos, manteniendo el flujo constante necesario para la experiencia
**hyper//hiit**.

## Implementación Técnica

Cada uno de estos nombres actúa como un protocol_id en tu
**arquitectura de array estructurado**. Recuerda que:

-   > El backend de C++ utilizará estos nombres para consultar la tabla
    > protocol_structure y calcular automáticamente los **MODULES** y la
    > **DURATION** que se muestran en la interfaz.

-   > Podrás asignarles un **RANK** (newbie, advanced o root) para
    > diferenciar la dificultad visualmente con las etiquetas cian.

# 13. Listado preliminar de protocolos por directiva

A continuación, se presentan las propuestas de **10 protocolos para cada
directiva** activa en el sistema **hyper//hiit**, manteniendo el rigor visual
de terminal cyberpunk, evitando palabras dobles largas y ajustando el
tamaño a referencias como KINETIC_LINK:

## FAT_BURNING (Metabolic acceleration protocol)

Diseñados para un alto gasto calórico.

-   **STRIKE**

-   **METABOLIX**

-   **PYROGEN**

-   **THERMO_X**

-   **BLAZE_CORE**

-   **IGNITE_ID**

-   **SCORCH**

-   **FUEL_CELL**

-   **RAPID_BURN**

-   **HEAT_SYNC**

## CARDIO_ENHANCEMENT (Cardiovascular optimization system)

Protocolos optimizados para la frecuencia cardíaca y la mejora de
la eficiencia.

-   **AEROBYTE**

-   **PULSE_ID**

-   **VO2_MAX_ST**

-   **HEART_LINK**

-   **CYBER_BEAT**

-   **RHYTHM_AX**

-   **BPM_MATRIX**

-   **FLOW_ZONE**

-   **OXYGEN_SYS**

-   **PUMP_CORE**

## STRENGTH_MATRIX (Muscular fortification sequence)

Nombres que evocan dureza y estructuras sólidas, coherentes con la meta
**IRON_CORE** de la ACHIEVEMENT_MATRIX.

-   **TITANIUM**

-   **GOLIATH**

-   **IRON_STORM**

-   **REINFORCE**

-   **KINETIC**

-   **OBSIDIAN**

-   **HYPER_CORE**

-   **FORTRESS**

-   **TENSION_ID**

-   **STALWART**

## ENDURANCE_GRID (Stamina amplification framework)

Enfocados en la resistencia sostenida y la capacidad de mantener el
sistema online durante períodos largos.

-   **STEEL_CORE**

-   **STAMINA**

-   **STEADFAST**

-   **LASTING**

-   **GRID_RUN**

-   **ETERNAL**

-   **STAMINA**

-   **BUFFER_SYS**

-   **LIMITLESS**

-   **VIGOR_NET**

-   **RELENTLESS**

## NEURAL_FLOW (Neural-synaptic synchronization)

Basados en la propuesta para el equilibrio y la sincronización,
reflejando el estado de **NEURAL_SYNC** al 100%.

-   **NEURALIS**

-   **STASIS_X**

-   **ZEN_SYNC**

-   **FOCUS_ID**

-   **FLOW_LINK**

-   **NEURAL_AX**

-   **BALANCER**

-   **SYNC_CORE**

-   **EQUILIBRIUM**

-   **MIND_GRID**

#  14. Métricas de Evolución:

## Algoritmo de IMPROVEMENT

El indicador IMPROVEMENT, visualizado en la sección EVOLUTION_METRICS, 
representa el crecimiento del rendimiento táctico y metabólico del usuario
mediante una comparativa de ventanas deslizantes de tiempo.

### A. Principio de Cálculo (Rolling Window)

El sistema no utiliza semanas naturales, sino una comparativa de 
ventana deslizante de 7 días para evitar el vaciado de datos cada lunes:

- **Segmento A (Actual):** Sumatorio de datos de los últimos 7 días
(T-0 a T-6).

- **Segmento B (Base):** Sumatorio de datos de los 7 días inmediatamente
anteriores (T-7 a T-13).

- **Regla de Validación:** Solo se contabilizan los protocolos
finalizados al 100% (estado COMPLETED). Las sesiones parciales no computan
para la evolución.

### B. Fórmula del Índice de Potencia (Puntuación de Sesión)

Para cada sesión, el backend de C++ genera una puntuación bruta basada
en cuatro vectores de rendimiento:

>   Puntuación = ∑Cal + ( ∑Ranks × K ) + ( MET × n_reps ) + ( Tiempo total × Velocidad )

-   **∑Cal:** Calorías totales quemadas (en números enteros para
optimización de UX).

-   **∑Ranks × K:** Multiplicador de dificultad basado en el rango del protocolo.
    -   Constantes de Rango (K): newbie = 1 | advanced = 5 | root = 10

-   **MET × n_reps:** Volumen de trabajo mecánico real, calculado según el
MET_FACTOR de cada módulo y su quantity.

-   **Tiempo total × Velocidad:** Factor de densidad temporal.

### C. Factor de Velocidad Relativa (Speed Factor)

La velocidad es una métrica comparativa guardada en *session_history* que mide
la eficiencia temporal respecto al último registro del mismo *protocol_id*:

>   Velocidad = ( Tiempo anterior / Tiempo actual )

-   **V > 1:** El usuario ha superado su registro anterior
(efecto Ghost/PB).

-   **V < 1:** El usuario ha realizado una sesión más lenta que la
referencia previa.

### D. Generación del Porcentaje de IMPROVEMENT

El valor final de IMPROVEMENT se obtiene mediante una regla de tres simple
que compara el sumatorio de puntuaciones del Segmento A respecto al Segmento
B (establecido como el 100% de base).

Este dato alimenta la visualización del terminal con un formato de
porcentaje de alto contraste (ej: +23%), permitiendo una lectura táctica
inmediata del progreso real del sujeto bajo el sistema hyper//hiit. 

## Algoritmo de EFFICIENCY

El indicador EFFICIENCY, situado en el bloque EVOLUTION_METRICS del dashboard
principal, mide la consistencia táctica y la calidad de la ejecución
temporal del usuario en sus misiones recientes. A diferencia del
Personal Best (PB), que es una métrica histórica absoluta,
la eficiencia se centra en el rendimiento comparativo sesión a sesión.

### A. Fundamento de la Eficiencia Táctica

La eficiencia se calcula mediante el Factor de Velocidad Relativa
(Speed Index) almacenado en la tabla session_history. Este
factor compara el tiempo de la sesión actual con el de la sesión
inmediatamente anterior del mismo *protocol_id*.

-   Fórmula de Eficiencia de Sesión:

>   Eficiencia = ( Tiempo actual / Tiempo anterior ) × 100

-   Interpretación de Valores:

    -   **=100%:** Consistencia total respecto a la última ejecución.
    -   **>100%:** Incremento de eficiencia (overclocking del sistema).
    -   **<100%:** Pérdida de ritmo o fatiga acumulada detectada por el sistema.
    
### B. Cálculo Semanal (Dashboard Integration)

El valor porcentual mostrado en la interfaz (ej: 89% EFFICIENCY
o +48% según la última telemetría) representa la media aritmética
de las eficiencias de todas las sesiones completadas en el segmento
actual de 7 días.

-   **Algoritmo de Comparativa:** De la misma manera que el IMPROVEMENT,
el sistema compara la media de eficiencia del Segmento A (T-0 a T-6) con
la del Segmento B (T-7 a T-13) para determinar si la tendencia de
consistencia es positiva o negativa.

### C. Jerarquía Visual y UX

Para evitar la sobrecarga cognitiva, el sistema separa claramente los
tres indicadores de rendimiento temporal:

1. **Barra Horizontal (Tarjeta de Protocolo):** Indica la carga o duración
total estimada del protocolo.

2. **Marcador Vertical (Personal Best):** Indica el récord histórico absoluto
(PR) grabado en la tabla protocols.

3. **Etiqueta EFFICIENCY (Evolution Metrics):** Indica la capacidad del usuario
para mantener o mejorar su ritmo de trabajo actual respecto a sus
últimas intervenciones.

### D. Implementación de Baja Latencia

El cálculo de la eficiencia se realiza en el backend de C++ al cerrar cada
sesión (estado COMPLETED), actualizando el campo speed_index en la base de
datos. Esto garantiza que la visualización en el dashboard se realice con
una latencia menor a 1ms, cumpliendo los requisitos técnicos del sistema.

## AVG_SESSIONS y AVG_CALORIES

Estas métricas proporcionan una lectura de la intensidad y la constancia
basal del usuario, complementando la información visual del gráfico de 7 días
con datos cuantitativos de media diaria.

### A. Definición y Cálculo Matemático

A diferencia de otros sistemas que muestran sumatorios totales, hyper//hiit
utiliza la media aritmética (mean) sobre el Segmento A (últimos 7 días)
para garantizar una telemetría precisa que permita valores decimales:

-   **AVG_SESSIONS** (Media de sesiones por día): 

>   AVG_SESSIONS = ∑SessionesCOMPLETED(T-0 a T-6) / 7

    - Nota de UX: El uso de la media permite mostrar decimales (ej: 2.14),
    ofreciendo una visión de la frecuencia de entrenamiento más allá de los días
    activos visibles en el gráfico.
    
-   **AVG_CALORIES** (Media de calorías por día):

>   AVG_CALORIES = ∑CaloriasCOMPLETED(T-0 a T-6) / 7

    - Nota de UX: Representa la potencia metabólica diaria. Al dividir
    por el total de días del segmento (7), el dato es independiente de si
    el usuario ha entrenado un día concreto o no, reflejando el nivel
    de actividad global semanal.
    
### B. Implementación Técnica

-   **Procesamiento:** El backend de C++ realiza el sumatorio y la
división asíncronamente al cargar el dashboard o al cerrar una sesión.

-   **Latencia:** El resultado se sirve a la interfaz QML como valor
numérico de alto contraste, manteniendo el requisito de respuesta de sistema de <1ms.

-   **Coherencia:** Estos datos se actualizan automáticamente con la
ventana deslizante de 7 días, asegurando que el "Tactical Overlay" esté
siempre sincronizado con el rendimiento más reciente del sujeto.

# Hoja de ruta de versiones

Esta hoja de ruta prioriza la funcionalidad del núcleo de la aplicación
para garantizar que el sistema sea usable para el entrenamiento en etapas
tempranas. Inicialmente está dividida en 10 etapas para garantizar un flujo
constante de desarrollo. Se establecerá la versión 0.4 como MVP
(Minimum Viable Product).


## v0.1: Core Terminal & Shell<a name="v01">:</a>

<!-- -->

-   **Interfaz Base:** Implementación del contenedor principal con
    estética dark mode y colores neón (cian y magenta) 1.

-   **Header & Footer Técnico:** Activación del logotipo hyper//hiit con
    efecto glow y el pie de página funcional con datos de LATENCY, BUILD
    y el marcador estático de NEURAL_SYNC: 100% 1, 2.

-   **Estructura de Secciones:** Definición de los espacios para
    EVOLUTION_METRICS, ACTIVE_DIRECTIVE y ACHIEVEMENT_MATRIX 1.

## v0.2: Sistema de Navegación de Directivas<a name="v02">:</a>

<!-- -->

-   **Lógica de Acordeón:** Implementación del mecanismo para desplegar y
    colapsar las directivas (FAT_BURNING, CARDIO_ENHANCEMENT, etc.) 3,
    4.

-   **Selección Activa:** Actualización de la cabecera de la sección
    según la directiva seleccionada por el sistema 3.

-   **Indicadores de Estado:** Integración de iconos Lucide (rayo, corazón,
    etc.) y descripciones para cada directiva 1, 3.

-   **Estructura de la Base de Datos:** Funciones de lectura y escritura
    básicas y carga desde fichero de datos Json.

## v0.3: Gestión de Protocolos & Scroll<a name="v03">:</a>

<!-- -->

-   **Mission Protocols List:** Implementación de la lista de protocolos
    con tarjetas individuales que muestran DURATION y MODULES 3, 4.

-   **Representación de Directivas y protocolos:** Lectura de base de
    datos y representación en los componentes QML.

-   **Navegación Vertical:** Activación de la barra de desplazamiento
    (scrollbar) cian en la parte derecha para navegar entre los protocolos de
    la misión 2, 4.

-   **Datos de Dificultad:** Integración de las etiquetas de rango (RANK:
    ADVANCED) en las tarjetas de protocolo 2.

## v0.4: Motor de Ejecución (MVP)<a name="v04">:</a>

<!-- -->

-   **Pantalla de Ejecución de Protocolo (Nueva):** Implementación de la
    pantalla de trabajo real que sigue la arquitectura de
    **Subsistemas** y **Módulos** definida.

-   **Secuenciador de Módulos:** El sistema ya permite realizar los
    ejercicios uno tras otro (ej: 30x burpees -\> 30x situps) basándose
    en el array de datos del protocolo.

-   **Cronómetro de Misión:** Contador de tiempo real para la sesión
    actual.

## v0.5: Feedback en Tiempo Real<a name="v05">:</a>

<!-- -->

-   **Registro de Sesiones:** Las sesiones se guardan en la base de datos
    para futuros análisis.

-   **Barras de Progreso Dinámicas:** Las barras de neón de las tarjetas
    de protocolo reflejan el progreso real de la sesión en curso.

-   **Sincronización de Módulos:** Actualización del contador de módulos
    durante la ejecución.

## v0.6: Evolution Metrics & Histórico<a name="v06">:</a>

<!-- -->

-   **Gráficos de Rendimiento:** Conexión de la sección EVOLUTION_METRICS
    con la base de datos para mostrar la evolución de los últimos 7 días
    (LAST_7\_DAYS).

-   **Cálculo de Impacto:** Cálculo real de AVG_SESSIONS, AVG_CALORIES y el
    porcentaje de mejora (IMPROVEMENT) y eficiencia (EFFICIENCY)
    basado en las sesiones completadas.

-   **Resumen de sesión:** Implementación de la pantalla de resumen de sesión y
    reestructuración de la navegación al finalizar un protocolo.

## v0.7: Achievement Matrix and Personal Record<a name="v07">:</a>

<!-- -->

-   **Desbloqueo de Hitos:** Funcionalidad para activar los iconos de la
    ACHIEVEMENT_MATRIX (como FIRE_STARTER o IRON_CORE) cuando el usuario
    alcanza ciertos objetivos.

-   **Resumen de Carrera:** Activación de los contadores totales de SESSIONS,
    CALORIES y EFFICIENCY.

-   **Comparativa de Rendimiento:** Implementación del marcador de PB en las
    barras de progreso de cada protocolo para comparar la sesión actual con
    el mejor registro anterior.

## v0.8: Audio Uplink & Media Control<a name="v08">:</a>

<!-- -->

-   **Mini-reproductor:** Integración de la barra de audio justo encima
    del footer técnico (según conversación previa).

-   **Progreso Musical:** Barra de progreso de neón magenta para la pista
    de audio actual sin indicadores numéricos.

## v0.9: CORE_CONFG & ARCHITECHT<a name="v09">:</a>

<!-- -->

-   **Pantalla de configuración CORE_CONFIG:** Ajuste de las distintas
    opciones del sistema, así como guardado en la base de datos y acceso
    al ARCHITECT.
    
-   **Pantalla de configuración ARCHITECHT:** Edición y creación de
    directivas, protocolos y módulos.

## v1.0: Full System Online<a name="v10">:</a>

<!-- -->

-   **Efectos Visuales Finales:** Implementación de las líneas de escaneo
    (*scanlines*) y efectos de terminal para una inmersión total.

-   **Build de Producción:** Estabilización de todas las conexiones entre
    el Backend (C++) y la UI (QML).