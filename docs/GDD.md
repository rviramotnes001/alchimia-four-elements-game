# Alchimia — Documento de Diseño del Juego (GDD)

> Documento vivo. Se construye sección por sección entre el creador y Claude.
> Estado: **en progreso**. Las secciones marcadas con *(pendiente)* aún no se han definido.

---

## 1. Visión

**Título de trabajo:** Alchimia: The Four Elements *(por decidir, ver "Nombre" abajo)*

**Género:** Metroidvania ligero 2D de plataformas, vista lateral, un jugador, para PC.

**Motor:** Godot 4.7.2 (GDScript).

**Sensación buscada:** cálida, de cuento. El jugador acompaña a Erek en la recuperación de los elementos y disfruta de la historia. Las escenas cinemáticas (cutscenes) son parte central de la experiencia y de la ambientación.

**Referencia principal:** *Hollow Knight* (mundo conectado, exploración, poderes que abren caminos). Con un tono mucho más cálido y colorido.

**Pilares del juego (lo que más debe destacar):**
1. **La historia** y su ambientación (cutscenes, personajes, mundo).
2. **Los puzzles con elementos** y las **esencias** que el jugador recolecta.
3. Combate y exploración como apoyo.

**Público y dificultad:** jóvenes y todo público, niños incluidos. Los puzzles pueden ser difíciles, pero el juego debe ser accesible.

**Duración:** sin definir. Se empieza con el **Capítulo 1 (elemento del Agua)** como lanzamiento inicial y se decide el resto según la respuesta del público y los testers.

**Tono del mundo:** empieza feliz y colorido. Se oscurece a medida que Claytor domina el reino y roba los elementos.

### Nombre (opciones)
| Opción | Nota |
|---|---|
| Alchimia Adventure | Nombre original del proyecto en Unity. Corto y claro. |
| Alchimia and the Four Elements | Descriptivo, deja claro el tema. Largo. |
| **Alchimia: The Four Elements** *(propuesta de Claude)* | Mezcla ambos. "Alchimia" es único (fácil de buscar) y encaja con un formato por capítulos, p. ej. *Capítulo 1: La Esencia del Agua*. |

*Decisión pendiente del creador.*

---

## 2. Historia y personajes

### Resumen de la historia
Alchimia es un reino feliz sostenido por cuatro elementos:
- **Agua:** da agua a todo el reino y sus animales.
- **Tierra:** mantiene la fauna, los hogares y los bosques.
- **Fuego:** da calor a las personas y es clave para crear armas y hechizos.
- **Aire:** mantiene el hábitat limpio y respirable.

Una noche, el brujo **Claytor** y sus súbditos entran al reino para robar los elementos y conquistarlo. El rey y su hijo intentan detenerlo, pero llegan tarde. La fuerza del robo dispersa los elementos (y sus esencias) por el reino. Claytor solo logra quedarse con el **Aire**.

Dispersión de los elementos:
| Elemento | Dónde terminó |
|---|---|
| Agua | Afueras del bosque |
| Tierra | Cuevas |
| Fuego | Volcán |
| Aire | Claytor lo tiene |

**Erek** sale en una misión para recuperarlos antes de que Claytor los encuentre. En cada zona enfrenta animales transformados y controlados por el elemento, y cada elemento recuperado le otorga un poder.

### Apertura del juego
Comienza con una **cutscene** que muestra el reino feliz y en paz, hasta que llega Claytor, roba los elementos y estos se dispersan, dejándole solo el Aire. Después empieza el control del jugador.

### Personajes

**Erek (protagonista, príncipe)**
- Muy **inseguro, pero valiente**.
- Arco: de príncipe inseguro a **rey de Alchimia** al final de la historia.
- Armas ya en arte: espada y arco.

**Rey Chris** (en el arte original se llama *Darville*, es el mismo personaje; "Chris" es el nombre oficial)
- Queda **herido pero a salvo en el castillo** tras el ataque.
- Su papel en el juego es ser **el narrador**: es quien cuenta la historia al jugador.
- Es **hermano de Claytor** (secreto, ver abajo).

**Claytor (antagonista)**
- Brujo que vive en las afueras del reino.
- **Es hermano del rey Chris**, o sea, **tío de Erek**.
- **Revelación tardía:** la trama no lo anuncia al inicio. Sus padres lo **desterraron** por su intención de conquistar el reino y sus alrededores.
- Motivación: poder, conquista y, en el fondo, el rechazo de su familia.

**Súbditos de Claytor:** lo acompañan en el ataque.

**Más personajes:** no hay otros por ahora. Posible expansión futura (aliados, comerciantes, compañero).

### Esencias
- Cada elemento tiene sus **esencias**, que el jugador **recolecta**.
- **Usos confirmados:**
  - Rellenar/llenar elementos en **puzzles**.
  - **Potenciar los poderes** de Erek más adelante.
  - **Abrir portales y puertas**.
  - Otros usos por definir.

### Preguntas abiertas de esta sección
- Diferencia exacta entre un **elemento** (la fuente de poder de cada zona) y una **esencia** (el objeto coleccionable). *Ver Sección 3.*
- Cómo es la narración de Chris: ¿voz en off, textos, escenas en el castillo entre zonas?
- Fecha o momento de la revelación del parentesco entre Claytor y Chris.

## 3. Poderes y elementos

### Identidad visual de los elementos
Cada elemento tiene **colores fijos** en todo el juego (UI, poderes, cutscenes), basados en los íconos reales en `arte/original/Elements/`:
| Elemento | Colores |
|---|---|
| Agua | Turquesa/menta + azul, con blanco |
| Tierra | Naranja/terracota + magenta/vino |
| Fuego | Rojo + amarillo |
| Aire | Verde azulado (teal) + blanco |

*Pendiente:* las esencias actuales (azul, verde, rojo, amarillo) no coinciden con estos colores; conviene recolorearlas.

Prompts de arte de cada elemento en [`ARTE_PROMPTS.md`](ARTE_PROMPTS.md).

### Reglas generales (confirmadas por el creador)
- **Elemento** = la fuente de poder de cada zona (lo que Erek recupera de cada jefe/zona). Cada elemento le da un **poder** a Erek.
- **Esencia** = coleccionable de cada elemento. Se consigue de **todas** estas formas: enemigos, escondidas en el mapa y como recompensa de puzzles.
- **Usos de las esencias:** llenar/activar cosas en puzzles, **potenciar** los poderes, **abrir puertas y portales**.
- **Los elementos NO se combinan entre sí.** Cada elemento sirve para **avanzar por el mapa según lo que pida cada obstáculo**.
- **Selección de poder:** **rueda de elementos** con *toggle* para elegir cada uno. Solo aparecen los ya desbloqueados.
- **Armas:** la espada y el arco **se combinan con los elementos** para hacerse más grandes y poderosos.

### Poderes (propuesta de Claude, **aprobada por el creador**)
Principio de diseño: cada poder hace **dos cosas** al menos, una de **combate** y una de **exploración/puzzle**, y abre zonas del mapa que antes estaban bloqueadas.

#### Agua (Capítulo 1)
| Poder | Combate | Exploración / puzzle |
|---|---|---|
| **Chorro de agua** | Disparo a distancia, empuja enemigos | Apaga antorchas y fuegos, activa interruptores lejanos, hace crecer plantas |
| **Respiración acuática** | Pelear bajo el agua | Nadar y bucear: abre zonas sumergidas del bosque |
| **Riego** | — | Hace brotar enredaderas/plataformas vegetales en puntos marcados |
| *Espada/Flechas de agua* | Golpe que empuja, flecha que apaga y activa | Alcance largo para puzzles |

#### Tierra (Cuevas)
| Poder | Combate | Exploración / puzzle |
|---|---|---|
| **Escudo de roca** | Reduce el daño, golpe cargado | Rompe paredes agrietadas |
| **Bloque de roca** | Bloquea proyectiles | Crea una plataforma, o pesa sobre un interruptor de presión |
| **Excavar** | — | Atraviesa tierra blanda, abre atajos |

#### Fuego (Volcán)
| Poder | Combate | Exploración / puzzle |
|---|---|---|
| **Llama** | Daño alto, quema enemigos | Quema telarañas, maderas y enredaderas; enciende antorchas |
| **Luz** | — | Ilumina salas oscuras y cuevas |
| **Calor** | — | Derrite hielo, activa mecanismos y forjas |

#### Aire (Castillo de Claytor, último)
Claytor lo tiene desde el inicio, así que lo **usa contra Erek** en el jefe final.
| Poder | Combate | Exploración / puzzle |
|---|---|---|
| **Doble salto / planeo** | Esquivar | Cruza vacíos grandes |
| **Dash de viento** | Ataque rápido | Cruza trampas y corrientes |
| **Ráfaga** | Empuja enemigos | Mueve molinos y plataformas, disipa niebla tóxica |

> Nota: el Aire como último poder es una decisión de **historia** (Claytor lo tiene). Si el movimiento (doble salto, dash) llega tan tarde, el diseño de niveles anteriores debe poder resolverse **sin** movimiento extra. Esto se revisará en la Sección 4.

### Energía elemental (decidido)
- Los poderes, golpes y flechas elementales **usan una barra propia de energía que se recarga**.
- Las **esencias NO se gastan en disparar**; así el jugador nunca se queda sin poder en medio de un puzzle.

### Esencias (decidido)
- Cada elemento tiene su tipo de esencia.
- Las esencias se usan **solo para mejoras de poderes y para abrir puertas/portales elementales**.
- **Mejora de poderes:** cada poder tiene niveles (1, 2, 3) que se desbloquean con esencias.
- **Puertas y portales elementales:** piden cierta cantidad o tipo de esencia.
- Se consiguen en enemigos, escondidas en el mapa y como recompensa de puzzles.

### Piezas de puzzle (separadas de las esencias) — *nombre y detalle por definir*
- Las cosas que se **usan dentro de un puzzle** (llenar un altar, activar una ranura) son **un sistema aparte**, para que gastar esencias en una mejora nunca deje al jugador atascado.
- Idea inicial: son objetos que **se encuentran y se usan dentro de la misma sala o zona del puzzle** y no se guardan como moneda.

### Preguntas abiertas de esta sección
- Nombre de las piezas de puzzle (ej.: "orbes", "gotas", "runas", "núcleos").
- Detalles exactos de la **rueda de elementos** (teclas, mando/gamepad).

## 4. Mapa del mundo y conexiones

### Decisiones del creador
- **Metroidvania con regreso a zonas anteriores:** con cada poder nuevo, el jugador puede volver a zonas ya visitadas para abrir caminos y secretos.
- **Castillo de Claytor:** está **pasando el Volcán** y **se abre al tener los 3 elementos** (Agua, Tierra, Fuego).
- **Viajes rápidos:** se usarán más adelante, para volver al castillo y recoger mejoras.
- **Tamaño:** se empieza por el Capítulo 1 y se expande según el desarrollo y la respuesta del público.

### Propuestas de Claude (**aprobadas por el creador**)

**Hub central: el Castillo de Alchimia**
Erek vuelve al castillo entre zonas. Allí:
- Habla con el **rey Chris** (narración y avance de la historia, cutscenes).
- **Guarda la partida.**
- **Gasta esencias** en mejorar poderes.
- Con el tiempo, el castillo "se llena" de cosas recuperadas (más color y vida cada vez que Erek devuelve un elemento), lo que refuerza el tono de cuento.

**Orden de las zonas: guiado, con libertad dentro**
Las zonas principales se visitan en orden fijo (**Agua → Tierra → Fuego → Castillo de Claytor**) porque la historia y los poderes dependen de ese orden. Dentro de cada zona y al volver a las anteriores, el jugador explora con libertad.
Esto encaja con el plan de lanzar **por capítulos** y es más fácil de equilibrar.

```
        [Bosque / Agua] ──┐
                          │
[Castillo de Alchimia] ───┼── [Cuevas / Tierra] ── [Volcán / Fuego] ── [Castillo de Claytor / Aire]
        (hub)             │
                          └── (portales de viaje rápido, se abren con esencias)
```

**Diseño por salas modulares**
Cada sala es una escena independiente con conexiones marcadas (puertas/salidas). Así el mapa **crece sin rehacer nada**: se añaden salas nuevas y se conectan.

**Tamaño recomendado del Capítulo 1:** unas **15 a 20 salas** más la arena del jefe. Es lo bastante grande para sentirse Metroidvania y lo bastante pequeño para terminarlo con un equipo de uno. Si funciona bien con el público, cada zona siguiente puede ser igual o un poco más grande.

**Bloqueos para el futuro:** en cada zona se dejan **puertas y caminos marcados con el símbolo de un elemento** que aún no se tiene. Esto da pistas visuales y motiva el regreso.

**Viajes rápidos:** **portales** que se abren con esencias y conectan las zonas con el castillo. Se implementan después del Capítulo 1.

**Mapa en pantalla:** un mapa que **se revela al explorar** salas (estilo *Hollow Knight*, pero simple). Es muy útil para que el jugador se ubique y vea qué salas tienen puertas de elementos aún cerradas. Se agrega después del prototipo del Capítulo 1.

---

### Capítulo 1: Zona del Agua — **Bosque Cristalino** (nombre aprobado)

**Ambiente:** bosque cálido y colorido con ríos, cascadas y lagos. Sus habitantes fueron **transformados por el elemento Agua**: animales y plantas del bosque que **evolucionaron** de forma especial (más grandes, brillantes o con rasgos acuáticos) porque el elemento dañó su hábitat.

**Enemigos disponibles en el arte** (se les puede dar un giro "evolucionado por el agua"):
| Enemigo | Idea de "evolución" (propuesta) |
|---|---|
| Mandrágora (planta) | Brota con raíces que beben agua, se ve más húmeda y brillante |
| Avispa | Versión que vuela cerca del agua, tipo "libélula" |
| Lobo | Lobo del río, rápido, con rasgos de agua |
| Sátiro | Guardián del bosque, más grande o con arma de agua |
| Rata | Enemigo pequeño de alcantarilla/orilla del río |
| Mini elemento de agua | Espíritu del agua que dispara proyectiles |

**Jefe: Gólem de Agua**
Gólem azul grande, con **3 fases** de pelea (**aprobado**; se podrá ampliar si funciona bien). Diseño:
1. **Fase 1:** golpes pesados y ataques a ras de suelo; el jugador aprende los patrones.
2. **Fase 2:** invoca olas o proyectiles de agua; la arena cambia.
3. **Fase 3:** más rápido y agresivo; el jugador debe usar lo aprendido (y el poder del Agua en un puzzle de combate).

### Obtención del poder del Agua (**aprobado**)
Para que el jugador pueda usar el agua **dentro** del capítulo (y no solo al final):
- **Al inicio/primer tercio:** Erek encuentra una **chispa del elemento** en un altar o fuente y obtiene el **Chorro de agua**.
- **Al vencer al Gólem:** recupera el **elemento completo** (cinemática) y desbloquea **Respiración acuática** y **Riego**.
- Después, el jugador puede **volver a salas ya visitadas** para abrir zonas sumergidas y secretos.

### Preguntas abiertas
- Detalle de cada fase del Gólem (ataques concretos). Se define en la Sección 5.

## 5. Zonas: salas, puzzles, enemigos y jefes

### Capítulo 1: Bosque Cristalino (**recorrido de 5 sectores aprobado por el creador**)
El creador delega en Claude el diseño de los puzzles concretos. **Monedas:** se usan para **comprar** (tienda en el castillo).

**Recorrido en cinco sectores** (unas 18 salas más la arena del jefe):

| Sector | Salas | Qué pasa | Poder / progreso |
|---|---|---|---|
| **A. Camino de entrada** | 1–3 | Tutorial: moverse, saltar, atacar con la espada. Primeros enemigos (mandrágora). Primer checkpoint. | Sin poderes |
| **B. Claro Cristalino** (centro del bosque) | 4–7 | Punto central de la zona; conecta con los otros 3 sectores. Aquí está el **Altar de la Chispa**. | **Obtiene el Chorro de agua** |
| **C. Río y Cascadas** | 8–11 | Puzzles de agua: compuertas, interruptores a distancia y caudal. Enemigos: lobo y avispa. | Primera **pieza de puzzle** + esencias |
| **D. Raíces del Gran Árbol** | 12–14 | Zona de plantas y sátiros. Mini-jefe. Puzzle de llenar la **piedra elemental** (tu arte *Big Element Rock*). | Segunda **pieza de puzzle** |
| **E. Lago del Gólem** | 15–17 + arena | El camino al jefe se abre al activar las piedras elementales. Pelea contra el **Gólem de Agua** (3 fases). | **Respiración acuática + Riego** |

**Después del jefe:** cutscene de recuperar el elemento, regreso al castillo con Chris, y **vuelta al bosque** con los nuevos poderes para abrir las salas sumergidas, las enredaderas y los secretos que quedaron marcados.

**Salas secretas (se abren al volver):** unas 3 o 4 con esencias, mejoras de vida y piezas coleccionables.

### Tipos de puzzle del capítulo (catálogo)
1. **Interruptor a distancia:** activar un interruptor con el Chorro de agua.
2. **Antorchas:** apagar antorchas en cierto orden con el agua.
3. **Compuertas y caudal:** abrir o cerrar compuertas para subir o bajar el nivel del agua y alcanzar plataformas.
4. **Piedra elemental:** llenar una piedra con las piezas de puzzle que se hallan en la zona para abrir una puerta.
5. **Cascada bloqueada:** desviar el agua para revelar un pasaje.
6. **Plataformas flotantes:** suben y bajan según el nivel del agua.
7. **Enredaderas (después del jefe):** hacer brotar con Riego para subir a zonas altas.
8. **Zonas sumergidas (después del jefe):** nadar con Respiración acuática.

Los puzzles aumentan en dificultad por sector: A (ninguno), B (uno sencillo para aprender el Chorro), C (dos o tres), D (combinados con combate), E (final).

### Objetos recolectables (según el arte disponible)
Esencias de agua, monedas, frutas, pociones de vida, cofres, llaves y checkpoints.

### Jefe: Gólem de Agua
- **Fase 1:** golpes pesados y ataques a ras de suelo. Enseña los patrones.
- **Fase 2:** invoca olas y proyectiles; la arena cambia.
- **Fase 3:** más rápido; combina los patrones anteriores y exige usar el poder del Agua.
*(Los ataques concretos se detallan cuando se construya la pelea.)*

### Preguntas abiertas
- Qué se vende en la tienda y a qué precios (Sección 6).

## 6. Reglas de juego (vida, daño, objetos, guardado, controles)

*(Propuesta de Claude **aprobada por el creador**. Valores numéricos provisionales, se ajustan jugando.)*

### Vida y daño
- **Vida en corazones.** Erek empieza con **5 corazones**. Cada golpe enemigo quita 1 (algunos jefes, 2).
- **Invulnerabilidad breve** tras recibir un golpe, con retroceso, para que no sea frustrante.
- **Mejoras de vida:** se encuentran en salas secretas (aumentan un corazón).
- **Curación:** frutas (curan poco), **pociones** (curan más). La poción grande restaura todo.
- **Muerte (decidido):** Erek reaparece en el **último checkpoint** y no pierde esencias ni progreso. **Pierde una parte pequeña de sus monedas**, que quedan en el **lugar donde murió** y puede **recuperar** al volver (estilo *Hollow Knight*, pero con penalización suave). Valor inicial propuesto: se pierde ~**25 %** de las monedas.

### Ataque y energía elemental
- **Espada:** ataque rápido, alcance corto, siempre disponible.
- **Arco:** ataque a distancia con flechas limitadas, que se recogen o compran.
- **Barra de energía elemental:** gasta con cada poder y se **recarga sola** poco a poco (más rápido al golpear enemigos).
- **Ataques elementales:** espada y flechas con efecto del elemento activo, usando la barra.

### Rueda de elementos
- Se abre con una tecla (mantener) y el jugador elige el elemento con el ratón/stick; también se puede **cambiar rápido con una tecla**.
- Muestra solo los elementos desbloqueados.

### Controles (teclado, y mando desde el inicio)
| Acción | Teclado | Mando |
|---|---|---|
| Mover | A / D o flechas | Stick izq. |
| Saltar | Espacio | A |
| Atacar (espada) | J | X |
| Disparar arco | L | RB |
| Poder elemental | K | B |
| Rueda de elementos | Q (mantener) | LB (mantener) |
| Interactuar / hablar | E | Y |
| Pausa / mapa | Esc / M | Start / Select |

### Guardado
- Guardado **automático en checkpoints** (ya tienes el sprite) y al hablar con Chris en el castillo.
- Un solo archivo de guardado al inicio; más ranuras si hace falta.

### Economía
- **Monedas (bronce, plata, oro):** se ganan de enemigos y cofres; se **gastan en la tienda del castillo** (pociones, flechas, vida extra por mejoras, etc.).
- **Esencias:** solo para mejoras de poderes y puertas/portales (ver Sección 3).
- **Piezas de puzzle:** se usan dentro de la zona, no se guardan.
- **Llaves:** abren puertas y cofres específicos.

### Dificultad y accesibilidad
- Un solo nivel de dificultad al inicio, con checkpoints frecuentes.
- **Puzzles con pistas opcionales** (por ejemplo, hablar con Chris o un objeto que da una pista) para que sean difíciles pero no bloqueen a los niños.
- Opciones: volumen, pantalla completa, remapear teclas, subtítulos en cutscenes.

### Idiomas (decidido)
**Español e inglés.** Todos los textos del juego se escriben en un sistema de traducción desde el inicio (no dentro del código), para poder añadir más idiomas después.

### Preguntas abiertas
- Qué se vende en la tienda y a qué precios.

## 7. Orden de progresión

*(PROPUESTA de Claude, pendiente de aprobación. Es el camino "ideal" del jugador en el Capítulo 1, y el esquema de los siguientes.)*

### Capítulo 1: Bosque Cristalino
1. **Cutscene de apertura:** el reino feliz, el ataque de Claytor y la dispersión de los elementos.
2. Erek despierta/inicia la misión; Chris (herido, desde el castillo) le da las primeras palabras.
3. **Sector A:** tutorial de movimiento y espada.
4. **Sector B:** llega al Claro, encuentra el **Altar de la Chispa** y obtiene el **Chorro de agua**.
5. **Sector C** (río): resuelve puzzles de agua y obtiene la **primera pieza de puzzle**.
6. **Sector D** (raíces): vence al mini-jefe y obtiene la **segunda pieza de puzzle**; llena las piedras elementales.
7. **Sector E:** se abre el camino; pelea contra el **Gólem de Agua** (3 fases).
8. **Cutscene:** recupera el elemento Agua; desbloquea **Respiración acuática** y **Riego**.
9. **Regreso al castillo:** habla con Chris, guarda, gasta esencias y monedas.
10. **Vuelta al bosque** con los nuevos poderes para abrir secretos y salas sumergidas. Se muestra el camino hacia las Cuevas (siguiente capítulo).

### Esquema de los siguientes capítulos *(por detallar)*
- **Capítulo 2 — Cuevas (Tierra):** nuevo poder, nuevo jefe, regresos al bosque y al castillo.
- **Capítulo 3 — Volcán (Fuego):** idem.
- **Capítulo 4 — Castillo de Claytor (Aire):** se abre con los 3 elementos; combate final; revelación de que Claytor es hermano de Chris; Erek se convierte en rey.

### Qué puede abrir el jugador al volver a una zona
Cada poder nuevo abre una parte del mapa ya visitado (puertas con el símbolo del elemento): zonas sumergidas (Agua), paredes agrietadas (Tierra), maderas y telarañas (Fuego), vacíos grandes (Aire).

## 8. Cutscenes y narrativa

*(PROPUESTA de Claude, pendiente de aprobación.)*

### Cómo se cuenta la historia
- **Chris es el narrador:** su voz (texto con voz o solo texto) abre y cierra los capítulos y comenta momentos clave.
- **Cutscenes principales:** escenas con dibujos/imágenes fijas con efectos de cámara y texto (barato de producir y coherente con un estilo cuento), con música.
- **Escenas dentro del juego:** diálogos cortos con cuadros de texto en el mundo, sin quitar el control por mucho tiempo.
- **Lista de cutscenes del Capítulo 1:**
  1. Apertura: el reino feliz y el ataque de Claytor.
  2. Erek y Chris: la despedida (Chris herido, Erek inseguro).
  3. Altar de la Chispa: primer poder.
  4. Antes del jefe: el Gólem y el elemento.
  5. Tras el jefe: recupera el Agua; el reino vuelve a un poco de color.
  6. Regreso al castillo: Chris y una pista sobre las Cuevas.

### Arco emocional de Erek
Empieza inseguro y dudando; en cada capítulo se hace más seguro. Al final, ya como rey, acepta el pasado de su familia.

### Decisiones del creador
- **Cutscenes con arte fijo** (imágenes estáticas) que aún **no están generadas**. Se generan con **Google Flow**, usando prompts que mantengan la consistencia. Ver [`ARTE_PROMPTS.md`](ARTE_PROMPTS.md).
- **Solo texto**, sin voces grabadas.

### Preguntas abiertas
- Estilo final de las cutscenes (pintado tipo libro de cuentos o pixel art de alta resolución).
- Música y sonido (por definir).
