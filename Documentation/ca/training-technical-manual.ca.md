Manual Tècnic Esportiu — HYPER//HIIT
====================================

>  **Revisió:** 19 · **Data:** 2026-05-14  

&nbsp;

**Àmbit:** Fisiologia de l'esforç, protocols d'entrenament i model de despesa calòrica.  
**Nota:** Aquest document és la referència esportiva i fisiològica del projecte. La documentació de l'arquitectura de l'aplicació, les estructures de dades i la lògica de programació es troben al *whitepaper* tècnic.

---

&nbsp;

Taula de continguts
-------------------

1. [Fonaments del HIIT](#1-fonaments-del-hiit)
2. [Protocols Fisiològics Principals](#2-protocols-fisiològics-principals)
3. [Model de Despesa Calòrica](#3-model-de-despesa-calòrica)
4. [Equilibri Biomecànic i Categorització d'Exercicis](#4-equilibri-biomecànic-i-categorització-dexercicis)
5. [Intensitat Subjectiva: Escala RPE de Borg Modificada](#5-intensitat-subjectiva-escala-rpe-de-borg-modificada)
6. [Protocols Basats en Volum (Repeticions)](#6-protocols-basats-en-volum-repeticions)
   - [FAT\_BURNING: STRIKE](#fat_burning-strike)
   - [FAT\_BURNING: METABOLIX](#fat_burning-metabolix)
   - [FAT\_BURNING: PYROGEN](#fat_burning-pyrogen)
   - [CARDIO\_ENHANCEMENT: AEROBYTE](#cardio_enhancement-aerobyte)
   - [CARDIO\_ENHANCEMENT: PULSE\_ID](#cardio_enhancement-pulse_id)
   - [CARDIO\_ENHANCEMENT: VO2\_MAX\_ST](#cardio_enhancement-vo2_max_st)
   - [STRENGTH\_MATRIX: TITANIUM](#strength_matrix-titanium)
   - [STRENGTH\_MATRIX: GOLIATH](#strength_matrix-goliath)
   - [STRENGTH\_MATRIX: IRON\_STORM](#strength_matrix-iron_storm)
   - [STRENGTH\_MATRIX: REINFORCE](#strength_matrix-reinforce)
   - [ENDURANCE\_GRID: STEEL\_CORE](#endurance_grid-steel_core)
   - [ENDURANCE\_GRID: STAMINA](#endurance_grid-stamina)
   - [ENDURANCE\_GRID: STEADFAST](#endurance_grid-steadfast)
   - [ENDURANCE\_GRID: LASTING](#endurance_grid-lasting)
7. [Lògica de Programació de Protocols](#7-lògica-de-programació-de-protocols)

---

## 1. Fonaments del HIIT

L'entrenament d'alta intensitat per intervals (HIIT, *High-Intensity Interval Training*) es defineix per sessions repetides d'esforç supramàxim o d'alta intensitat, separades per períodes de recuperació activa o passiva de baixa intensitat. Les adaptacions fisiològiques principals que persegueix HYPER//HIIT són:

- **Cardiovasculars:** Millora del volum sistòlic, de la densitat capil·lar i del *VO₂* màx.
- **Metabòliques:** Augment de la densitat mitocondrial, sensibilitat a la insulina i oxidació de substrats lipídics.
- **Neuromusculars:** Millora del reclutament d'unitats motores i de la resistència a la fatiga muscular local.

L'objectiu del sistema és maximitzar aquestes adaptacions en el mínim temps possible mitjançant protocols estructurats i progressius.

---

## 2. Protocols Fisiològics Principals

El sistema implementa quatre protocols com a marcs fisiològics de referència. Cada protocol de la biblioteca d'entrenaments deriva d'un d'aquests quatre estàndards.

### A. Protocol AFAP (*As Fast As Possible*) — Estàndard de Volum i Densitat

- **Font:** Metodologia de resistència metabòlica (*cross-training* contemporani).
- **Ràtio Treball/Descans:** Sense descans programat. L'usuari gestiona les pauses de manera autònoma amb l'objectiu de no aturar el moviment completament (*rest-pause*).
- **Estructura:** Variable basada en repeticions (piràmide descendent, piràmide ascendent o rondes fixes). El temps total és la variable dependent i la mètrica de rendiment.
- **Intensitat Objectiu:** Llindar de lactat elevat (80–90% de la *FC*màx). L'objectiu és mantenir una potència de sortida constant malgrat la fatiga acumulada.
- **Adaptació principal:** Resistència muscular, tolerància a l'àcid làctic i resiliència mental. La progressió es mesura completant el mateix volum de treball en menys temps (millora de la *densitat d'entrenament*).

### B. Protocol AMRAP (*As Many Rounds As Possible*) — Estàndard de Màxima Eficiència

- **Font:** Protocols de condicionament metabòlic (MetCon).
- **Ràtio Treball/Descans:** Treball continu durant un temps fix preestablert.
- **Estructura:** Finestra temporal fixa (10, 15 o 20 minuts). L'usuari ha de completar el màxim nombre de voltes o repeticions possible.
- **Intensitat Objectiu:** Esforç submàxim constant. S'optimitza el "ritme de creuer" sense arribar a l'esgotament total prematur.
- **Adaptació principal:** Capacitat de treball aeròbic-anaeròbic sostingut. Permet mesurar objectivament la millora en completar més rondes en sessions successives.

### C. Protocol Tabata — Estàndard Elit

- **Font:** Izumi Tabata et al. (1996). *Medicine & Science in Sports & Exercise.*
- **Ràtio Treball/Descans:** 20 s de treball d'ultra-alta intensitat / 10 s de descans passiu.
- **Estructura:** 8 rondes (durada total: 4 minuts).
- **Intensitat Objectiu:** ~170% del *VO₂* màx (esforç supramàxim).
- **Adaptació principal:** Capacitat anaeròbica i *VO₂* màx. Protocol estrictament per a usuaris d'un nivell avançat consolidat, atès que l'esforç supramàxim requereix una base cardiovascular i neuromuscular sòlida per evitar lesions.

### D. Mètode Gibala/Little — Estàndard Intermedi

- **Font:** Martin Gibala i Jonathan Little (2009–2010). *Journal of Physiology.*
- **Ràtio Treball/Descans:** 60 s d'alta intensitat / 75 s de recuperació de baixa intensitat.
- **Estructura:** De 8 a 12 rondes.
- **Intensitat Objectiu:** ~95% de la *FC*màx.
- **Adaptació principal:** Densitat mitocondrial i sensibilitat a la insulina, sense l'estrès metabòlic extrem dels protocols supramaximals. Adequat com a pas previ al Tabata.

---

## 3. Model de Despesa Calòrica

### 3.1. Fórmula de càlcul

El sistema utilitza la fórmula estàndard derivada de la taula MET (*Metabolic Equivalent of Task*, Ainsworth et al., 2011), corregida per un factor de fatiga específic de cada exercici i un corrector demogràfic d'edat i sexe:

```
kcal = MET × pes_kg × (durada_s / 3600) × factor_fatiga × corrector_demogràfic
```

### 3.2. Paràmetres

**MET (Equivalent Metabòlic de la Tasca)**
Representa el cost energètic d'un exercici en múltiples del metabolisme basal en repòs (1 MET ≈ 3,5 ml O₂/kg/min). Els valors de referència emprats procedeixen del *Compendium of Physical Activities* (Ainsworth et al., 2011). Valors de referència principals:

| Exercici | MET |
|---|---|
| Burpees (intensitat alta) | 11.0 |
| High Knees / Shadow Boxing intens | 9.0 |
| Mountain Climbers / Seal Jacks | 8.0 |
| Squat Thrusts / Jumping Jacks / Fast Feet | 8.0 |
| Lateral Skaters / Shadow Boxing | 7.5–7.0 |
| Archer Squats / Bulgarian Split Squats | 7.0 |
| Diamond / Decline Push-ups | 6.5–6.0 |
| Lunges / Step-ups | 6.0–5.5 |
| Air Squats / Sumo Squats | 5.5–5.0 |
| Plank Jacks / Mountain Climbers (lents) | 5.0 |
| Hollow Rocks / exercicis isomètrics | 3.5 |
| Glute Bridges | 3.5 |
| Sit-ups / Crunches | 3.0 |

**Factor de fatiga**
Coeficient adimensional que modela la variació del cost metabòlic real respecte al valor MET teòric en condicions de fatiga acumulada. Un exercici de gran demanda neuromuscular té un factor superior a 1.0; els períodes de recuperació activa o exercicis isomètrics estàtics poden tenir un factor inferior a 1.0.

| Tipus d'exercici | Factor de fatiga típic |
|---|---|
| Full body explosiu (burpees, squat thrusts) | 1.15–1.25 |
| Salts i moviments de alta coordinació | 1.10–1.15 |
| Força dinàmica (push-ups, squats) | 1.00–1.05 |
| Core dinàmic (sit-ups, mountain climbers) | 0.95–1.00 |
| Recuperació activa / isomètrics | 0.75–0.85 |

**Corrector demogràfic**
Modela les diferències en la despesa calòrica atribuïbles al sexe i l'edat, normalitzades sobre una referència de 30 anys:

```
corrector = 1.0 + factor_sexe + factor_edat

factor_sexe  = +0.05 (home) o −0.05 (dona)
factor_edat  = clamp( (30 − edat) × 0.003, −0.15, +0.10 )
```

El factor d'edat aplica una correcció de ±0.3% per any respecte als 30 anys, limitada a un rang de [−15%, +10%] per evitar extrapolacions no fisiològiques en edats extremes.

### 3.3. Efecte EPOC

El consum d'oxigen en excés postexercici (EPOC, *Excess Post-exercise Oxygen Consumption*) pot representar entre un 6% i un 15% addicional de la despesa calòrica total, en funció de la intensitat i la durada de la sessió. Les estimacions de despesa total (exercici + recuperació) que apareixen en les fitxes de protocol inclouen aquest factor de manera orientativa.

> **Nota:** Les calories indicades a cada protocol s'han calculat per a un perfil de referència neutre (adult, 75 kg, 30 anys) amb l'objectiu de facilitar la comparació entre protocols. L'aplicació recalcula aquests valors amb el perfil real de cada usuari.

---

## 4. Equilibri Biomecànic i Categorització d'Exercicis

### 4.1. Patrons de moviment primaris

Per prevenir el sobreentrenament i assegurar la integritat estructural de les sessions, el sistema classifica tots els exercicis en cinc patrons de moviment primaris:

| Patró | Descripció | Exemples |
|---|---|---|
| **Push (Empenta)** | Moviment de tren superior allunyant pes del cos. | Flexions, Pike push-ups, Fons. |
| **Pull (Tracció)** | Moviment de tren superior acostant pes al cos. | Dominades, Rem invertit, Supermans. |
| **Squat (Genoll dominant)** | Moviment de tren inferior on l'articulació dominant és el genoll. | Sentadilles, Salts verticals, Goblet squats. |
| **Hinge (Maluc dominant)** | Moviment de tren inferior on l'articulació dominant és el maluc. | Pont de gluti, Kettlebell swings, Pes mort. |
| **Lunge (Unilateral)** | Moviment de tren inferior unilateral. | Estocades, Split squats búlgars, Step-ups. |

A més, s'afegeix una sisena categoria transversal:

| Patró | Descripció | Exemples |
|---|---|---|
| **Full Body** | Exercicis multiarticulars que involucren simultàniament tren superior, inferior i core. Generen la major demanda cardiovascular. | Burpees, Mountain Climbers, Jumping Jacks, Squat Thrusts. |

### 4.2. Subcategorització per zona muscular

Cada patró es desglossa en zones funcionals per al sistema d'etiquetes intern:

| Tag | Zona | Descripció |
|---|---|---|
| `FULL_BODY` | Cos sencer | Exercicis globals de màxima intensitat cardiovascular. |
| `UPPER_PUSH` | Pit, espatlles, tríceps | Moviments d'empenta de tren superior. |
| `UPPER_PULL` | Esquena, bíceps | Moviments de tracció de tren superior. |
| `LOWER_KNEE` | Quàdriceps | Exercicis de tren inferior centrats en el genoll. |
| `LOWER_HINGE` | Gluti, isquiotibials | Exercicis de tren inferior centrats en el maluc. |
| `CORE` | Nucli | Estabilitat, antiextensió i flexió de tronc. |

### 4.3. Regles d'equilibri estructural

1. **Regla de consecutivitat:** Un protocol no pot incloure més de dos exercicis consecutius de la mateixa categoria `target_zone`. Això evita la fatiga muscular localitzada i l'estrès articular repetitiu.
2. **Regla d'equilibri push/pull:** Si un protocol inclou tres o més exercicis d'`UPPER_PUSH`, com a mínim un d'ells ha de tenir un exercici de contrapart `UPPER_PULL` en la mateixa sessió setmanal.
3. **Regla d'alternança genoll/maluc:** En protocols de tren inferior llargs (≥ 4 exercicis), s'ha d'alternar `LOWER_KNEE` i `LOWER_HINGE` per evitar la sobrecàrrega de l'articulació del genoll.

### 4.4. Algoritme d'equilibri per a protocols de 5 exercicis

La distribució de referència per a un protocol equilibrat de cinc exercicis és:

1. `FULL_BODY` — motor cardiovascular central.
2. `LOWER_KNEE` — treball de quàdriceps.
3. `UPPER_PUSH` — tren superior d'empenta.
4. `LOWER_HINGE` — treball de gluti i isquis.
5. `CORE` — estabilitat com a recuperació activa.

---

## 5. Intensitat Subjectiva: Escala RPE de Borg Modificada

El sistema utilitza l'escala de valoració de l'esforç percebut (RPE, *Rating of Perceived Exertion*) de Borg modificada en una escala de l'1 al 10 per calibrar la intensitat de les sessions i personalitzar futures recomanacions en funció del feedback de l'usuari.

| RPE | Classificació | Indicadors observables |
|---|---|---|
| 1–3 | Lleuger | Respiració còmoda; conversa fluida sense cap dificultat. |
| 4–6 | Moderat | Respiració profunda; es pot parlar en frases curtes. |
| 7–8 | Dur | Respiració molt pesada; dificultat notable per parlar. |
| 9 | Molt dur | Buscant l'aire; només es pot pronunciar una paraula. |
| 10 | Esforç màxim | Límit absolut; impossible parlar; esgotament complet. |

---

## 6. Protocols Basats en Volum (Repeticions)

A diferència dels protocols basats en el temps (Tabata/Gibala), els protocols de volum mesuren el rendiment per la **densitat de treball**: completar una càrrega de treball mecànica fixa en el menor temps possible.

**Mètrica de progrés (*Personal Record*):** La millora es demostra executant el mateix protocol en menys temps en sessions successives.

**Regla de tècnica (*Form Breakdown*):** La velocitat d'execució no és una mètrica vàlida si es produeix degradació de la tècnica. La qualitat del moviment té prioritat sobre el temps.

**Regla d'alternança articular:** En protocols de volum alt (≥ 100 repeticions per exercici), no s'han de combinar dos exercicis que carreguen la mateixa articulació de forma dominant (per exemple, evitar Jump Squats i Lunges en la mateixa piràmide).

> **Llegenda de les taules:** Les calories estimades s'han calculat amb la fórmula de la secció 3, usant el perfil de referència neutre (75 kg, 30 anys, corrector = 1.0). El factor de fatiga de cada ronda reflecteix l'increment del cost metabòlic per unitat de temps a mesura que s'acumula la fatiga.

---

### FAT\_BURNING: STRIKE

**Categoria:** Fat Burning · **Format:** Piràmide 30-15-30 · **Protocol base:** AFAP

**Estructura:**

| Subsistema | Exercici | Reps |
|---|---|---|
| SUBSYSTEM 1 | Burpees | 30 |
| | Sit-ups | 30 |
| | Lunges | 30 |
| SUBSYSTEM 2 | Burpees | 15 |
| | Sit-ups | 15 |
| | Lunges | 15 |
| SUBSYSTEM 3 | Burpees | 30 |
| | Sit-ups | 30 |
| | Lunges | 30 |

**Desglossament calòric (perfil de referència, 75 kg, 30 anys):**

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **RONDA 1** | Burpees | 30 | 2:30 min | 11.0 | 1.20 | 30.6 |
| (30 reps) | Sit-ups | 30 | 1:20 min | 3.0 | 0.95 | 5.3 |
| | Lunges | 30 | 1:15 min | 5.5 | 1.00 | 7.6 |
| **RONDA 2** | Burpees | 15 | 1:15 min | 11.0 | 1.20 | 15.3 |
| (15 reps) | Sit-ups | 15 | 0:40 min | 3.0 | 0.95 | 2.7 |
| | Lunges | 15 | 0:40 min | 5.5 | 1.00 | 4.1 |
| **RONDA 3** | Burpees | 30 | 3:00 min | 11.0 | 1.25 | 38.2 |
| (30 reps, fatiga) | Sit-ups | 30 | 1:30 min | 3.0 | 1.00 | 5.6 |
| | Lunges | 30 | 1:30 min | 5.5 | 1.05 | 9.7 |
| **TOTALS** | | **225 reps** | **~14 min** | | | **~119 kcal** |

> A la ronda 3, el temps per repetició augmenta a causa de la fatiga làctica, la qual cosa incrementa la despesa calòrica total en mantenir la freqüència cardíaca en zona anaeròbica durant més temps. Incloent l'efecte EPOC (~10–12%), la despesa total estimada se situa entre **130 i 140 kcal**.

**Racionalitat fisiològica:** La combinació de burpees (full body, MET 11.0), lunges (lower knee) i sit-ups (core) respecta l'equilibri biomecànic i manté la freqüència cardíaca per sobre del 80% de la *FC*màx durant tota la sessió, maximitzant la oxidació de substrats.

---

### FAT\_BURNING: METABOLIX

**Categoria:** Fat Burning · **Format:** Rondes iguals 20×4 · **Protocol base:** AFAP

**Exercicis:** Jumping Jacks (`FULL_BODY`) · Squat Thrusts (`FULL_BODY`) · Mountain Climbers (`CORE/FULL_BODY`)

**Racionalitat:** El format de rondes iguals permet mantenir un ritme de treball constant (*steady-state metabòlic*). La combinació de tres exercicis de tipus full body manté la demanda cardiovascular uniformement elevada, buscant el que s'anomena *metabolic conditioning*: maximitzar el consum d'oxigen per unitat de temps.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Jumping Jacks | 20 | 0:30 min | 8.0 | 1.00 | 4.4 |
| | Squat Thrusts | 20 | 1:00 min | 9.0 | 1.10 | 9.9 |
| | Mountain Climbers | 20/20 | 0:45 min | 8.0 | 1.05 | 7.0 |
| **Rondes 2–4** | (Igual que R1) | 3 × 120 | ~7:45 min | ~8.3 | 1.10–1.20 | ~65.1 |
| **TOTALS** | | **320 reps** | **~10 min** | | | **~86 kcal** |

> Despesa total estimada incloent EPOC (~12%): **~96 kcal**.

---

### FAT\_BURNING: PYROGEN

**Categoria:** Fat Burning · **Format:** Piràmide descendent 40-30-20-10 · **Protocol base:** AFAP

**Exercicis:** Lateral Skaters (`FULL_BODY`) · Reverse Lunges (`LOWER_KNEE`) · Bicycle Crunches (`CORE`)

**Racionalitat:** La piràmide descendent és psicològicament eficaç: la ronda més exigent es realitza quan el cos és fresc, i el volum decreix a mesura que s'acumula la fatiga, permetent mantenir la intensitat d'execució alta al llarg de tota la sessió. Els *Reverse Lunges* s'utilitzen en lloc dels endavant per reduir el moment de força sobre el genoll, afavorint la seguretat articular en sessions d'alt volum.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Lateral Skaters | 40 | 1:30 min | 7.5 | 1.15 | 19.4 |
| | Reverse Lunges | 40 | 2:00 min | 5.5 | 1.00 | 15.4 |
| | Bicycle Crunches | 40 | 1:00 min | 3.0 | 0.95 | 4.0 |
| **Ronda 2** | Lateral Skaters | 30 | 1:10 min | 7.5 | 1.15 | 15.0 |
| | Reverse Lunges | 30 | 1:30 min | 5.5 | 1.05 | 12.1 |
| | Bicycle Crunches | 30 | 0:45 min | 3.0 | 0.95 | 3.0 |
| **Ronda 3** | Lateral Skaters | 20 | 0:45 min | 7.5 | 1.15 | 9.6 |
| | Reverse Lunges | 20 | 1:00 min | 5.5 | 1.05 | 8.1 |
| | Bicycle Crunches | 20 | 0:30 min | 3.0 | 0.95 | 2.0 |
| **Ronda 4** | Lateral Skaters | 10 | 0:25 min | 7.5 | 1.15 | 5.4 |
| | Reverse Lunges | 10 | 0:30 min | 5.5 | 1.05 | 4.0 |
| | Bicycle Crunches | 10 | 0:15 min | 3.0 | 0.95 | 1.0 |
| **TOTALS** | | **300 reps** | **~11 min** | | | **~99 kcal** |

> Despesa total estimada incloent EPOC (~15% per la intensitat dels salts laterals): **~114 kcal**.

---

### CARDIO\_ENHANCEMENT: AEROBYTE

**Categoria:** Cardio Enhancement · **Format:** Rondes iguals 30×4 · **Protocol base:** AFAP

**Exercicis:** Jumping Jacks (`FULL_BODY`) · High Knees (`FULL_BODY`) · Mountain Climbers (`CORE/FULL_BODY`)

**Racionalitat:** A diferència del Fat Burning (que busca pics d'intensitat), Cardio Enhancement persegueix mantenir la freqüència cardíaca en zona aeròbica alta (75–85% *FC*màx) de forma sostinguda. Aquesta zona optimitza el desenvolupament del *VO₂* màx i la capacitat aeròbica de base. El volum total de 360 repeticions amb tres exercicis de baix impacte muscular i alta demanda cardiovascular produeix el que es coneix com a *fatiga central* (cor i pulmons) minimitzant la *fatiga perifèrica* (muscular local).

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Jumping Jacks | 30 | 0:45 min | 8.0 | 1.00 | 6.7 |
| | High Knees | 30/30 | 1:00 min | 9.0 | 1.10 | 9.9 |
| | Mountain Climbers | 30/30 | 1:00 min | 8.0 | 1.05 | 9.3 |
| **Ronda 2** | Jumping Jacks | 30 | 0:45 min | 8.0 | 1.05 | 7.0 |
| | High Knees | 30/30 | 1:00 min | 9.0 | 1.10 | 9.9 |
| | Mountain Climbers | 30/30 | 1:00 min | 8.0 | 1.10 | 9.8 |
| **Ronda 3** | Jumping Jacks | 30 | 0:50 min | 8.0 | 1.05 | 7.7 |
| | High Knees | 30/30 | 1:15 min | 9.0 | 1.10 | 12.4 |
| | Mountain Climbers | 30/30 | 1:15 min | 8.0 | 1.10 | 12.2 |
| **Ronda 4** | Jumping Jacks | 30 | 1:00 min | 8.0 | 1.10 | 9.8 |
| | High Knees | 30/30 | 1:15 min | 9.0 | 1.15 | 12.9 |
| | Mountain Climbers | 30/30 | 1:15 min | 8.0 | 1.15 | 12.8 |
| **TOTALS** | | **360 reps** | **~12 min** | | | **~120 kcal** |

---

### CARDIO\_ENHANCEMENT: PULSE\_ID

**Categoria:** Cardio Enhancement · **Format:** Piràmide descendent 40-30-20-10 · **Protocol base:** AFAP

**Exercicis:** Lateral Shuffles (`FULL_BODY`) · Butt Kicks (`FULL_BODY`) · Cross Jacks (`FULL_BODY`)

**Racionalitat:** La piràmide descendent en exercicis cardiovasculars permet iniciar amb el major volum quan la capacitat aeròbica és màxima, i anar guanyant velocitat d'execució a mesura que decreixen les repeticions. El resultat és una intensitat percebuda relativament constant al llarg de tota la sessió, una característica desitjable per a l'entrenament de la zona aeròbica.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Lateral Shuffles | 40 | 1:30 min | 7.5 | 1.00 | 12.5 |
| (40 reps) | Butt Kicks | 40/40 | 1:15 min | 8.0 | 1.00 | 11.1 |
| | Cross Jacks | 40 | 1:00 min | 8.0 | 1.00 | 8.9 |
| **Ronda 2** | Lateral Shuffles | 30 | 1:10 min | 7.5 | 1.05 | 10.2 |
| (30 reps) | Butt Kicks | 30/30 | 1:00 min | 8.0 | 1.05 | 9.3 |
| | Cross Jacks | 30 | 0:45 min | 8.0 | 1.05 | 7.0 |
| **Ronda 3** | Lateral Shuffles | 20 | 0:50 min | 7.5 | 1.05 | 7.3 |
| (20 reps) | Butt Kicks | 20/20 | 0:40 min | 8.0 | 1.05 | 6.2 |
| | Cross Jacks | 20 | 0:30 min | 8.0 | 1.05 | 4.7 |
| **Ronda 4** | Lateral Shuffles | 10 | 0:25 min | 7.5 | 1.05 | 3.6 |
| (10 reps) | Butt Kicks | 10/10 | 0:20 min | 8.0 | 1.05 | 3.1 |
| | Cross Jacks | 10 | 0:15 min | 8.0 | 1.05 | 2.3 |
| **TOTALS** | | **300 reps** | **~10 min** | | | **~86 kcal** |

---

### CARDIO\_ENHANCEMENT: VO2\_MAX\_ST

**Categoria:** Cardio Enhancement · **Format:** Piràmide ascendent 15-30-45 · **Protocol base:** AFAP

**Exercicis:** Seal Jacks (`FULL_BODY`) · Shadow Boxing (`UPPER_PUSH/FULL_BODY`) · Fast Feet (`FULL_BODY`)

**Racionalitat:** La piràmide ascendent és especialment eficaç per a l'entrenament del *VO₂* màx perquè obliga el sistema cardiovascular a adaptar-se progressivament a una demanda d'oxigen creixent. En iniciar amb baix volum, el cos s'escalfa adequadament i la intensitat d'execució de les últimes rondes —quan el volum és màxim— pot ser realment alta.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Seal Jacks | 15 | 0:25 min | 8.0 | 1.00 | 3.7 |
| (15 reps) | Shadow Boxing | 15/15 | 0:30 min | 7.0 | 1.00 | 4.0 |
| | Fast Feet | 15/15 | 0:20 min | 8.0 | 1.00 | 3.0 |
| **Ronda 2** | Seal Jacks | 30 | 0:50 min | 8.0 | 1.05 | 7.7 |
| (30 reps) | Shadow Boxing | 30/30 | 1:00 min | 7.0 | 1.05 | 8.2 |
| | Fast Feet | 30/30 | 0:45 min | 8.0 | 1.05 | 7.0 |
| **Ronda 3** | Seal Jacks | 45 | 1:20 min | 8.0 | 1.10 | 13.6 |
| (45 reps) | Shadow Boxing | 45/45 | 1:45 min | 7.0 | 1.10 | 15.9 |
| | Fast Feet | 45/45 | 1:15 min | 8.0 | 1.10 | 13.8 |
| **TOTALS** | | **270 reps** | **~9 min** | | | **~77 kcal** |

---

### STRENGTH\_MATRIX: TITANIUM

**Categoria:** Strength Matrix · **Format:** Piràmide 30-15-30 · **Protocol base:** AFAP

**Exercicis:** Diamond Push-ups (`UPPER_PUSH`) · Archer Squats (`LOWER_KNEE`) · V-Ups (`CORE`)

**Racionalitat:**
- **Diamond Push-ups:** La posició tancada de mans concentra la càrrega sobre el cap esternal del pectoral i els tríceps, incrementant la tensió mecànica respecte a les flexions convencionals.
- **Archer Squats:** Variant unilateral progressiva de la *Pistol Squat*. En desplaçar el 70–80% del pes cap a una sola cama, la tensió mecànica sobre el quàdriceps i el gluti és significativament superior a la del squat bilateral.
- **V-Ups:** Requereixen una contracció sinèrgica explosiva dels flexors de maluc i els rectes abdominals, amb major implicació de la cadena anterior que el sit-up convencional.

La ronda 2 (15 repeticions) s'executa amb èmfasi en el control excèntric (baixada de 3 s) per maximitzar el dany muscular i l'estímul de hipertròfia.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Diamond Push-ups | 30 | 2:00 min | 6.0 | 1.00 | 13.3 |
| (30 reps) | Archer Squats | 30 | 2:00 min | 6.5 | 1.00 | 14.4 |
| | V-Ups | 30 | 1:30 min | 3.5 | 0.95 | 7.0 |
| **Ronda 2** | Diamond Push-ups | 15 | 1:30 min | 6.5 | 1.00 | 10.8 |
| (15 reps, lent) | Archer Squats | 15 | 1:15 min | 7.0 | 1.00 | 9.8 |
| | V-Ups | 15 | 1:00 min | 3.5 | 0.95 | 4.7 |
| **Ronda 3** | Diamond Push-ups | 30 | 2:30 min | 6.0 | 1.05 | 17.5 |
| (30 reps, fatiga) | Archer Squats | 30 | 2:15 min | 6.5 | 1.05 | 17.1 |
| | V-Ups | 30 | 1:45 min | 3.5 | 1.00 | 8.6 |
| **TOTALS** | | **225 reps** | **~18 min** | | | **~103 kcal** |

> Tot i que la despesa calòrica és inferior a la dels protocols de Fat Burning, l'estímul de hipertròfia i el dany muscular estructural produït generen un efecte metabòlic residual (augment del metabolisme basal) que es manté durant 24–72 hores.

---

### STRENGTH\_MATRIX: GOLIATH

**Categoria:** Strength Matrix · **Format:** Piràmide descendent 20-15-10-8-5 · **Protocol base:** AFAP

**Exercicis:** Pike Push-ups (`UPPER_PUSH`) · Archer Squats (`LOWER_KNEE`) · Hollow Rocks (`CORE`)

**Racionalitat:** En la Strength Matrix, reduir el nombre de repeticions per ronda permet centrar l'esforç en la qualitat d'execució i la generació de força màxima per repetició, en lloc de delegar en la resistència cardiovascular. La piràmide descendent preserva la tècnica al llarg de tota la sessió, ja que el volum decreix a mesura que s'acumula la fatiga neuromuscular. Es recomana un descans actiu de 60–90 s entre rondes per permetre la ressíntesi parcial d'ATP i garantir la qualitat de la ronda següent.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Pike Push-ups | 20 | 1:30 min | 6.5 | 1.00 | 10.8 |
| (20 reps) | Archer Squats | 20 | 1:15 min | 7.0 | 1.00 | 9.8 |
| | Hollow Rocks | 20 | 1:00 min | 3.5 | 0.95 | 4.7 |
| **Ronda 2** | Pike Push-ups | 15 | 1:10 min | 6.5 | 1.00 | 8.4 |
| (15 reps) | Archer Squats | 15 | 1:00 min | 7.0 | 1.00 | 7.8 |
| | Hollow Rocks | 15 | 0:45 min | 3.5 | 0.95 | 3.5 |
| **Ronda 3** | Pike Push-ups | 10 | 0:50 min | 6.5 | 1.00 | 6.0 |
| (10 reps) | Archer Squats | 10 | 0:45 min | 7.0 | 1.00 | 5.9 |
| | Hollow Rocks | 10 | 0:30 min | 3.5 | 0.95 | 2.3 |
| **Ronda 4** | Pike Push-ups | 8 | 0:40 min | 6.5 | 1.00 | 4.8 |
| (8 reps) | Archer Squats | 8 | 0:35 min | 7.0 | 1.00 | 4.6 |
| | Hollow Rocks | 8 | 0:25 min | 3.5 | 0.95 | 1.9 |
| **Ronda 5** | Pike Push-ups | 5 | 0:30 min | 6.5 | 1.00 | 3.6 |
| (5 reps) | Archer Squats | 5 | 0:25 min | 7.0 | 1.00 | 3.2 |
| | Hollow Rocks | 5 | 0:20 min | 3.5 | 0.95 | 1.2 |
| **TOTALS** | | **174 reps** | **~13 min** | | | **~78 kcal** |

---

### STRENGTH\_MATRIX: IRON\_STORM

**Categoria:** Strength Matrix · **Format:** Rondes iguals 15×4 · **Protocol base:** AFAP

**Exercicis:** Diamond Push-ups (`UPPER_PUSH`) · Bulgarian Split Squats (`LOWER_KNEE`) · Plank Jacks (`CORE`)

**Racionalitat:** El format de rondes iguals facilita la planificació de l'esforç i afavoreix la consistència tècnica. Els *Bulgarian Split Squats* (15 repeticions per cama) generen una tensió unilateral molt superior al squat bilateral equivalent, activant de forma prioritzada el gluti i el quàdriceps de la cama de davant. Els *Plank Jacks* serveixen com a recuperació activa de tren superior entre les rondes d'`UPPER_PUSH` i `LOWER_KNEE`.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Diamond Push-ups | 15 | 1:00 min | 6.5 | 1.00 | 7.2 |
| | Bulgarian Split Squats | 15/cama | 2:00 min | 7.0 | 1.00 | 15.6 |
| | Plank Jacks | 15 | 0:45 min | 5.0 | 0.95 | 5.0 |
| **Ronda 2** | Diamond Push-ups | 15 | 1:05 min | 6.5 | 1.05 | 7.8 |
| | Bulgarian Split Squats | 15/cama | 2:10 min | 7.0 | 1.05 | 17.8 |
| | Plank Jacks | 15 | 0:50 min | 5.0 | 1.00 | 5.6 |
| **Ronda 3** | Diamond Push-ups | 15 | 1:10 min | 6.5 | 1.05 | 8.4 |
| | Bulgarian Split Squats | 15/cama | 2:20 min | 7.0 | 1.10 | 20.1 |
| | Plank Jacks | 15 | 0:55 min | 5.0 | 1.00 | 6.1 |
| **Ronda 4** | Diamond Push-ups | 15 | 1:15 min | 6.5 | 1.10 | 9.5 |
| | Bulgarian Split Squats | 15/cama | 2:30 min | 7.0 | 1.10 | 21.5 |
| | Plank Jacks | 15 | 1:00 min | 5.0 | 1.00 | 6.7 |
| **TOTALS** | | **240 reps** | **~18 min** | | | **~131 kcal** |

---

### STRENGTH\_MATRIX: REINFORCE

**Categoria:** Strength Matrix · **Format:** Piràmide ascendent 10-20-30 · **Protocol base:** AFAP

**Exercicis:** Decline Push-ups (`UPPER_PUSH`) · Sumo Squats amb pols (`LOWER_KNEE/HINGE`) · Leg Raises (`CORE`)

**Racionalitat:** La piràmide ascendent en el context de la Strength Matrix utilitza la ronda inicial (10 reps) com a activació neuromuscular pesada: permet establir la connexió ment-múscul i calibrar la tècnica quan la fatiga és mínima. La ronda final (30 reps) arriba a la fatiga total dels grups musculars diana, combinant el treball de força amb la resistència muscular. Els *Decline Push-ups* (peus elevats) desplacen la càrrega cap a la porció clavicular del pectoral i les espatlles.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Decline Push-ups | 10 | 0:45 min | 7.0 | 1.00 | 5.8 |
| (10 reps) | Sumo Squats amb pols | 10 | 0:40 min | 5.5 | 1.00 | 4.1 |
| | Leg Raises | 10 | 0:40 min | 3.0 | 0.95 | 2.7 |
| **Ronda 2** | Decline Push-ups | 20 | 1:40 min | 7.0 | 1.05 | 12.9 |
| (20 reps) | Sumo Squats amb pols | 20 | 1:30 min | 5.5 | 1.00 | 9.2 |
| | Leg Raises | 20 | 1:30 min | 3.0 | 0.95 | 6.0 |
| **Ronda 3** | Decline Push-ups | 30 | 2:45 min | 7.0 | 1.10 | 23.5 |
| (30 reps) | Sumo Squats amb pols | 30 | 2:15 min | 5.5 | 1.05 | 14.5 |
| | Leg Raises | 30 | 2:15 min | 3.0 | 1.00 | 9.6 |
| **TOTALS** | | **180 reps** | **~14 min** | | | **~88 kcal** |

---

### ENDURANCE\_GRID: STEEL\_CORE

**Categoria:** Endurance Grid · **Format:** Piràmide descendent 50-40-30-20-10 · **Protocol base:** AFAP

**Exercicis:** Burpees (`FULL_BODY`) · Air Squats (`LOWER_KNEE`) · Sit-ups (`CORE`)

**Racionalitat:** Amb 450 repeticions totals, STEEL_CORE és un repte de volum alt que persegueix la resistència muscular i cardiovascular pura. L'estructura piramidal descendent és clau: les primeres rondes consumeixen el 60% del volum total quan la capacitat de treball és màxima. A partir de la tercera ronda, el factor de fatiga làctica s'incrementa de forma notable: la cadència de burpees pot descendir de 11 reps/min (ronda 1) a 7–8 reps/min (rondes 4–5), mantenint la freqüència cardíaca prop del màxim durant més temps.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Burpees | 50 | 4:30 min | 11.0 | 1.20 | 66.0 |
| (50 reps) | Air Squats | 50 | 2:00 min | 5.0 | 1.00 | 11.1 |
| | Sit-ups | 50 | 2:15 min | 3.0 | 0.95 | 9.0 |
| **Ronda 2** | Burpees | 40 | 3:45 min | 11.0 | 1.22 | 55.5 |
| (40 reps) | Air Squats | 40 | 1:45 min | 5.0 | 1.00 | 9.7 |
| | Sit-ups | 40 | 1:50 min | 3.0 | 0.95 | 7.3 |
| **Ronda 3** | Burpees | 30 | 3:15 min | 11.0 | 1.25 | 48.8 |
| (30 reps) | Air Squats | 30 | 1:30 min | 5.0 | 1.00 | 8.3 |
| | Sit-ups | 30 | 1:30 min | 3.0 | 0.95 | 5.9 |
| **Ronda 4** | Burpees | 20 | 2:30 min | 11.0 | 1.25 | 32.5 |
| (20 reps) | Air Squats | 20 | 1:00 min | 5.0 | 1.05 | 5.8 |
| | Sit-ups | 20 | 1:00 min | 3.0 | 1.00 | 3.3 |
| **Ronda 5** | Burpees | 10 | 1:20 min | 11.0 | 1.25 | 17.4 |
| (10 reps) | Air Squats | 10 | 0:30 min | 5.0 | 1.05 | 2.9 |
| | Sit-ups | 10 | 0:30 min | 3.0 | 1.00 | 1.7 |
| **TOTALS** | | **450 reps** | **~29 min** | | | **~285 kcal** |

> L'efecte EPOC en protocols d'aquest volum i intensitat és molt significatiu. Incloent la post-crema estimada (~15%), la despesa total se situa entre **325 i 330 kcal**.

---

### ENDURANCE\_GRID: STAMINA

**Categoria:** Endurance Grid · **Format:** Rondes iguals 40×5 · **Protocol base:** AFAP

**Exercicis:** Air Squats (`LOWER_KNEE`) · Lunges Alternes (`LOWER_KNEE/LUNGE`) · Sit-ups (`CORE`)

**Racionalitat:** L'Endurance Grid prioritza la **capacitat de treball sostingut** per sobre de la potència explosiva. STAMINA, amb 600 repeticions totals, posa a prova la resistència muscular de les cames, el core i la coordinació durant ~29 minuts ininterromputs. El canvi d'un exercici de genoll dominant a un de core (de Squats a Sit-ups) funciona com a recuperació activa parcial: les cames descansen mentre el sistema cardiovascular continua treballant. Tot i que la despesa calòrica per minut és inferior a la del Fat Burning, el temps total sota tensió és molt superior, la qual cosa millora l'eficiència mitocondrial.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Air Squats | 40 | 1:30 min | 5.0 | 1.00 | 8.3 |
| | Lunges Alternes | 40 | 1:40 min | 5.5 | 1.00 | 10.2 |
| | Sit-ups | 40 | 1:45 min | 3.0 | 0.95 | 6.7 |
| **Ronda 2** | Air Squats | 40 | 1:35 min | 5.0 | 1.05 | 9.2 |
| | Lunges Alternes | 40 | 1:45 min | 5.5 | 1.05 | 11.2 |
| | Sit-ups | 40 | 1:50 min | 3.0 | 1.00 | 7.3 |
| **Ronda 3** | Air Squats | 40 | 1:40 min | 5.0 | 1.05 | 9.7 |
| | Lunges Alternes | 40 | 1:50 min | 5.5 | 1.10 | 11.9 |
| | Sit-ups | 40 | 1:55 min | 3.0 | 1.00 | 7.7 |
| **Ronda 4** | Air Squats | 40 | 1:45 min | 5.0 | 1.10 | 10.7 |
| | Lunges Alternes | 40 | 2:00 min | 5.5 | 1.10 | 13.4 |
| | Sit-ups | 40 | 2:00 min | 3.0 | 1.00 | 8.0 |
| **Ronda 5** | Air Squats | 40 | 1:50 min | 5.0 | 1.10 | 11.2 |
| | Lunges Alternes | 40 | 2:05 min | 5.5 | 1.10 | 14.0 |
| | Sit-ups | 40 | 2:05 min | 3.0 | 1.05 | 8.7 |
| **TOTALS** | | **600 reps** | **~29 min** | | | **~148 kcal** |

---

### ENDURANCE\_GRID: STEADFAST

**Categoria:** Endurance Grid · **Format:** Piràmide descendent 50-40-30-20-10 · **Protocol base:** AFAP

**Exercicis:** Step-ups (`LOWER_KNEE/LUNGE`) · Flexions Tècniques (`UPPER_PUSH`) · Abdominals Tisora (`CORE`)

**Racionalitat:** STEADFAST combina el patró de piràmide descendent (on gairebé el 60% del volum es concentra en les dues primeres rondes) amb exercicis de moderada intensitat cardiovascular però alta demanda neuromuscular. Les *Flexions Tècniques* (rang de moviment complet, pit tocant el terra) forcen una activació superior del pectoral respecte a les flexions parcials. L'*Abdominal Tisora* treballa els flexors de maluc i els rectes abdominals en excèntric, complementant sense solapar la cadena muscular dels Step-ups.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Step-ups | 50 | 2:30 min | 6.0 | 1.00 | 16.7 |
| (50 reps) | Flexions Tècniques | 50 | 2:30 min | 5.5 | 1.00 | 15.3 |
| | Abdominals Tisora | 50 | 1:30 min | 3.0 | 0.95 | 6.0 |
| **Ronda 2** | Step-ups | 40 | 2:05 min | 6.0 | 1.05 | 14.6 |
| (40 reps) | Flexions Tècniques | 40 | 2:10 min | 5.5 | 1.05 | 13.9 |
| | Abdominals Tisora | 40 | 1:15 min | 3.0 | 1.00 | 5.3 |
| **Ronda 3** | Step-ups | 30 | 1:40 min | 6.0 | 1.05 | 11.0 |
| (30 reps) | Flexions Tècniques | 30 | 1:45 min | 5.5 | 1.05 | 10.7 |
| | Abdominals Tisora | 30 | 0:55 min | 3.0 | 1.00 | 3.9 |
| **Ronda 4** | Step-ups | 20 | 1:05 min | 6.0 | 1.10 | 7.9 |
| (20 reps) | Flexions Tècniques | 20 | 1:10 min | 5.5 | 1.10 | 7.8 |
| | Abdominals Tisora | 20 | 0:40 min | 3.0 | 1.00 | 2.7 |
| **Ronda 5** | Step-ups | 10 | 0:35 min | 6.0 | 1.10 | 4.3 |
| (10 reps) | Flexions Tècniques | 10 | 0:35 min | 5.5 | 1.10 | 3.9 |
| | Abdominals Tisora | 10 | 0:20 min | 3.0 | 1.00 | 1.3 |
| **TOTALS** | | **450 reps** | **~21 min** | | | **~125 kcal** |

---

### ENDURANCE\_GRID: LASTING

**Categoria:** Endurance Grid · **Format:** Rondes iguals 60×3 · **Protocol base:** AFAP

**Exercicis:** Butt Kicks (`FULL_BODY`) · Glute Bridges (`LOWER_HINGE`) · Mountain Climbers lents (`CORE/FULL_BODY`)

**Racionalitat:** LASTING és el protocol de gestió d'energia per excel·lència de l'Endurance Grid. Les rondes de 180 repeticions cadascuna busquen la fatiga acumulada total a través d'un esforç controlat i sostingut. La combinació d'un exercici aeròbic de cames (*Butt Kicks*), un de força de maluc (*Glute Bridges*) i un de core dinàmic (*Mountain Climbers lents*) permet que cada zona muscular tingui una recuperació parcial mentre les altres treballen, alargant el temps total sota tensió sense arribar a la fallada muscular local. L'estratègia òptima d'execució és mantenir un ritme del 70–75% de la capacitat màxima per evitar el col·lapse muscular prematur.

| Ronda | Exercici | Reps | Temps est. | MET | Factor fatiga | Kcal est. |
|---|---|---|---|---|---|---|
| **Ronda 1** | Butt Kicks | 60/60 | 1:15 min | 8.0 | 1.00 | 11.1 |
| (60 reps) | Glute Bridges | 60 | 3:00 min | 3.5 | 0.80 | 9.3 |
| | Mountain Climbers (lents) | 60/60 | 2:00 min | 5.0 | 0.90 | 10.0 |
| **Ronda 2** | Butt Kicks | 60/60 | 1:20 min | 8.0 | 1.05 | 12.4 |
| | Glute Bridges | 60 | 3:15 min | 3.5 | 0.82 | 10.4 |
| | Mountain Climbers (lents) | 60/60 | 2:10 min | 5.0 | 0.95 | 11.4 |
| **Ronda 3** | Butt Kicks | 60/60 | 1:30 min | 8.0 | 1.10 | 14.7 |
| | Glute Bridges | 60 | 3:30 min | 3.5 | 0.85 | 11.7 |
| | Mountain Climbers (lents) | 60/60 | 2:20 min | 5.0 | 1.00 | 13.1 |
| **TOTALS** | | **540 reps** | **~20 min** | | | **~104 kcal** |

---

## 7. Lògica de Programació de Protocols

Quan el sistema genera un protocol d'entrenament, ha de respectar la següent seqüència estructural:

1. **Escalfament i refredament:** Sempre externs al protocol principal. No es comptabilitzen en el temps ni en les calories del protocol.
2. **Selecció del marc fisiològic:** El bloc de treball s'estructura segons un dels quatre estàndards (Tabata, Gibala/Little, AMRAP o AFAP), en funció de l'objectiu i el nivell de l'usuari.
3. **Distribució de patrons de moviment:** S'aplica l'alternança entre els patrons de la secció 4 per garantir l'equilibri biomecànic. Màxim dos exercicis consecutius de la mateixa categoria `target_zone`.
4. **Composició dels subsistemes:** Cada subsistema (grup d'exercicis d'una ronda) ha de contenir exercicis distints. Un mateix exercici pot repetir-se en subsistemes diferents del protocol, però no de forma consecutiva dins del mateix subsistema.
5. **Càlcul calòric:** S'aplica la fórmula de la secció 3 amb el perfil real de l'usuari. Els valors de les fitxes d'aquest document són orientatius, calculats sobre el perfil de referència neutre (75 kg, 30 anys).

---

*Document elaborat per al projecte HYPER//HIIT. Per a la documentació de l'arquitectura de l'aplicació, els models de dades i la lògica de programació, consultar el whitepaper tècnic.*
