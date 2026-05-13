Architecture Report hyper//hiit
================================

>    Rev. 45 (12/05/26)

&nbsp;

Table of Contents
-----------------

[1. Foundations of the Structured Array Architecture
](#1-foundations-of-the-structured-array-architecture)

[2. Dynamic Visual Grouping via subsistema_id
](#2-dynamic-visual-grouping-via-subsistema_id)

[3. Mission Flow Management: Transition and Rest Modules
](#3-mission-flow-management-transition-and-rest-modules)

[4. Data Versatility: The unitat_tipus Field
](#4-data-versatility-the-unitat_tipus-field)

[5. Automatic Protocol Metrics Calculation
](#5-automatic-protocol-metrics-calculation)

[6. Implementation Example:](#6-implementation-example)

- [Protocol INFERNO_SEQUENCE](#protocol-inferno_sequence)

[7. System Hierarchical Architecture](#7-system-hierarchical-architecture)

[8. Data Model: Master and Relational Tables](#8-data-model-master-and-relational-tables)

- [Table: Modules](#table-modules)

- [Table: directives](#table-directives)

- [Table: protocols](#table-protocols)

- [Mapping table: directive_protocols](#mapping-table-directive_protocols)

- [Mapping table: protocol_structure](#mapping-table-protocol_structure)

- [Table: ranks](#table-ranks)

- [Table session_history](#table-session_history)

[9. Structured Array Logic and Data Processing
](#9-structured-array-logic-and-data-processing)

- [Metrics Calculation Algorithms
](#metrics-calculation-algorithms)

[10. JSON File Architecture](#10-json-file-architecture)

[11. UX Rules and Interface Design (Mission Flow)
](#11-ux-rules-and-interface-design-mission-flow)

- [Mission Flow (Mission Flux)](#mission-flow-mission-flux)

- [Rank Indicators (RANK labels)](#rank-indicators-rank-labels)

- [Efficiency and Progression Visualisation
](#efficiency-and-progression-visualisation)

- [System Visual Requirements (System Footer)
](#system-visual-requirements-system-footer)

[12. Protocol Implementation Example
](#12-protocol-implementation-example)

- [Technical Implementation](#technical-implementation)

[13. Preliminary Protocol List by Directive
10](#13-preliminary-protocol-list-by-directive)

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

[14. Evolution Metrics:](#14-evolution-metrics)

- [IMPROVEMENT Algorithm
](#improvement-algorithm)

   - [A. Calculation Principle (Rolling Window)
](#a-calculation-principle-rolling-window)

   - [B. Power Index Formula (Session Score)
](#b-power-index-formula-session-score)

   - [C. Relative Speed Factor (Speed Factor)
](#c-relative-speed-factor-speed-factor)

   - [D. IMPROVEMENT Percentage Generation
](#d-improvement-percentage-generation)

- [EFFICIENCY Algorithm
](#efficiency-algorithm)

   - [A. Tactical Efficiency Foundation
](#a-tactical-efficiency-foundation)

   - [B. Weekly Calculation (Dashboard Integration)
](#b-weekly-calculation-dashboard-integration)

   - [C. Visual Hierarchy and UX
](#c-visual-hierarchy-and-ux)

   - [D. Low-Latency Implementation
](#d-low-latency-implementation)

- [AVG_SESSIONS and AVG_CALORIES
](#avg_sessions-and-avg_calories)

   - [A. Definition and Mathematical Calculation
](#a-definition-and-mathematical-calculation)

   - [B. Technical Implementation
](#b-technical-implementation)

[Version Roadmap](#version-roadmap)

- [v0.1: Core Terminal & Shell](#v01)

- [v0.2: Directive Navigation System](#v02)

- [v0.3: Protocol Management & Scroll](#v03)

- [v0.4: Execution Engine (MVP)](#v04)

- [v0.5: Real-Time Feedback](#v05)

- [v0.6: Evolution Metrics & History](#v06)

- [v0.7: Achievement Matrix and Personal Record](#v07)

- [v0.8: Audio Uplink & Media Control](#v08)

- [v0.9: CORE_CONFG & ARCHITECHT](#v09)

- [v1.0: Full System Online](#v10)

&nbsp;

&nbsp;

# 1. Foundations of the Structured Array Architecture

The operational skeleton of the hyper//hiit system is articulated through a
structured array architecture based on a high-density relational mapping.
This choice is not merely aesthetic; it is the optimal solution for a tactical
performance terminal that requires a drastic reduction of the user's cognitive
load under conditions of extreme fatigue.

The use of this structure guarantees the following competitive advantages:

-   **Scalability without Code Changes:**
    > Adding new exercises or tactical modules only requires a new entry in
    > the mapping table, with no need to modify the C++ rendering engine.

-   **Low-Latency Integration with the Backend:**
    > The C++ engine processes the array natively, ensuring real-time
    > biometric synchronisation (Neural Sync).

-   **Tactical Readability:**
    > The data structure allows a clean visual hierarchy, prioritising
    > critical information to maintain performance under physical pressure.

# 2. Dynamic Visual Grouping via subsistema_id

The subsistema_id field acts as the system's segmentation engine. The
interface uses this key to automatically generate dynamic separators and
headers (such as **SUBSYSTEM_01** or **PHASE_A**), eliminating the need for
predefined, rigid visual tables.

This functionality allows the active directive (such as **FAT_BURNING** or
**STRENGTH_MATRIX**) to maintain the characteristic "cyberpunk" aesthetic:
a modular interface where each training phase is presented as a segmented
tactical objective. This design facilitates rapid visual navigation during
high-intensity protocols where the user's attention is limited.

# 3. Mission Flow Management: Transition and Rest Modules

One of the most strategic UX architecture decisions has been the integration
of rest periods and transitions through a specialised module_id. From a
systems perspective, this allows the backend to manage a **single state
machine** for the entire mission, avoiding the complexity of handling "pause"
and "activity" states as separate logic.

The advantages of this design include:

-   **Chronometric Integrity:**
    > The mission timer is continuous, guaranteeing precise telemetry for
    > the entire session.

-   **Flow Continuity:**
    > The user receives clear **"REST"** or **"TRANSIT"** instructions as
    > an organic part of the sequence, avoiding any break in the operational
    > rhythm.

# 4. Data Versatility: The unitat_tipus Field

The unitat_tipus field is fundamental to the rigour of the database and its
alignment with biometric synchronisation. This attribute defines the nature
of the numeric variable, allowing the system to correctly interpret the effort
required for each module.

|               |              |                                               |
|---------------|--------------|-----------------------------------------------|
| Numeric Value | unitat_tipus | System Interpretation                         |
| 30            | repetitions  | Physical execution of 30 units (e.g.: Burpees) |
| 30            | seconds      | Time duration of 30s (e.g.: Plank or Rest)    |

# 5. Automatic Protocol Metrics Calculation

The C++ backend performs a real-time data extraction from the array to
generate the execution metrics displayed in the user interface:

1.  **MODULES:**
    > Performs a simple count of the array entries (rows) assigned to a
    > specific protocol.

2.  **DURATION:**
    > Executes the sum of the product of each repetition value by its
    > corresponding **base time**. This "base time" is retrieved through a
    > relational lookup in the database using the module_id as the primary
    > key, guaranteeing an exact time estimate.

# 6. Implementation Example: 

-   ## Protocol INFERNO_SEQUENCE

Based on the current interface telemetry under the **FAT_BURNING** directive,
the data hierarchy is rendered as follows:

-   **PROTOCOL HEADER:** INFERNO_SEQUENCE

    -   **Metadata:** Duration: 20:00 \| Modules: 8 \| Completion: 85%

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

This document establishes the engineering specification for the high-tech
**hyper//hiit** terminal. As Lead Solutions Architect, the objective is to
guarantee a robust data structure under a *Tactical Overlay* interface that
maximises the operational efficiency of the end user.

# 7. System Hierarchical Architecture

The system architecture has been designed as a four-level hierarchical stack,
optimised for real-time processing by the C++ data engine.

-   **Level 1: Directive:**
    > The top node of the tree. Defines the mission purpose (e.g.:
    > FAT_BURNING or STRENGTH_MATRIX). The system maintains an
    > ACTIVE_DIRECTIVE state to filter the available protocols in the
    > interface.

-   **Level 2: Protocol:**
    > Operative sequences linked to a *Directive*. Verified examples:
    > INFERNO_SEQUENCE (8 modules), TORCH_PROTOCOL (6 modules).

-   **Level 3: Subsystem:**
    > Logical segmentation of the data flow. Allows grouping modules into
    > phases (Warm-up, Peak, Cool-down), facilitating "Dynamic Visual
    > Grouping" in the UI without overloading the relational database.

-   **Level 4: Module:**
    > The atomic unit of execution. Represents a physical action (Burpees)
    > or a system state (REST).

# 8. Data Model: Master and Relational Tables

To guarantee the integrity of the *Neural Link* and data persistence, the
following SQL schemas are applied:

### Table: Modules

Contains the base definition of each training unit, as well as the target
zone, effectiveness and fatigue coefficient.

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
>   0: seconds  
>   1: repetitions  
>   2: breaths  
>   3: metres

### Table: directives

Contains the definition of each of the directives to follow in order to
achieve the established objective.

```sql

CREATE TABLE IF NOT EXISTS directives (
        dir_id INTEGER PRIMARY KEY AUTOINCREMENT,
        dir_name TEXT NOT NULL,
        dir_description TEXT,
        dir_icon TEXT,
        dir_color TEXT
);

```

### Table: protocols

Contains the base information of the protocols without including their
module structure, which will be linked in another table.

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

### Mapping table: directive_protocols

Contains the relationship between protocols and the directives that include
them.

```sql

CREATE TABLE IF NOT EXISTS directives_protocols (
        dp_mapping_id INTEGER PRIMARY KEY AUTOINCREMENT,
        dir_id INTEGER,
        protocol_id INTEGER,
        FOREIGN KEY(dir_id) REFERENCES directives(dir_id),
        FOREIGN KEY(protocol_id) REFERENCES protocols(protocol_id)
);

```

### Mapping table: protocol_structure

Contains the executive structure of the protocols, defining in a single list
all the modules of a protocol.

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

> **Technical Note on unit_type:** This field is critical for the backend
> logic. It determines whether the quantity value should be interpreted as
> a repetition integer (e.g.: 30 Burpees) or as a time counter in seconds
> (e.g.: 60 seconds of Plank or transition).

### Table: ranks

Contains the names of the different levels (normally three) of the protocols
and will be imported from the json file.

```sql

CREATE TABLE IF NOT EXISTS ranks(
        rank_level INTEGER PRIMARY KEY,
        rank_name TEXT NOT NULL UNIQUE
);

```

### Table: session_history

Contains the information of executed sessions and data for metrics and
statistics.

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

# 9. Structured Array Logic and Data Processing

The C++ backend generates a dynamic array that the interface uses to render
the mission flow.

## Metrics Calculation Algorithms

The following formulas are applied to process data prior to visualisation:

-   **MODULE_COUNT:**
    > Count = Total_Entries(Array) where protocol_id ==
    > active_protocol *(Example: INFERNO_SEQUENCE returns 8).*

-   **DURATION:**
    > TotalDuration = Σ (quantity_i \* base_time_i) *Where base_time is
    > retrieved from the Modules table for each module_id.*

-   **FATIGUE_RATE:**
    > A percentage used to calculate the approximate total time of the
    > module by multiplying it by the number of repetitions and the result
    > by the repetition time. When imported from JSON it is converted from
    > percentage to multiplier (6.5% = 1.065). For example:
    > module_time = estimated_duration \* (quantity \* fatigue_rate)

-   **MET_FACTOR:**
    > A unit used to measure the intensity of physical activity and oxygen
    > consumption. By definition, 1 MET equals the energy consumption of a
    > person at absolute rest (basal metabolism). To calculate the
    > kilocalories (kcal) burned during an activity, the following standard
    > formula is used: Calories = MET \* kg \* hours

The use of subsystem_id allows visual separators to be injected into the UI
automatically, marking the transitions between intensity phases without
requiring additional logic in the frontend.

# 10. JSON File Architecture

In order to load and/or export data more easily, a **JSON** format file will
be used with the following example structure:

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

# 11. UX Rules and Interface Design (Mission Flow)

The interface has been conceived as a high-contrast *Neural Interface*,
following a functional cyberpunk aesthetic.

### Mission Flow (Mission Flux)

To maintain total immersion and synchronisation, the global mission counter
never stops. This is achieved through the following:

-   Injection of special module_id entries of type **REST** or **TRANSIT**.

-   During these modules, the UI displays recovery or preparation notices,
    but the mission clock remains active.

### Rank Indicators (RANK labels)

The system classifies difficulty and access profile into three levels:

-   newbie: Users in the initiation phase.

-   advanced: Elite level (verified in the STRENGTH_MATRIX view of the
    current version).

-   root: Maximum system mastery.

### Efficiency and Progression Visualisation

-   **Progress Bar:** 
    > Renders the current state of the mission. Must include a vertical
    > marker representing the **Personal Record (PR)** to allow a real-time
    > comparison.

-   **Efficiency:** 
    > The system calculates current performance against the best record
    > (e.g.: 89% EFFICIENCY).

### System Visual Requirements (System Footer)

Every interface must permanently display system status metrics in the footer:

-   **NEURAL_SYNC:** % of user synchronisation.

-   **LATENCY:** Response time (Requirement: \<1ms).

-   **BUILD:** Environment version, refer to the "Version Roadmap" document.

# 12. Protocol Implementation Example

Structure of a complete protocol array segmented by subsystems:

-   **SUBSYSTEM_01 (Warm-up/Initial):**

    -   30x Burpees

    -   30x Situps

    -   30x Jacks

-   **TRANSIT_LINK:**

    -   60s Rest (*Transition type module*)

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

This array model allows the backend to feed the UI with precise data,
maintaining the constant flow necessary for the **hyper//hiit** experience.

## Technical Implementation

Each of these names acts as a protocol_id in your **structured array
architecture**. Remember that:

-   > The C++ backend will use these names to query the protocol_structure
    > table and automatically calculate the **MODULES** and **DURATION**
    > displayed in the interface.

-   > You will be able to assign them a **RANK** (newbie, advanced or root)
    > to visually differentiate difficulty using the cyan labels.

# 13. Preliminary Protocol List by Directive

Below are the proposals for **10 protocols per active directive** in the
**hyper//hiit** system, maintaining the cyberpunk terminal visual rigour,
avoiding long double words and adjusting length to references such as
KINETIC_LINK:

## FAT_BURNING (Metabolic acceleration protocol)

Designed for high caloric expenditure.

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

Protocols optimised for heart rate and efficiency improvement.

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

Names that evoke hardness and solid structures, consistent with the
**IRON_CORE** goal of the ACHIEVEMENT_MATRIX.

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

Focused on sustained endurance and the ability to keep the system online
for extended periods.

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

Based on the proposal for balance and synchronisation, reflecting the
**NEURAL_SYNC** state at 100%.

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

#  14. Evolution Metrics:

## IMPROVEMENT Algorithm

The IMPROVEMENT indicator, displayed in the EVOLUTION_METRICS section,
represents the growth of the user's tactical and metabolic performance
through a rolling time window comparison.

### A. Calculation Principle (Rolling Window)

The system does not use calendar weeks, but rather a 7-day rolling window
comparison to avoid data emptying every Monday:

- **Segment A (Current):** Sum of data from the last 7 days (T-0 to T-6).

- **Segment B (Base):** Sum of data from the immediately preceding 7 days
(T-7 to T-13).

- **Validation Rule:** Only protocols completed at 100% (COMPLETED status)
are counted. Partial sessions do not count towards evolution.

### B. Power Index Formula (Session Score)

For each session, the C++ backend generates a raw score based on four
performance vectors:

>   Score = ∑Cal + ( ∑Ranks × K ) + ( MET × n_reps ) + ( Total time × Speed )

-   **∑Cal:** Total calories burned (as integers for UX optimisation).

-   **∑Ranks × K:** Difficulty multiplier based on the protocol rank.
    -   Rank Constants (K): newbie = 1 | advanced = 5 | root = 10

-   **MET × n_reps:** Actual mechanical work volume, calculated according
    to the MET_FACTOR of each module and its quantity.

-   **Total time × Speed:** Temporal density factor.

### C. Relative Speed Factor (Speed Factor)

Speed is a comparative metric stored in *session_history* that measures
temporal efficiency against the last record of the same *protocol_id*:

>   Speed = ( Previous time / Current time )

-   **V > 1:** The user has surpassed their previous record (Ghost/PB
    effect).

-   **V < 1:** The user has completed a slower session than the previous
    reference.

### D. IMPROVEMENT Percentage Generation

The final IMPROVEMENT value is obtained through a simple cross-multiplication
that compares the sum of Segment A scores against Segment B (established as
the 100% baseline).

This data feeds the terminal visualisation in a high-contrast percentage
format (e.g.: +23%), enabling an immediate tactical reading of the subject's
real progress under the hyper//hiit system.

## EFFICIENCY Algorithm

The EFFICIENCY indicator, located in the EVOLUTION_METRICS block of the main
dashboard, measures the tactical consistency and quality of the user's
temporal execution in their recent missions. Unlike the Personal Best (PB),
which is an absolute historical metric, efficiency focuses on comparative
performance session to session.

### A. Tactical Efficiency Foundation

Efficiency is calculated using the Relative Speed Factor (Speed Index) stored
in the session_history table. This factor compares the time of the current
session with that of the immediately preceding session of the same
*protocol_id*.

-   Session Efficiency Formula:

>   Efficiency = ( Current time / Previous time ) × 100

-   Value Interpretation:

    -   **=100%:** Total consistency with respect to the last execution.
    -   **>100%:** Efficiency increase (system overclocking).
    -   **<100%:** Loss of rhythm or accumulated fatigue detected by the system.

### B. Weekly Calculation (Dashboard Integration)

The percentage value displayed in the interface (e.g.: 89% EFFICIENCY or
+48% according to the latest telemetry) represents the arithmetic mean of
the efficiencies of all sessions completed in the current 7-day segment.

-   **Comparison Algorithm:** In the same way as IMPROVEMENT, the system
    compares the average efficiency of Segment A (T-0 to T-6) with that of
    Segment B (T-7 to T-13) to determine whether the consistency trend is
    positive or negative.

### C. Visual Hierarchy and UX

To avoid cognitive overload, the system clearly separates the three temporal
performance indicators:

1. **Horizontal Bar (Protocol Card):** Indicates the estimated total load or
duration of the protocol.

2. **Vertical Marker (Personal Best):** Indicates the absolute historical
record (PR) recorded in the protocols table.

3. **EFFICIENCY Label (Evolution Metrics):** Indicates the user's ability to
maintain or improve their current work pace relative to their most recent
sessions.

### D. Low-Latency Implementation

The efficiency calculation is performed in the C++ backend upon closing each
session (COMPLETED status), updating the speed_index field in the database.
This guarantees that the dashboard visualisation is rendered with a latency
of less than 1ms, meeting the system's technical requirements.

## AVG_SESSIONS and AVG_CALORIES

These metrics provide a reading of the user's baseline intensity and
consistency, complementing the visual information of the 7-day chart with
quantitative daily average data.

### A. Definition and Mathematical Calculation

Unlike other systems that display total sums, hyper//hiit uses the arithmetic
mean over Segment A (last 7 days) to guarantee precise telemetry that allows
decimal values:

-   **AVG_SESSIONS** (Average sessions per day):

>   AVG_SESSIONS = ∑SessionsCOMPLETED(T-0 to T-6) / 7

    - UX Note: The use of the mean allows decimal values to be shown
    (e.g.: 2.14), offering a view of training frequency beyond the active
    days visible in the chart.

-   **AVG_CALORIES** (Average calories per day):

>   AVG_CALORIES = ∑CaloriesCOMPLETED(T-0 to T-6) / 7

    - UX Note: Represents daily metabolic power. By dividing by the total
    days in the segment (7), the figure is independent of whether the user
    trained on a given day or not, reflecting the overall weekly activity
    level.

### B. Technical Implementation

-   **Processing:** The C++ backend performs the sum and division
    asynchronously when loading the dashboard or closing a session.

-   **Latency:** The result is served to the QML interface as a
    high-contrast numeric value, maintaining the system response requirement
    of <1ms.

-   **Coherence:** This data is automatically updated with the 7-day rolling
    window, ensuring that the "Tactical Overlay" is always synchronised with
    the subject's most recent performance.

# Version Roadmap

This roadmap prioritises the functionality of the application core to ensure
the system is usable for training in early stages. It is initially divided
into 10 stages to guarantee a constant development flow. Version 0.4 will be
established as the MVP (Minimum Viable Product).


## v0.1: Core Terminal & Shell<a name="v01">:</a>

<!-- -->

-   **Base Interface:** Implementation of the main container with dark mode
    aesthetic and neon colours (cyan and magenta) 1.

-   **Technical Header & Footer:** Activation of the hyper//hiit logo with
    glow effect and the functional footer with LATENCY, BUILD data and the
    static NEURAL_SYNC: 100% marker 1, 2.

-   **Section Structure:** Definition of the spaces for EVOLUTION_METRICS,
    ACTIVE_DIRECTIVE and ACHIEVEMENT_MATRIX 1.

## v0.2: Directive Navigation System<a name="v02">:</a>

<!-- -->

-   **Accordion Logic:** Implementation of the mechanism to expand and
    collapse directives (FAT_BURNING, CARDIO_ENHANCEMENT, etc.) 3, 4.

-   **Active Selection:** Update of the section header according to the
    directive selected by the system 3.

-   **Status Indicators:** Integration of Lucide icons (lightning bolt,
    heart, etc.) and descriptions for each directive 1, 3.

-   **Database Structure:** Basic read and write functions and loading from
    Json data file.

## v0.3: Protocol Management & Scroll<a name="v03">:</a>

<!-- -->

-   **Mission Protocols List:** Implementation of the protocol list with
    individual cards showing DURATION and MODULES 3, 4.

-   **Directive and Protocol Rendering:** Database reading and rendering in
    QML components.

-   **Vertical Navigation:** Activation of the cyan scrollbar on the right
    side to navigate between mission protocols 2, 4.

-   **Difficulty Data:** Integration of rank labels (RANK: ADVANCED) in
    protocol cards 2.

## v0.4: Execution Engine (MVP)<a name="v04">:</a>

<!-- -->

-   **Protocol Execution Screen (New):** Implementation of the real work
    screen that follows the defined **Subsystems** and **Modules**
    architecture.

-   **Module Sequencer:** The system already allows exercises to be performed
    one after another (e.g.: 30x burpees -\> 30x situps) based on the
    protocol data array.

-   **Mission Timer:** Real-time counter for the current session.

## v0.5: Real-Time Feedback<a name="v05">:</a>

<!-- -->

-   **Session Log:** Sessions are saved to the database for future analysis.

-   **Dynamic Progress Bars:** The neon bars on protocol cards reflect the
    real progress of the ongoing session.

-   **Module Synchronisation:** Update of the module counter during
    execution.

## v0.6: Evolution Metrics & History<a name="v06">:</a>

<!-- -->

-   **Performance Charts:** Connection of the EVOLUTION_METRICS section with
    the database to display the evolution of the last 7 days (LAST_7\_DAYS).

-   **Impact Calculation:** Real calculation of AVG_SESSIONS, AVG_CALORIES
    and the improvement percentage (IMPROVEMENT) and efficiency (EFFICIENCY)
    based on completed sessions.

-   **Session Summary:** Implementation of the session summary screen and
    navigation restructuring upon completing a protocol.

## v0.7: Achievement Matrix and Personal Record<a name="v07">:</a>

<!-- -->

-   **Milestone Unlocking:** Functionality to activate the icons of the
    ACHIEVEMENT_MATRIX (such as FIRE_STARTER or IRON_CORE) when the user
    reaches certain objectives.

-   **Career Summary:** Activation of the total counters for SESSIONS,
    CALORIES and EFFICIENCY.

-   **Performance Comparison:** Implementation of the PB marker in the
    progress bars of each protocol to compare the current session with the
    previous best record.

## v0.8: Audio Uplink & Media Control<a name="v08">:</a>

<!-- -->

-   **Mini-player:** Integration of the audio bar just above the technical
    footer (as per previous discussion).

-   **Music Progress:** Magenta neon progress bar for the current audio
    track without numeric indicators.

## v0.9: CORE_CONFG & ARCHITECHT<a name="v09">:</a>

<!-- -->

-   **CORE_CONFIG Settings Screen:** Adjustment of the various system
    options, as well as saving to the database and access to the ARCHITECT.

-   **ARCHITECHT Settings Screen:** Editing and creation of directives,
    protocols and modules.

## v1.0: Full System Online<a name="v10">:</a>

<!-- -->

-   **Final Visual Effects:** Implementation of scanlines and terminal
    effects for total immersion.

-   **Production Build:** Stabilisation of all connections between the
    Backend (C++) and the UI (QML).