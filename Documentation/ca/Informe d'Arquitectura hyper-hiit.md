Taula de continguts

[1. Fonaments de l'Arquitectura d'Array Estructurat
3](#fonaments-de-larquitectura-darray-estructurat)

[2. Agrupament Visual Dinàmic via subsistema_id
3](#agrupament-visual-dinàmic-via-subsistema_id)

[3. Gestió del Flux de Missió: Mòduls de Transició i Descans
3](#gestió-del-flux-de-missió-mòduls-de-transició-i-descans)

[4. Versatilitat de Dades: El Camp unitat_tipus
3](#versatilitat-de-dades-el-camp-unitat_tipus)

[5. Càlcul Automàtic de Mètriques de Protocol
4](#càlcul-automàtic-de-mètriques-de-protocol)

[6. Exemple d'Implementació: 4](#exemple-dimplementació)

- [Protocol INFERNO_SEQUENCE 4](#protocol-inferno_sequence)

[7. Arquitectura Jeràrquica del Sistema 5](#arquitectura-jeràrquica-del-sistema)

[8. Model de Dades: Taules Mestres i Relacionals 5](#model-de-dades-taules-mestres-i-relacionals)

- [Taula: Modules 5](#taula-modules)

- [Taula: directives 5](#taula-directives)

- [Taula: protocols 5](#taula-protocols)

- [Taula de mapeig: directive_protocols 6](#taula-de-mapeig-directive_protocols)

- [Taula de mapeig: protocol_structure 6](#taula-de-mapeig-protocol_structure)

[9. Lògica de l'Array Estructurat i Processament de Dades
6](#lògica-de-larray-estructurat-i-processament-de-dades)

- [Algorismes de Càlcul de Mètriques
6](#algorismes-de-càlcul-de-mètriques)

[10. Arquitectura del fitxer JSON 7](#arquitectura-del-fitxer-json)

[11. Regles d'UX i Disseny d'Interfície (Mission Flow)
8](#regles-dux-i-disseny-dinterfície-mission-flow)

- [Flux de Missió (Mission Flux) 8](#flux-de-missió-mission-flux)

- [Indicadors de Rang (RANK labels) 8](#indicadors-de-rang-rank-labels)

- [Visualització d'Eficiència i Progressió
9](#visualització-deficiència-i-progressió)

- [Requisits Visuals del Sistema (System Footer)
9](#requisits-visuals-del-sistema-system-footer)

[12. Exemple d'Implementació de Protocol
9](#exemple-dimplementació-de-protocol)

[13. Llistat preliminar de protocols
10](#llistat-preliminar-de-protocols)

- [A. FAT_BURNING (Metabolic acceleration protocol)
10](#fat_burning-metabolic-acceleration-protocol)

- [B. CARDIO_ENHANCEMENT (Cardiovascular optimization system)
10](#cardio_enhancement-cardiovascular-optimization-system)

- [C. STRENGTH_MATRIX (Muscular fortification sequence)
10](#strength_matrix-muscular-fortification-sequence)

- [D. ENDURANCE_GRID (Stamina amplification framework)
11](#endurance_grid-stamina-amplification-framework)

- [E. NEURAL_FLOW (Neural-synaptic synchronization)
11](#neural_flow-neural-synaptic-synchronization)

- [Implementació Tècnica 11](#implementació-tècnica)

[14. Ruta de versions 12](#ruta-de-versions)

- [v0.1: Core Terminal & Shell 12](#v0.1-core-terminal-shell)

- [v0.2: Sistema de Navegació de Directives 12](#v0.2-sistema-de-navegació-de-directives)

- [v0.3: Gestió de Protocols & Scroll 12](#v0.3-gestió-de-protocols-scroll)

- [v0.4: Motor d'Execució (MVP) 13](#v0.4-motor-dexecució-mvp)

- [v0.5: Feedback en Temps Real 13](#v0.5-feedback-en-temps-real)

- [v0.6: Evolution Metrics & Històric 13](#v0.6-evolution-metrics-històric)

- [v0.7: Achievement Matrix 13](#v0.7-achievement-matrix)

- [v0.8: Audio Uplink & Media Control 13](#v0.8-audio-uplink-media-control)

- [v0.9: Personal Best (PB) & Benchmarks 13](#v0.9-personal-best-pb-benchmarks)

- [v1.0: Full System Online 14](#v1.0-full-system-online)

# Fonaments de l'Arquitectura d'Array Estructurat

L'esquelet operatiu del sistema hyper//hiit s'articula mitjançant una
arquitectura d'array estructurat basada en un mapeig relacional d'alta
densitat. Aquesta elecció no és merament estètica; és la solució òptima
per a un terminal de rendiment tàctic que requereix una reducció
dràstica de la càrrega cognitiva de l'usuari sota condicions de fatiga
extrema.

L'ús d'aquesta estructura garanteix els següents avantatges competitius:

-   **Escalabilitat sense Canvis de Codi:** L'addició de nous exercicis
    > o mòduls tàctics només requereix una nova entrada a la taula de
    > mapeig, sense necessitat de modificar el motor de renderitzat en
    > C++.

-   **Integració de Baixa Latència amb el Backend:** El motor en C++
    > processa l'array de forma nativa, assegurant una sincronització
    > biomètrica en temps real (Neural Sync).

-   **Llegibilitat Tàctica:** L'estructura de dades permet una jerarquia
    > visual neta, prioritzant la informació crítica per mantenir el
    > rendiment sota pressió física.

# Agrupament Visual Dinàmic via subsistema_id

El camp subsistema_id actua com el motor de segmentació del sistema. La
interfície utilitza aquesta clau per generar automàticament separadors i
capçaleres dinàmiques (com **SUBSYSTEM_01** o **PHASE_A**), eliminant la
necessitat de taules visuals predefinides i rígides.

Aquesta funcionalitat permet que la directiva activa (com
**FAT_BURNING** o **STRENGTH_MATRIX**) mantinga l'estètica "cyberpunk"
característica: una interfície modular on cada fase de l'entrenament es
presenta com un objectiu tàctic segmentat. Aquest disseny facilita la
navegació visual ràpida durant protocols d'alta intensitat on l'atenció
de l'usuari és limitada.

# Gestió del Flux de Missió: Mòduls de Transició i Descans

Una de les decisions d'arquitectura d'UX més estratègiques ha estat la
integració de períodes de descans i transicions mitjançant un module_id
especialitzat. Des de la perspectiva de sistemes, això permet que el
backend gestione una **màquina d'estats única** per a tota la missió,
evitant la complexitat de gestionar estats de "pausa" i "activitat" com
a lògiques separades.

Els avantatges d'aquest disseny inclouen:

-   **Integritat Cronomètrica:** El cronòmetre de la missió és continu,
    > garantint una telemetria precisa de la sessió completa.

-   **Continuïtat del Flux:** L'usuari rep instruccions clares de
    > **"REST"** o **"TRANSIT"** com a part orgànica de la seqüència,
    > evitant trencar el ritme operatiu.

# Versatilitat de Dades: El Camp unitat_tipus

El camp unitat_tipus és fonamental per a la rigorositat de la base de
dades i la seva alineació amb la sincronització biomètrica. Aquest
atribut defineix la naturalesa de la variable numèrica, permetent que el
sistema interprete correctament l'esforç requerit per a cada mòdul.

| Valor Numèric | unitat_tipus | Interpretació del Sistema                     |
|---------------|--------------|-----------------------------------------------|
| 30            | repeticions  | Execució física de 30 unitats (ex: Burpees)   |
| 30            | segons       | Durada temporal de 30s (ex: Planxa o Descans) |

# Càlcul Automàtic de Mètriques de Protocol

El backend de C++ realitza una extracció de dades en temps real de
l'array per generar les mètriques d'execució que es mostren a la
interfície d'usuari:

1.  **MODULES:** Realitza un comptatge simple de les entrades (files) de
    > l'array assignades a un protocol específic.

2.  **DURATION:** Executa la suma del producte de cada valor de
    > repetició pel seu **temps base** corresponent. Aquest "temps base"
    > es recupera mitjançant una cerca relacional a la base de dades
    > utilitzant el module_id com a clau primària, garantint una
    > estimació temporal exacta.

# Exemple d'Implementació: 

## Protocol INFERNO_SEQUENCE

Basat en la telemetria de la interfície actual sota la directiva
**FAT_BURNING**, així es renderitza la jerarquia de dades:

-   **PROTOCOL HEADER:** INFERNO_SEQUENCE

    -   **Metadades:** Duration: 20:00 \| Modules: 8 \| Completion: 85%

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

## 

Aquest document estableix l'especificació d'enginyeria per al terminal
d'alta tecnologia **hyper//hiit**. Com a Lead Solutions Architect,
l'objectiu és garantir una estructura de dades robusta sota una
interfície de tipus *Tactical Overlay* que maximitzi l'eficiència
operativa de l'usuari final.

# Arquitectura Jeràrquica del Sistema

L'arquitectura del sistema s'ha dissenyat com una pila jeràrquica de
quatre nivells, optimitzada per al processament en temps real pel motor
de dades de C++.

-   **Level 1: Directive:** El node superior de l'arbre. Defineix el
    > propòsit de la missió (ex: FAT_BURNING o STRENGTH_MATRIX). El
    > sistema manté un estat de ACTIVE_DIRECTIVE per filtrar els
    > protocols disponibles a la interfície.

-   **Level 2: Protocol:** Seqüències operatives vinculades a una
    > *Directive*. Exemples verificats: INFERNO_SEQUENCE (8 mòduls),
    > TORCH_PROTOCOL (6 mòduls).

-   **Level 3: Subsystem:** Segmentació lògica del flux de dades. Permet
    > agrupar mòduls en fases (Warm-up, Peak, Cool-down) facilitant un
    > "Agrupament Visual Dinàmic" a la UI sense sobrecarregar la base de
    > dades relacional.

-   **Level 4: Module:** La unitat atòmica d'execució. Representa una
    > acció física (Burpees) o un estat del sistema (REST).

# Model de Dades: Taules Mestres i Relacionals

Per garantir la integritat del *Neural Link* i la persistència de dades,
s'apliquen els següents esquemes SQL:

### Taula: Modules

Conté la definició base de cada unitat d'entrenament, així com la zona
de treball, la efectivitat i coeficient de fatiga.

CREATE TABLE IF NOT EXISTS modules (

module_id INTEGER PRIMARY KEY,

mod_name VARCHAR(100),

target_zone VARCHAR(50), -- Target area (e.g., FULL BODY)

difficulty INT -- 1: Begginer \| 2: Intermediate \| 3: Advanced

mod_description TEXT,

mod_instructions TEXT,

mod_safety TEXT,

mod_equipment TEXT,

unit_type INTEGER NOT NULL, -- 0: SECONDS \| 1: REPS \| 2: BREATH

rep_time FLOAT,

met_factor FLOAT, -- Efficiency constant

fatigue_rate FLOAT, -- Performance tier 1

);

### Taula: directives

Conté la definició de dadascuna de les directives a seguir per
aconseguir l’objectiu establert.

CREATE TABLE IF NOT EXISTS directives (

dir_id INTEGER PRIMARY KEY AUTOINCREMENT,

dir_name TEXT NOT NULL,

dir_description TEXT,

dir_icon TEXT,

dir_color TEXT

);

### Taula: protocols

Conté la informació base dels protocols sense incloure la seua
estructura de mòduls que s’enllaçarà en altra taula.

CREATE TABLE IF NOT EXISTS protocols (

protocol_id INTEGER PRIMARY KEY AUTOINCREMENT,

protocol_name TEXT NOT NULL,

estimated_duration INTEGER,

module_count INTEGER,

rank TEXT,

personal_best INTEGER

);

### Taula de mapeig: directive_protocols

Conté la relació entre el protocols i les directives que els inclouen.

CREATE TABLE IF NOT EXISTS directives_protocols (

dp_mapping_id INTEGER PRIMARY KEY AUTOINCREMENT,

dir_id INTEGER,

protocol_id INTEGER,

FOREIGN KEY(dir_id) REFERENCES directives(dir_id),

FOREIGN KEY(protocol_id) REFERENCES protocols(protocol_id)

);

### Taula de mapeig: protocol_structure

Conté la estructura executiva del protocols definint en un llistat únic
tots els mòduls d’un protocol.

CREATE TABLE IF NOT EXISTS protocol_structure (

p_map_id INTEGER PRIMARY KEY,

protocol_id INTEGER,

subsystem INTEGER,

s_order INT,

module_id INTEGER,

quantity INT,

UNIQUE (protocol_id, protocol_order),

FOREIGN KEY (protocol_id) REFERENCES protocols(protocol_id),

FOREIGN KEY (module_id) REFERENCES modules(module_id)

);

**Nota Tècnica sobre unit_type:** Aquest camp és crític per a la lògica
del backend. Determina si el valor quantity s'ha d'interpretar com un
enter de repeticions (ex: 30 Burpees) o com un comptador de temps en
segons (ex: 60 segons de Plank o de transició).

# Lògica de l'Array Estructurat i Processament de Dades

El backend de C++ genera un array dinàmic que la interfície utilitza per
renderitzar el flux de missió.

### Algorismes de Càlcul de Mètriques

Les següents fórmules s'apliquen per processar les dades abans de la
visualització:

-   **MODULE_COUNT:** Count = Total_Entries(Array) where protocol_id ==
    > active_protocol *(Exemple: INFERNO_SEQUENCE retorna 8).*

-   **DURATION:** TotalDuration = Σ (quantity_i \* base_time_i) *On
    > base_time* *es recupera de la taula de Modules* *per a cada
    > module_id.*

-   **FATIGUE_RATE:** Es un percentatge per a calcular el temps total
    > aproximat del modul multiplicant aquest pel nombre de repeticións
    > i el resultat pel temps de repetició. Quan s’importa desde JSON es
    > passa de percentatge a multiplicador (6.5% = 1,065). Per exemple:
    > module_time = estimated_duration \* (quantity \* fatigue_rate)

-   **MET_FACTOR:** és una unitat que s'utilitza per mesurar la
    > intensitat de l'activitat física i el consum d'oxigen. Per
    > definició, 1 MET equival al consum d'energia d'una persona en
    > repòs absolut (el metabolisme basal). Per calcular les
    > kilocalories (kcal) que cremes durant una activitat, s'utilitza la
    > següent fórmula estàndard: Calories = MET \* kg \* hours

L'ús de subsystem_id permet injectar separadors visuals a la UI de forma
automàtica, marcant les transicions entre fases d'intensitat sense
necessitat de lògica addicional al frontend.

# Arquitectura del fitxer JSON

Per tal de carregar i/o exportar les dades d’una manera més fàcil
utilitzarem un fitxer am format **JSON** amb la següent estructura
d’exemple:

{

"modules": \[

{

"module_name": "Rest",

"difficulty": 0,

"target_zone": "REST"

"description": "Take your time to rest",

"instructions": "Take your time to rest",

"safety_info": "Take your time to rest",

"equipment": \["NONE"\],

"unit_type": "seconds"

"met_factor": 12

"fatigue_rate": 6,5

"rep_time": 1

},

{

"module_name": "Burpees",

"difficulty": 1,

"target_zone": "FULL_BODY"

"module_description": "Plank, push-up and jump",

"instructions": "...",

"safety_info": "Keep core tight",

"equipment": \["NONE"\],

"unit_type": "reps"

"met_factor": 12

"fatigue_rate": 6,5

"rep_time": 3,7

},

"module_name": "Sit-ups",

"difficulty": 1,

"target_zone": "CORE_FLEX"

"module_description": "...",

"instructions": "...",

"safety_info": "Keep core tight",

"equipment": \["NONE"\],

"unit_type": "reps"

"met_factor": 4

"fatigue_rate": 2

"rep_time": 2,5

},

"module_name": "Squats",

"difficulty": 1,

"module_description": "...",

"instructions": "...",

"safety_info": "Keep core tight",

"equipment": \["NONE"\],

"target_zone": "LOWER_KNEE"

"unit_type": "reps"

"met_factor": 8

"fatigue_rate": 3

"rep_time": 3,25

}

\],

"directives": \[

{

"directive_name": "FAT_BURNING",

"directive_description": "Metabolic acceleration protocol",

"directive_icon": "\\ue0d2",

"directive_color": "#BF00FF"

},

{

"directive_name": "CARDIO_ENHANCEMENT",

"directive_description": "Cardiovascular optimization system",

"directive_icon": "\\ue0f2",

"directive_color": "#00FFF9"

}

\],

"protocols": \[

{

"protocol_name": "ARES_STRIKE",

"estimated_duration": 1200,

"module_count": 8,

"rank": "ADVANCED",

"personal_best": 85,

"target_directives": \["FAT_BURNING", "CARDIO_ENHANCEMENT"\],

"structure": \[

{

"order": 1

"subsystem": 1,

"module": "Burpees",

"quantity": 30,

"unit": "reps",

},

{

"order": 2

"subsystem": 1,

"module": "Sit-ups",

"quantity": 30,

"unit": "reps",

},

{

"order": 3

"subsystem": 1,

"module": "Squats",

"quantity": 30,

"unit": "reps",

},

\]

}

\]

}

# Regles d'UX i Disseny d'Interfície (Mission Flow)

La interfície s'ha concebut com una *Neural Interface* d'alt contrast,
seguint l'estètica cyberpunk funcional.

### Flux de Missió (Mission Flux)

Per mantenir la immersió total i la sincronització, el comptador global
de la missió mai s'atura. Això s'aconsegueix mitjançant el següent:

-   Injecció de module_id especials de tipus **REST** o **TRANSIT**.

-   Durant aquests mòduls, la UI mostra avisos de recuperació o
    > preparació, però el rellotge de missió roman actiu.

### Indicadors de Rang (RANK labels)

El sistema classifica la dificultat i el perfil d'accés en tres nivells:

-   newbie: Usuaris en fase d'iniciació.

-   advanced: Nivell d'elit (verificat en la vista STRENGTH_MATRIX de la
    > versió actual).

-   root: Màxim domini del sistema.

### Visualització d'Eficiència i Progressió

-   **Barra de Progrés:** Renderitza l'estat actual de la missió. Ha
    > d'incloure un marcador vertical que representi el **Personal Best
    > (PB)** per permetre una comparativa en temps real.

-   **Eficiència:** El sistema calcula el rendiment actual respecte a la
    > millor marca (ex: 89% EFFICIENCY).

### Requisits Visuals del Sistema (System Footer)

Tota interfície ha de mostrar de forma permanent les mètriques d'estat
del sistema al peu de pàgina:

-   **NEURAL_SYNC:** % de sincronització de l'usuari.

-   **LATENCY:** Temps de resposta (Requisit: \<1ms).

-   **BUILD:** Versió de l'entorn (Actual: v0.2.1-alpha, consultar
    > document “Ruta de versions”).

# Exemple d'Implementació de Protocol

Estructura d'un array de protocol complet segmentat per subsistemes:

-   **SUBSYSTEM_01 (Warm-up/Initial):**

    -   30x Burpees

    -   30x Situps

    -   30x Jacks

-   **TRANSIT_LINK:**

    -   60s Rest (*Module tipus transició*)

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

Aquest model d'array permet que el backend alimenti la UI amb dades
precises, mantenint el flux constant necessari per a l'experiència
**hyper//hiit**.

## Implementació Tècnica

Cadascun d'aquests noms actua com un protocol_id en la teva
**arquitectura d'array estructurat**. Recorda que:

-   El backend de C++ utilitzarà aquests noms per consultar la taula
    > protocol_structure i calcular automàticament els **MODULES** i la
    > **DURATION** que es mostren a la interfície.

-   Podràs assignar-los un **RANK** (newbie, advanced o root) per
    > diferenciar la dificultat visualment amb les etiquetes cian.

# Llistat preliminar de protocols

A continuació, tens les propostes de **10 protocols per a cada
directiva** activa al sistema **hyper//hiit**, mantenint el rigor visual
de terminal cyberpunk, evitant paraules dobles llargues i ajustant la
mida a referències com KINETIC_LINK:

## FAT_BURNING (Metabolic acceleration protocol)

Dissenyats per a una alta despesa calòrica.

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

Protocols optimitzats per a la freqüència cardíaca i la millora de
l'eficiència.

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

Noms que evoquen duresa i estructures sòlides, coherents amb la fita
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

Enfocats a la resistència sostinguda i la capacitat de mantenir el
sistema online durant períodes llargs.

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

Basats en la teva proposta per a l'equilibri i la sincronització,
reflectint l'estat de **NEURAL_SYNC** al 100%.

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

## 

# Ruta de versions

Aquest full de ruta prioritza la funcionalitat del nucli de l'aplicació
per garantir que el sistema siga usable per a l'entrenament en etapes
primerenques. Inicialment està dividit en 10 etapes per arantir un fluxe
constant de desenvolupament. S’establirà la versió 0.4 com a MVP
(Minimum Viable Product)

#### v0.1: Core Terminal & Shell

-   **Interfície Base:** Implementació del contenidor principal amb
    estètica dark mode i colors neó (cian i magenta) 1.

<!-- -->

-   **Header & Footer Tècnic:** Activació del logotip hyper//hiit amb
    efecte glow i el peu de pàgina funcional amb dades de LATENCY, BUILD
    i el marcador estàtic de NEURAL_SYNC: 100% 1, 2.

-   **Estructura de Seccions:** Definició dels espais per a
    EVOLUTION_METRICS, ACTIVE_DIRECTIVE i ACHIEVEMENT_MATRIX 1.

#### v0.2: Sistema de Navegació de Directives

-   **Lògica d'Acordió:** Implementació del mecanisme per desplegar i
    col·lapsar les directives (FAT_BURNING, CARDIO_ENHANCEMENT, etc.) 3,
    4.

-   **Selecció Activa:** Actualització de la capçalera de la secció
    segons la directiva seleccionada pel sistema 3.

-   **Indicadors d'Estat:** Integració d'icones Lucide (llamp, cor,
    etc.) i descripcions per a cada directiva 1, 3.

-   **Estructura de la Base de Dades:** Funcions de lectura i escritura
    bàsiques i carrega desde fitxer de dades Json.

#### v0.3: Gestió de Protocols & Scroll

-   **Mission Protocols List:** Implementació de la llista de protocols
    amb targetes individuals que mostren DURATION i MODULES 3, 4.

-   **Representació de Directives i protocols:** Lectura de base de
    dades i representació als components QML

-   **Navegació Vertical:** Activació de la barra de desplaçament
    (scrollbar) cian a la part dreta per navegar entre els protocols de
    la missió 2, 4.

-   **Dades de Dificultat:** Integració de les etiquetes de rang (RANK:
    ADVANCED) a les targetes de protocol 2.

#### v0.4: Motor d'Execució (MVP)

-   **Pantalla d'Execució de Protocol (Nou):** Implementació de la
    pantalla de treball real que segueix l'arquitectura de
    **Subsistemes** i **Mòduls** definida.

-   **Seqüenciador de Mòduls:** El sistema ja permet realitzar els
    exercicis un rere l'altre (ex: 30x burpees -\> 30x situps) basant-se
    en l'array de dades del protocol.

-   **Cronòmetre de Missió:** Comptador de temps real per a la sessió
    actual.

#### v0.5: Feedback en Temps Real

-   **Barres de Progrés Dinàmiques:** Les barres de neó de les targetes
    de protocol reflecteixen el progrés real de la sessió en curs 2, 4.

-   **Sincronització de Mòduls:** Actualització del comptador de mòduls
    restants durant l'execució.

#### v0.6: Evolution Metrics & Històric

-   **Gràfics de Rendiment:** Connexió de la secció EVOLUTION_METRICS
    amb la base de dades per mostrar l'evolució dels darrers 7 dies
    (LAST_7\_DAYS) 1, 4.

-   **Càlcul d'Impacte:** Càlcul real de AVG_SESSIONS, AVG_CALORIES i el
    percentatge d'millora (IMPROVEMENT) basat en les sessions
    completades 1.

#### v0.7: Achievement Matrix

-   **Desbloqueig de Fites:** Funcionalitat per activar les icones de la
    ACHIEVEMENT_MATRIX (com FIRE_STARTER o IRON_CORE) quan l'usuari
    assoleix certs objectius 1, 4.

-   **Resum de Carrera:** Activació dels comptadors totals de SESSIONS,
    CALORIES i EFFICIENCY 1.

#### v0.8: Audio Uplink & Media Control

-   **Mini-reproductor:** Integració de la barra d'àudio just a sobre
    del footer tècnic (segons conversa prèvia).

-   **Progrés Musical:** Barra de progrés de neó magenta per a la pista
    d'àudio actual sense indicadors numèrics.

#### v0.9: Personal Best (PB) & Benchmarks

-   **Comparativa de Rendiment:** Implementació del marcador de PB a les
    barres de progrés de cada protocol per comparar la sessió actual amb
    el millor registre anterior.

-   **Optimització de Ranks:** Ajust automàtic de la dificultat
    suggerida segons el rendiment històric de l'usuari.

#### v1.0: Full System Online

-   **Mode Architect:** Activació completa de les funcions de
    configuració a través de l'icona d'engranatge (ARCHITECT) 2.

-   **Efectes Visuals Finals:** Implementació de les línies d'escaneig
    (*scanlines*) i efectes de terminal per a una immersió total.

-   **Build de Producció:** Estabilització de totes les connexions entre
    el Backend (C++) i la UI (QML).
