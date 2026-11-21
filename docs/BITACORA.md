# Bitácora de Alchimia: The Four Elements

Resumen de todo lo hecho hasta ahora (2026-11-18). Reescrita desde cero. Las entradas nuevas se agregan arriba de la sección "Historial".

## 1. Proyecto y herramientas
- Godot 4.7.2, GDScript, Forward+, Jolt. Metroidvania 2D cozy. Diseño en `docs/GDD.md`.
- Método: paso a paso, probando cada pieza hasta que "se sienta bien". Salas una por una; tiles con cuidado más adelante.
- Se trabaja con el addon Godot AI (MCP). Notas: `script_patch`, `node_set_property` y `scene_save` fallan con el juego corriendo (detenerlo primero). Después de crear scripts con `class_name` correr `filesystem_manage scan`. Errores de parseo intermedios entre patches son normales; importa el diagnóstico del último.
- Render pixel-clean: viewport 640×360, ventana 1280×720, stretch `canvas_items`, aspect `expand`, scale_mode `integer`, filtro nearest, snap de transforms/vértices a píxel, cámara sin smoothing.
- Física: capas 1 mundo, 2 jugador, 3 enemigos, 4 hitbox del jugador, 5 hurtbox de enemigos.
- Localización: CSV `translations/texts.csv` → autoload `Localization`, inglés por defecto, F1 cambia idioma. Fuente Kenney Mini. Hitstop con `Engine.time_scale`.

## 2. Controles
| Acción | Teclado | Gamepad |
|---|---|---|
| Mover | A/D, flechas | stick izq |
| Agacharse/bajar | S, Down | stick abajo |
| Saltar | Espacio, W | A |
| Atacar | J | X |
| Cambiar arma | Tab | RB |
| Interactuar | E | Y |
| Poder elemental | K | B |
| Rueda de elementos | Q (tap = siguiente, mantener = rueda) | LB |
| Elemento directo | 0 (ninguno), 1–4 | — |

## 3. Jugador (`scripts/player.gd`)
- Estados NORMAL, ATTACK, HURT, DEAD. Origen en los pies, sprite 48×36, `Visual` volteado con `scale.x`.
- Salud en medios corazones (6 = 3 corazones), daño 1 = medio corazón, knockback, invulnerabilidad, muerte.
- Espada: hitbox, hitstop, movimiento reducido (0.35) al atacar.
- Arco: animaciones `bow_attack` (suelo) y `bow_attack_air` (aire) con frame de disparo, flecha (`scripts/arrow.gd`, daño 1, velocidad 260). En suelo no se mueve al disparar; en aire gravedad reducida. Poses normales con ambas armas (el arco solo se ve al disparar).
- Cambio de arma con `weapon_swap`; el HUD muestra el icono del arma.
- Interacción con E (`interactable`).
- Nado: `water_zone` (Área2D). Más lento (×0.6), hundimiento suave, brazada, buceo; reusa poses de salto (sin arte de nado aún).
- Oxígeno: 6 burbujas sobre la cabeza (`oxygen_meter.gd`), se gasta con la cabeza bajo el agua, se rellena fuera; al llegar a 0 hace 1 de daño por ahogo. No se gasta con Respiración acuática activa.

## 4. HUD
- Corazones, icono de arma, ranura de ítems (llaves, etc.), monedas/esencias, barra de energía con chip de elemento (`element_energy.gd`), rueda de elementos (`element_wheel.gd`). Todo dibujado con rects para mantener pixeles limpios.

## 5. Elementos y energía (`elemental_power.gd`, `elements.gd`)
- Elementos: Agua (turquesa/azul), Tierra (naranja/magenta), Fuego (rojo/amarillo), Aire (verde azulado/blanco). No se combinan.
- Energía 100, se recarga (14/s tras 0.8 s), no gasta esencias. Golpear recarga 6.
- K = poder principal del elemento activo; los demás poderes son automáticos o al interactuar.
- Armas elementales automáticas: con Agua activa, la espada/flechas se cargan de agua (cuesta 3 y 5 de energía).
- Q tap cicla NINGUNO → elementos desbloqueados. Mantener Q abre la rueda (stick derecho o mouse; centro = ninguno). 0 = ninguno, 1–4 directos.
- Sin elemento: nada elemental funciona (ni Respiración ni Riego); el agua sí te ahoga.

## 6. Poderes de Agua (completos)
- **Chorro de agua** (K, 25 energía): `water_jet.tscn`, empuja sin dañar, apaga antorchas, activa interruptores, riega semillas.
- **Espada/flechas de agua**: empujan y activan props.
- **Respiración acuática**: permite estar bajo el agua sin gastar oxígeno (requiere Agua seleccionada).
- **Riego**: E sobre un punto de riego (20 energía) hace crecer una enredadera con plataforma de una vía (`irrigation_point`, 44 px, 0.9 s).

## 7. Props y nivel de prueba
- `training_dummy`, `hazard` (pinchos), `gate` (`set_open`), `water_switch`, `elemental_torch` (agua apaga, fuego enciende), `water_zone`, `irrigation_point`.
- Interfaz de props: Hurtbox Area2D capa 16 cuyo padre expone `take_damage(amount, from_x)`, `on_element_hit(element, source)`, `push(direction, force)`.
- `scenes/test_level.tscn` (escena principal): piso en y=80, 3 plataformas, 2 dummies, pinchos, 2 puertas, interruptor de agua → puerta 1, antorcha → puerta 2, piscina a la izquierda, punto de riego.

## 8. Valores temporales (revertir antes del juego real)
- `elemental_power.gd`: `water_jet`, `water_breathing`, `irrigation` en true y los 4 elementos en `unlocked` solo para pruebas. Debe empezar vacío y desbloquearse con el Altar de la Chispa (Chorro) y el Gólem (Respiración + Riego).
- Costos de poder (`jet_cost=25`, `irrigation_cost=20`) provisionales.

## 9. Decisiones de diseño
- K es el poder principal; los secundarios son automáticos.
- Esencias solo para mejoras/puertas; energía aparte y recargable. Piezas de puzzle son otro sistema.
- Muerte = reaparecer en el último checkpoint y perder ~25% de monedas (recuperables). Flechas limitadas según GDD.

## 10. Pendiente / huecos conocidos
- Todo probado con input simulado; falta sentir a mano (gamepad, flechas nadando, zonas de agua solapadas).
- Sin arte de nado, de elementos ni de props; flechas infinitas y no recargan energía; no hay clase base de enemigo; reaparición solo en el spawn inicial; cámara sin límites ni salas; `player.gd` grande (conviene dividir); acentos/ñ en Kenney Mini por revisar.

## 11. Roadmap acordado
1. Sistema de salas + límites y transiciones de cámara.
2. Flechas limitadas (y recarga de energía con flechas).
3. Enemigo base.
4. Último checkpoint al morir + pérdida de monedas.
5. Detalles sueltos y commit de git.
6. Tiles (16 px, con los assets del usuario) y sala A1 (Camino de entrada), luego B1 y demás.
7. Después: arte de nado, visuales de armas elementales, esencias/coleccionables, textos de letreros/diálogos, poderes de Tierra, Fuego y Aire.

## 12. Mapa de archivos
- `scripts/`: player, elemental_power, elements, element_energy, element_wheel, oxygen_meter, hud, arrow, water_jet, elemental_torch, water_switch, gate, water_zone, irrigation_point, training_dummy, hazard.
- `scenes/`: test_level, hud, arrow, water_jet, elemental_torch, water_switch, gate, water_zone, irrigation_point, etc.
- `art/`: Collectibles, Font, Player (incl. `erek_frames.tres`), UI. `translations/texts.csv`. Docs: GDD, COMO_CREAR_SALAS, ARTE_PROMPTS, SUBIR_A_GITHUB.

## Historial
### 2026-11-19 · A1 rehecha desde cero (prueba de estilo)
- Problema visto en las salas viejas: cielo en degradado plano sin fondo en capas (el arte `art/Background/Forest/BG01.png` no se usaba), suelo como franja delgada sobre un vacío oscuro liso, terreno casi plano y decoración suelta.
- `tools/sector_a_builder.gd`: nuevo spec `"bg": true` → `_build_background()` crea un `ParallaxBackground` (capas: nubes con desvanecido hacia abajo, colinas BG01 lejanas más claras y colinas BG01 cercanas; `motion_scale.y = 0`, repetición horizontal de 400 px).
- A1 (80x24, base 20): camino plano → loma de 4 tiles con pendientes de 45° → hondonada con 2 plataformas finas (Small Grass) → subida con un escalón hasta la salida; salida más alta que la entrada. Props: cartel y cerco, árboles lejanos tintados en capa `b`, sauce en la loma, tronco, flores, faroles y roca elemental. Enemigos: Rata x21, Rata x40, Gota x68.
- Nota: el perfil de `TerrainShapes` empieza en x=-2 (OVERSCAN) y los tramos deben sumar cols+4 para cubrir hasta la salida.
- Props asentados: `_build_props` ahora comprueba que haya suelo plano (misma altura y sin tiles de pendiente) bajo todo el ancho del prop (solo el tronco en árboles) y, si no, lo mueve hasta 6 tiles al lugar válido más cercano sin solaparse con otros props; si no hay, avisa con `push_warning`. Antes los props en pendientes o bordes de escalón flotaban de un lado.
- Feedback del usuario aplicado: (1) se quitó el arbusto chico (`smallBush`) de A1; (2) enemigos trabados en el suelo: en `enemy.gd` `floor_max_angle = 50°` (las pendientes de 45° exactos contaban como pared) y `floor_snap_length = 10` (0 en voladores); `ground_ahead()` ahora lanza el rayo desde 12 px arriba de los pies (antes arrancaba dentro del tile en las subidas y el enemigo daba media vuelta). Probado 100 s simulados a 4x con un monitor: ningún enemigo se queda quieto más que su pausa de patrulla ni cambia de altura; (3) plataformas flotantes: ahora hay una meseta de roca que nace del suelo de la hondonada (R3/F3/D3) y encima dos plataformas finas en escalera (filas 17 y 15). El salto del jugador llega a ~3.5 tiles (320²/2/900 px).
- Los eval de `editor_manage game_eval` se abortan a los 8 s: para pruebas largas, agregar un nodo monitor con `GDScript.new()` + `set_script` y leerlo después.
### 2026-11-19 · A2 y A3 rehechas + capas de terreno traseras + acabado de pendientes
- **A1 la editó el usuario a mano: NO volver a correr el generador sobre A1** (copia en `_old_rooms3/a1_user_edit.tscn`). Comparando su A1 con la generada se vio qué hizo: bajo cada diagonal de pendiente, 2 filas debajo de ella, puso una pieza de roca que sigue la diagonal: atlas (8,4) bajo las bajadas y (11,4) bajo las subidas (el resto de diferencias eran solo variantes al azar de los tiles planos).
- `TerrainTools._place_underside` automatiza ese acabado para todo lo que se pinte con `paint()`.
- **Capas traseras** (`back` y `platforms_back` en el spec): TileMapLayers `GroundBack`, `GrassTipsBack`, `PlatformsBack` con z=-3 y tinte `BACK_TINT`, para que los salientes se vean detrás del suelo. `GroundBack` NO tiene colisión (primer intento con colisión creó paredes sólidas y los enemigos nacían dentro y se hundían); en su lugar `BackLedges` (StaticBody2D de una vía) pone colisión solo sobre la superficie de cada saliente: se sube saltando desde abajo y se pasa por delante. Probado: salto desde la terraza (y=496) aterriza en el saliente (y=464). `PlatformsBack` usa tiles de Small Grass (ya son de una vía).
- Fondo: la última capa de colinas lleva un `ColorRect` de relleno por debajo (en salas altas se veía el degradado del cielo abajo).
- **A2** (80x24): entrada baja → dos pasos a la meseta del altar (fila 17) con un risco trasero en dos escalones donde están las reliquias y la roca elemental → dos arenas de combate (filas 19 y 21) con un saliente trasero y una plataforma → subida de 4 hasta la salida. Enemigos: Mandrágora x22, Sátiro x36, Avispa x45 (aire), Lobo x62.
- **A3** (64x40): ladera de la fila 35 a la 13 alternando pendientes de 45° y escalones de 2 tiles, con salientes traseros y 2 plataformas traseras por terraza y un mirador arriba. Enemigos: Sátiro x13, Mandrágora x27, Avispa x34 (aire), Lobo x60.
- Enemigos: `ground_ahead` ahora llega 28 px bajo los pies (la colisión de las pendientes está ~5 px abajo; con 14 px el enemigo no bajaba pendientes y se quedaba parado en el borde). Probado en A3: el Sátiro persigue bajando la pendiente; ningún enemigo se hunde en el suelo.
- Lección: no poner enemigos ni props dentro de tiles con colisión; los bloques traseros no deben ser sólidos.
- Pendiente: la masa oscura bajo las laderas de A3 es muy grande (el tile no tiene textura de relleno).
### 2026-11-19 · Enemigos por zonas y ritmo
- Petición: demasiados enemigos, que no se sienta atacado todo el tiempo; que haya secciones (más adentro del bosque, enemigos distintos) y flow.
- `scripts/enemy_zones.gd` (`EnemyZones`): `SECTORS` (A-E, profundidad y tipos permitidos según el GDD), `ROOMS` (sector + presupuesto por sala; Lobo y Sátiro cuentan doble), reglas: separación mínima 20 tiles entre enemigos, 12 tiles de entradas/salidas, máx. 1 volador. `check()` devuelve los problemas; el generador y `World._enter_room` (solo builds de depuración) los muestran con `push_warning`. Guía de diseño en `docs/ENEMIGOS.md`.
- Sector A ahora: A1 = 1 enemigo (Rata en la loma; se quitaron Rata2 y Gota a mano en `a1.tscn`, sin regenerarla), A2 = 2 (Mandrágora que guarda el altar + Rata en la arena baja), A3 = 2 (Rata en la terraza media + Mandrágora cerca de la cima). Antes: 3 + 4 + 4 = 11; ahora 5. Sin Lobo/Sátiro/Avispa/Gota en A (llegan en B-D).
- Probado: las tres salas pasan `check_room` sin problemas y un caso malo genera los avisos esperados.
- Ajuste 2026-11-20 (1 por sala era poco): presupuestos A1 = 2, A2 = 3, A3 = 3 (8 en total, antes 11 al inicio y 5 tras el primer recorte); `MIN_GAP` 16 y `MIN_FROM_SPAWN` 10. A1: Rata x21 y Rata x47 (la segunda se duplicó a mano en `a1.tscn`, sin regenerar). A2: Mandrágora x26 (altar), Rata x44 (arena baja), Rata x62 (tramo final). A3: Rata x14, Mandrágora x30, Rata x48.
- Bug de la "planta enterrada flotando en una plataforma": en A3 la planta rosa, las flores rojas y la mandrágora enterrada quedaban justo delante de la plataforma trasera. El generador ahora evita las "zonas bajo plataformas traseras" (hasta 5 tiles sobre el suelo): los props se reubican o se omiten, y un enemigo ahí produce un aviso en `zone_problems`.
### 2026-11-20 · Zonas de patrulla + colisionador del jugador
- **Patrulla designada** (`enemy.gd`): `patrol_radius` (px, defecto 56 = ±3.5 tiles desde donde se coloca el enemigo; 0 = sin límite; en el spec del generador, `"range"` en tiles). `patrol_should_turn()` da la vuelta en pared, borde, límite de la zona y **al empezar una pendiente o escalón** (la patrulla es siempre en plano, caminar inclinado se veía raro); si algo lo saca de su zona (persecución, golpe) regresa a casa antes de seguir. Lo usan Rata, Lobo, Sátiro y Gota en su estado de patrulla; la persecución sí puede cruzar pendientes. `ground_y_ahead()` devuelve la altura del suelo adelante. Probado a 4x: ratas de A1 y A3 se quedan dentro de su radio y `y` constante.
- **Jugador se veía a través del tile**: el sprite mide ~25 px de ancho (cuerpo denso x -5..+8, capa hasta -12/-15, frente hasta +12) pero el colisionador era de 8 px, así que ~8 px del sprite quedaban dentro del muro. Ahora el colisionador es de **14x28** (`scenes/player.tscn`); sigue cabiendo en huecos de 1 tile (16 px). Probado con un bot (corre a la derecha y salta al topar): A1 llega a la salida y A3 sube hasta la cima sin atascarse, igual que antes. Queda un solo borde de ~5 px (la punta de la nariz/mano) que puede rozar el muro.
### 2026-11-20 · Rata con sprite doble en A1 + notas para reutilizar en otros capítulos
- **Bug**: la `Rat2` de A1 se hizo duplicando `Rat1` desde el editor; como los enemigos son `@tool` y construyen su cuerpo por código, el duplicado guardó en `a1.tscn` los hijos creados en ejecución (`_CollisionShape2D_…`, `_Node2D_…`, `_AnimatedSprite2D_…`, `Hurtbox`, `Contact`, `_Label_…`) y al jugar se construía otro cuerpo encima: sprite y colisiones dobles. Se reemplazó por una instancia limpia de `enemy_slime.tscn` (respaldo del archivo anterior en `_old_rooms3/a1_before_rat_fix.tscn`). Verificado: Rat1 y Rat2 tienen cada uno 1 sprite y los mismos 5 hijos.
- **Prevención**: `Enemy._build_body()` descarta cualquier hijo guardado en la escena antes de construir el cuerpo (las escenas de enemigos no traen hijos propios). Aun así, para colocar un enemigo nuevo en el editor: instanciar la escena (`scenes/enemy_*.tscn`), no duplicar uno ya colocado.
- **Para los capítulos siguientes** (enemigos y tiles distintos), lo reutilizable es data, no código:
  - Enemigos nuevos: un script que extienda `Enemy` (`_setup`, `_make_frames`, `_think`; en patrulla usar `patrol_should_turn()`), su escena en `scenes/`, su clave en `SectorABuilder.ENEMY_SCENES` y su tipo en `EnemyZones.SECTORS[...].kinds` (más `TOUGH` si es duro).
  - Zonas/ritmo: capítulos o sectores nuevos = nuevas entradas en `EnemyZones.SECTORS` y `EnemyZones.ROOMS` (presupuesto por sala); reglas en `docs/ENEMIGOS.md`.
  - Tiles nuevos: cada spec del generador acepta `"tileset": "res://tiles/<capitulo>_tileset.tres"` (por defecto el del bosque). `TerrainTools` asume el atlas del bosque (Terrain Set modo Match Sides, pendientes de 45° en (8..11, 2..5), roca en (2..3, 4..5)); un tileset con otro atlas necesita su propio mapa de piezas en `TerrainTools` (o una copia por capítulo).
  - Fondo: `SectorABuilder._build_background` y `BG_DIR` (colinas/nubes del bosque); cambiar la lista de capas por las del capítulo.
  - Salas con capas traseras: `back` / `platforms_back` en el spec (ver arriba); las salas editadas a mano NO se regeneran.
- Respaldo de la A1 anterior: `_old_rooms3/a1.tscn`. A2 y A3 NO se regeneraron (siguen como estaban). Si el estilo gusta, se aplica `"bg": true` y el mismo enfoque a A2/A3.
- Pendiente de decidir: el relleno oscuro bajo el pasto es del arte del tile (Main Grass).
### 2026-11-18 · Salas rehechas con casi nada de pendientes + enemigos que no reaparecen
- Petición: menos tiles inclinados, más escalones/plataformas, menos enemigos, y "vida única" (interpretado como: un enemigo vencido NO reaparece al volver a la sala; si se refería a otra cosa, ajustar).
- `tools/sector_a_builder.gd` regenerado (sobrescribió a1/a2/a3, incluidas las ediciones manuales del usuario en A1/A2; copia anterior en `_old_rooms/`, con `.gdignore` para que Godot no la escanee). Nuevo spec `enemies: [{k, x, row?, air?}]` (k = Rat, Wolf, Wasp, Satyr, Mandrake, Gota) que los coloca en el nodo `Enemies` con nombres únicos (Rat1, Rat2...).
- A1 (80x24): escalones de 1 tile, una colina corta de pendiente (2 tiles) y 9 islas + 1 pilar. Enemigos 3: Rata (x21), Gota (x47), Rata (x66).
- A2 (80x24): escalones hasta una arena elevada, bajada escalonada, una colina de pendiente corta, 11 islas y 3 pilares bajos. Enemigos 4: Sátiro (x27), Mandrágora (x43), Avispa (x36, en el aire), Lobo (x66).
- A3 (64x40): escalera de acantilados de 2-3 tiles (sin pendientes) con 6 islas como ruta alterna. Enemigos 4: Sátiro (x24), Mandrágora (x39), Avispa (x46), Lobo en la cima (x62).
- Verificado con un bot (camina y salta): atraviesa A1 y A2 hasta la salida y sube A3 hasta arriba; capturas de las tres salas revisadas.
- `World.defeated` (sala -> nombres de enemigos vencidos) + `_track_enemies()`: al entrar a una sala se quitan los vencidos y se anotan los que mueren. Vive mientras dure la partida (aún no se guarda en disco).
- Nota: A3 quedó como una escalera grande y lisa; falta variedad (más islas, entrantes) cuando se decore.

### 2026-11-18 · Botín de enemigos + enemigos en las salas
**Botín (`scripts/pickup.gd`, `Pickup`)**
- Al morir, cada enemigo tira los dados (`Enemy._drop_loot`, en diferido porque la muerte puede venir de una señal de colisión). Exports del grupo "Botín": `drop_chance`, `drop_count` (mín-máx), y pesos `drop_weight_coin / food / essence`.
- Tipos: **moneda** (bronce 1 con 70 %, plata 5 con 25 %, oro 10 con 5 %), **comida** (manzana cura 2 medios corazones, plátano 1; no se recoge con la vida llena, se queda en el suelo) y **esencia** (azul/verde/roja/amarilla = Agua/Tierra/Fuego/Aire, índice = `Elements.Type`).
- Comportamiento: salta al aparecer, rebota una vez, flota, monedas y esencias se atraen al jugador a 42 px, desaparecen a los 14 s (parpadean los últimos 3). Tamaño en el mundo 0.6 del icono (`WORLD_SCALE`).
- Jugador: `coins`, `essence_counts[4]`, `add_coins`, `add_essence`, `essences_total`, `heal(medios_corazones)`, señales `coins_changed` y `essences_changed`; el HUD se conecta solo (contadores de monedas y esencias de la derecha). El jugador persiste entre salas, así que la cartera también.
- Tablas por tipo (prob. / reparto moneda-comida-esencia): rata 55 % (8/1/1), avispa 45 % (5/1/4), lobo 90 % x2-3 (5/3/2), sátiro 85 % x2-3 (5/2/3), mandrágora 70 % (3/3/4), gota 60 % (3/1/6).
- Probado: soltó 5 objetos, el jugador cobró monedas y esencias y se curó de 2 a 6.
- Pendiente: usos de las esencias (energía de elemento, tienda...), llaves y pociones (arte listo en `art/Collectibles`), guardar la cartera.

**Enemigos en las salas** (nodo `Enemies` en cada sala; posiciones = pies, medidas con rayos sobre tramos planos)
- A1 (suave): Rata (432,240), Rata (1096,304), Gota (832,272), Avispa (640,240).
- A2 (combate): Rata (232,304), Sátiro (472,240), Mandrágora (744,272), Gota (824,240), Lobo (1096,304), Avispa (576,250).
- A3 (subida): Rata (352,448), Sátiro (288,496), Mandrágora (600,352), Gota (656,304), Avispa (700,270), Lobo (928,176 en la cima).
- Verificado: todos aterrizan sobre el suelo. Las salas se instancian de nuevo al entrar, así que los enemigos reaparecen cada vez (persistencia de estado entre salas sigue pendiente).

### 2026-11-18 · Armas elementales con los 4 elementos
- Bug: solo el Agua se aplicaba a la espada y las flechas (`ElementalPower.WEAPON_ELEMENTS = [WATER]`); con Tierra, Fuego o Aire las flechas salían normales aunque el elemento estuviera activo. Ahora los 4 elementos tiñen la espada y las flechas con su color, gastan energía (3 por golpe, 5 por flecha) y activan lo que reacciona (`on_element_hit`: p. ej. Fuego enciende la antorcha, Agua la apaga). Verificado: las flechas de los 4 elementos salen con `element` y color correctos.
- **Decisión del usuario: se define más adelante, según avance el desarrollo** (ideas sin comprometer: Fuego daño extra/quemadura, Tierra aturdimiento, Aire empuje/levantar). Pendiente: el efecto propio de Tierra/Fuego/Aire sobre los enemigos (hoy solo el Agua empuja); el chorro de poder (K) solo existe para Agua.

### 2026-11-18 · Enemigos base + terreno de Sector A (sesión larga)
**Enemigos (técnica base)**
- `scripts/enemy.gd` (`Enemy`, extiende CharacterBody2D): crea solo cuerpo, `Hurtbox` (capa 16, lo que golpean espada y flechas) y zona `Contact` (máscara 2, daña con `take_hit(x, contact_damage)`). Mismo contrato que `TrainingDummy`: `take_damage(amount, from_x)` y `push(dir, force)`. Los tipos sobreescriben `_setup()` (datos: tamaño/color/vida, se llama ANTES de construir el cuerpo) y `_think(delta)` (IA). Ayudas: `dx_to_player()`, `ground_ahead()`, `_stun`, destello al golpe, señal `died`. Por ahora son polígonos de color (sin arte).
- `EnemySlime` (limo): patrulla, da la vuelta en pared o borde. 2 vida, 1 medio corazón.
- `EnemyBoar` (jabalí): patrulla; si ve al jugador al frente (130 px, mismo nivel) avisa 0.5 s parpadeando rojo, embiste 0.7 s y se aturde 0.9 s (ventana para golpearlo). 3 vida, daño 2. Un golpe lo saca de la embestida.
- `EnemyBat` (murciélago): vuela sin gravedad, flota en su origen, pica hacia donde estabas al detectarte (110 px) y vuelve; 1 vida.
- Escenas `scenes/enemy_slime|boar|bat.tscn`, colocadas en `scenes/test_level.tscn` (x 560 / 820 / 700, a la derecha). Probado con un runner: patrullas, estados del jabalí y del murciélago, daño al jugador y muerte.
- **Sprites** (`art/Enemies/Forest/`): Limo→**Rata** (hoja `Rat/rat-Sheet.png`, celdas 42x22), Jabalí→**Lobo** (`Wolf/werewolf-*`), Murciélago→**Avispa** (`Wasp/*`). Las clases conservan los nombres viejos (EnemySlime/Boar/Bat). Las animaciones se arman por código (`Enemy.add_files_anim` / `add_sheet_anim`) en `_make_frames()`; si un tipo no devuelve frames se dibuja la caja de color. `sprite_faces` indica hacia dónde mira el dibujo original (todos miran a la izquierda).
- **Animación de muerte**: al morir se reproduce `die`, el cuerpo deja de colisionar con el jugador pero cae al suelo, y luego se desvanece y se libera.
- **Pisotón**: export `stompable` (+ `stomp_bounce` 260, `stomp_bounce_held` 360 manteniendo salto). Rata y avispa se pisan: mueren y llaman a `Player.bounce(force, force_held)` (nuevo en `player.gd`). El lobo NO se pisa (daña también desde arriba). La detección usa el historial de 6 cuadros de la Y del jugador, porque el contacto del Area2D llega con 1-2 cuadros de retraso y el jugador cae rápido; un golpe de lado nunca cuenta como pisotón. Probado: rata muerta, rebote de -260.
- **Ajustes de animación**: rata = fila 1 de la hoja para caminar (fila 0 quieta, fila 3 golpe, fila 5 aplastada para morir). Avispa: patrulla de lado a lado (±45 px de su origen) con la animación `move`, picada con `attack`; antes cambiaba de dirección cada cuadro por el vaivén y se veía mal. Lobo: nuevo estado ATTACK, un zarpazo cuando el jugador está a menos de 36 px (animación `attack` de 7 cuadros: 0-2 preparación con el brazo atrás, 3-5 garra activa con daño 2 y pequeño impulso adelante, enfriamiento 0.9 s). Funciona desde patrulla y también a mitad de la embestida. Probado: ATTACK→RECOVER→PATROL y daño al jugador.
- **Pausas de patrulla**: `Enemy.patrol_paused(delta)` (grupo Patrulla: `patrol_walk_time` 2.5-4.5 s, `patrol_pause_time` 0.8-1.6 s, al azar). Rata, lobo y avispa se detienen en idle y luego siguen; si ven al jugador durante la pausa reaccionan igual.
- **Avispa tras la picada**: nuevo estado PAUSE: se queda quieta en idle `recover_time` (1 s) antes de volver a patrullar; es la ventana para golpearla. Un golpe la manda directo a RETURN.
- **Tres enemigos más** (en `test_level`; los 6 enemigos están juntos a la IZQUIERDA del jugador, después del estanque: Rata x=-400, Sátiro -500, Mandrágora -600, Gota -690, Lobo -790, Avispa -880; a la derecha las compuertas Gate1/Gate2 bloquean el paso):
  - `EnemySatyr`: guerrero de 4 vida. Patrulla; si te ve (130 px al frente o <40 px) te persigue (78 px/s), se detiene en bordes/paredes, y cerca (34 px) tajo con espada: levanta (cuadros 0-2) y corta (3-4, daño 2). Pierde el interés a 190 px o si cambias de nivel. No pisable.
  - `EnemyMandrake`: emboscadora. Enterrada (se ve un brote, sin daño ni colisión) hasta que te acercas a 60 px; sale (`show`), persigue y ataca con raíces (cuadros 4-5, daño 1); si estás lejos 2 s se vuelve a enterrar. Pisable.
  - `EnemyWater` (Gota de agua) + `EnemyShot`: patrulla lento; si te ve al frente (150 px) se prepara y dispara una gota (`EnemyShot.spawn`, 120 px/s, daño 1, se rompe en paredes). Pisable. Su dibujo mira a la derecha (`sprite_faces = 1`). La fila 0 de la hoja se usó como caminar (sin confirmar).
- Base: helpers `build_melee(reach, h)` / `melee_tick(active, dmg)` / `melee_off()` para golpes cuerpo a cuerpo; `death_puff` (por defecto NO, el usuario prefirió el fade out): si se activa, al terminar su animación de muerte aparece la nube de estrellas `art/Enemies/Forest/enemy-deadth.png` (6 cuadros de 40x41) y el enemigo se libera. Arreglo: no consultar `get_overlapping_bodies` con monitoring apagado (error en consola).
- Enemigos con `@tool`: se ven en el editor al colocarlos (sin IA).
- Sprites aún sin usar: Sátiro (`Satyr/`), Mandrágora (`Plant/`, tiene run/jump/attack/show) y elemento de agua (`Mini Element/`, hoja 640x320 de celdas 64x64 + proyectil). Pendientes de convertir en tipos.
- Pendiente: drops (monedas), reaparición por sala y estado entre salas.

**Terreno y salas**
- Terrains nuevos en `forest_tileset.tres`: "Small Grass" (plataformas finas one-way, fila 2) y "Pilar" (columnas). `TerrainTools`: rocas bajo pendientes, capas de pasto frontal (`GrassFront` con shader, z 2) y `Platforms` (z 2).
- A1/A2/A3 rehechas solo con tiles (sin decoración); A1/A2 luego editadas por el usuario: no regenerar.
- Colisión de pendientes bajada 5 px y suelos completos con tope en -3; jugador con `_snap_on_slope`, `_stick_to_slope`/`_grounded()`, cuerpo 8x28 y `floor_snap_length` 18: subir y bajar pendientes ya es suave.
- one_way de Small Grass restaurado en disco: reiniciar Godot (Cmd+Q, No guardar) antes de guardar el TileSet.

### TileSet rehecho por el usuario (video de terrains): modo Match Corners
- El usuario siguió el video sbv35boXqac (Match Corners, pintar por dentro de cada tile) y rehizo el Terrain Set en modo 1 con las 36 piezas del marco. Se conserva ese diseño. Copia previa a mis arreglos: `tiles/forest_tileset.tres.user_corners_v2`.
- Arreglos aplicados: (0,4) y (0,5) no tenían `terrain = 0` (hueco en la pared izquierda); las 12 piezas del anillo con sombra (cols 1/4 filas 3-6 y (2,3),(3,3),(2,6),(3,6)) tienen `probability = 0.0` para que el pincel no las reparta al azar: las coloca `TerrainTools.shade` / `ForestGround`.
- Verificado en juego: bloque con hueco, escalera, L y la galería con pendientes cierran bien en modo Corners.
- Pendiente del lado del usuario: reiniciar Godot (Cmd+Q, No guardar) para que cargue el TileSet del disco; mientras tanto su copia en memoria es la anterior a estos arreglos.

### ForestGround: acabado automático al pintar en el editor
- `scripts/forest_ground.gd` (`ForestGround`, @tool, extiende TileMapLayer): revisa la capa cada 0.25 s en el editor y, si cambió, aplica `TerrainTools.shade` + `rebuild_tips` sobre la capa hermana `GrassTips`. Verificado pintando con tilemap_manage: las sombras se colocan solas.
- La señal `changed` NO se dispara en el editor al pintar con las herramientas; por eso se usa polling por firma.
- Lienzo de pintado: `rooms/_autoshade_test.tscn` (Ground = ForestGround + GrassTips, TileSet forest). Para otras escenas: TileMapLayer + este script.
- Piezas fuera del Terrain por diseño: anillo con sombra (cols 1/4, filas 3/6; las coloca `shade`) y pendientes de 45° (script/bloques 2x2).

### Relleno con sombra + script de acabado
- El anillo interior del atlas (cols 1 y 4, filas 3 y 6) son piezas de relleno con sombra de borde; Terrain no puede ubicarlas, así que `TerrainTools.shade(ground)` las coloca según los vecinos de borde (se llama dentro de `paint`).
- Para pintado a mano: `tools/shade_terrain.gd` (EditorScript, Archivo > Ejecutar) aplica `shade` y reconstruye `GrassTips`.
- Importante: `project_run` con autosave=true pisó el TileSet con la copia en memoria del editor; usar `autosave:false`. Para recargar un TileSet cambiado por fuera hay que reiniciar Godot (`editor_manage quit` no guarda).

### Terrain en modo Match Sides (arregla el pintado a mano)
- El Terrain Set pasó de "Corners and Sides" a **Match Sides** (`terrain_set_0/mode = 2`): como el atlas no trae esquinas interiores, el modo con esquinas dejaba huecos y cortes al pintar con el pincel. Con 4 lados no hace falta ningún parche. Copia anterior: `tiles/forest_tileset.tres.before_sides`.
- Roles (bits de lados con terreno): TL cap (0,2); T (1-4,2); TR cap (5,2); L (0,3..6); R (5,3..6); BL (0,7); B (1-4,7); BR (5,7); relleno (2-3,4-5).
- `TerrainTools.LEGACY_FIXES = false` (fix_step_feet ya no se usa). Se mantiene la limpieza de relleno bajo pendientes.
- Las pendientes (8,2)/(9,2)/(9,3)/(8,3) y (10,2)/(11,2)/(10,3)/(11,3) NO son Terrain: se colocan con `TerrainTools`/`TerrainShapes` (o a mano en bloques 2x2).

### Galería de terrenos y generador de formas
- `scripts/terrain_shapes.gd` (`TerrainShapes`): perfiles por segmentos (flat, up, down, rise, drop, gap) → `profile()` / `paint_profile()`. Pendientes con `len` par.
- `rooms/terrain_gallery.tscn`: 17 formas (escaleras, colinas, valles 4/8, rampa 12, zigzag, meseta, torre, fosos, cañón…) + 6 islas flotantes. Se regenera con `TerrainShapes.build_gallery(ground, tips)`.
- TileSet: creados tiles (9,2) y (10,2) (piezas puente, sin colisión); quitado el Terrain de las piezas de arte de columnas 6-13 (contaminaban el relleno). Copias: `forest_tileset.tres.before_bridges`, `.before_strip`, `.user_backup`.
- `TerrainTools`: relleno interior en toda la capa (celdas con 4 vecinos sólidos), porque el atlas no trae esquinas internas.
- Godot se cerró una vez al abrir con patrones guardados en el TileSet: no usar `TileSet.add_pattern`.

### Terrain corregido + pendientes de 45°
- El TileSet editado a mano había perdido `terrain = 0` (centro) y los bits de borde; se reaplicaron los roles (copia en `tiles/forest_tileset.tres.user_backup`). Se sacaron del Terrain las piezas raras/columna 6.
- Pendientes: tiles (8,2)/(9,3) bajan a la derecha y (11,2)/(10,3) suben; rellenos oscuros del atlas ahora con colisión. `TerrainTools.paint(ground, tips, cells, slopes)` con `slopes=[{x,y,len,dir}]` (dir 1 baja a la derecha, -1 sube); `_fill_under_slopes` evita paredes sueltas bajo la pendiente.
- Player: auto-escalón de 6 px (`_try_step_up`) para el desnivel suelo/pendiente.

### 2026-11-18 · Sistema de salas conectadas (Sector A)
- Nuevo `scenes/world.tscn` (escena principal): sala actual + jugador y HUD persistentes + cielo en degradado + fundido. `World.change_room(id, spawn)`; `World.ROOMS` registra las salas.
- `Room` (límites de cámara, spawns, muros invisibles sin salida) y `RoomExit` (franja en el borde, enum `ExitSide`; no se puede llamar `Side`, choca con el enum global de Godot).
- `tools/sector_a_builder.gd` genera `rooms/a1`, `a2`, `a3` (terreno con `TerrainTools`, decoración automática solo sobre tramos planos, dummies, spawns y salidas). A1→A2→A3 y el regreso probados cruzando los bordes.
- La escena de prueba vieja sigue en `scenes/test_level.tscn` (no es la principal).
- Docs: `docs/COMO_CREAR_SALAS.md` reescrita al sistema real; `docs/MAPA.md` con el mapa de conexiones.
- Pendiente: pendientes diagonales y cuevas (pieza en V de Main Grass, colisión diagonal), fondo en capas (lo aporta el usuario), plataformas finas con Small Grass, checkpoints y reaparición por sala, enemigo base, estado entre salas (monedas, enemigos), B1.
### 2026-11-18 · A1 descartada: se rehace con Terrains (autotile)
- Se armó `rooms/a1.tscn` colocando tiles a mano por código (cols 1-4 al azar, caps, paredes). No gustó: terreno plano y repetitivo, pasto mal puesto y decoración mal colocada. Se borró A1 (está en la papelera) y `test_level` vuelve a ser la escena principal.
- Se conserva `scripts/room.gd` (`Room`: límites de cámara y muros invisibles) y `tiles/forest_tileset.tres` (atlas + colisión, SIN terrains todavía).
- Aprendido del video "Simple Auto-Tile in Godot 4.4" (Mostly Mad Productions): TileSet con Physics Layer (colisión por tile) + Terrain Set con un Terrain, pintar los bits de vecindad en cada tile y luego pintar el mapa con Terrains en modo Connect; así Godot elige solo bordes y esquinas. Filtro de textura en Nearest para pixel art.
- Hecho: `tiles/forest_tileset.tres` ahora tiene el Terrain Set 0 (modo Match Corners and Sides) con el terreno "Ground". Main Grass: fila 2 = borde superior y esquinas, cols 0 y 5 filas 3-6 = paredes, fila 7 = borde inferior, interior solo cols 2-3 filas 4-5 (y 2-3 filas 3 y 6 con probabilidad 0.12 como parches de roca). Cols 1 y 4 NO están en el terrain (hacían rayas). Se configuró por script con `editor_manage game_eval` (API `TileData.set_terrain_peering_bit`) y se guardó con `ResourceSaver.save`.
- Prueba: `rooms/terrain_test.tscn` (60x24 tiles) pintada con `TileMapLayer.set_cells_terrain_connect(cells, 0, 0)`; las puntas de pasto (fila 1) van en la capa GrassTips (z 1) sobre cada tile de fila 2. Los escalones, paredes, bordes inferiores y bloques flotantes (2 y 4 de grosor) salen con bordes correctos solos.
- Ajuste: se quitaron los parches de roca del relleno (tiles 2-3 filas 3 y 6 salieron del terrain). El atlas NO tiene esquinas interiores: al pie de un escalón Godot ponía borde derecho + pared izquierda y quedaba una grieta oscura. Se arregló con `scripts/terrain_tools.gd` (`TerrainTools.paint(ground, tips, celdas)`): pinta con Terrains, luego `fix_step_feet` convierte el pie en borde plano y da pared de roca a la masa alta, y `rebuild_tips` repone las puntas de pasto. Probado subiendo y bajando escalones en `rooms/terrain_test.tscn`.
- Siguiente: plataformas finas con Small Grass (segundo terrain) y rehacer A1 con `TerrainTools`
- Notas del atlas Main Grass: fila 2 = borde con pasto; fila 1 = solo puntas de pasto (2 px, sin colisión); fila 3 = roca bajo el pasto; filas 4-5 = relleno oscuro; fila 6 = roca del fondo; fila 7 = borde inferior; la pieza en V (cols 8-11) no se usó.
- `docs/COMO_CREAR_SALAS.md` describe un sistema de salas por datos (`rooms/*.gd`) que NO es el real; las salas son escenas.
### 2026-11-18 · Agua completa y base de elementos
- Poderes de Agua, rueda, opción sin elemento, props de prueba, HUD ajustado.
### 2026-11-17 · Arco y render
- Arco con animaciones, cambio de arma, icono en HUD, render pixel-clean.
### Antes · Base
- Movimiento, espada, vida/daño, HUD inicial, localización.

## Rediseño de A1/A2/A3 (salas tranquilas y compuestas a mano)
- Pedido: menos plataformas/repetición, salas únicas y con detalle profesional.
- `tools/sector_a_builder.gd`: nuevo sistema de **props autorales** (`props` en cada spec): `{f|tree+c, x, l (b/m/f), tint, flip, row, dy}`. Recorta cada sprite a su rect opaco y lo ancla por la base al suelo. Capas: `Props_b` (z -4, árboles lejanos teñidos), `Props_m` (z -1), `Props_f` (z 3, plantas pequeñas al frente). Árboles salen de `Trees TileSet.png` (filas willow_s/willow_l/round_m/round_l/pine_s/pine_l, 4 colores).
- **A1 Claro de entrada**: sendero casi plano bajo sauces, cartel, cerco, tronco, farol y roca elemental al fondo; 2 islas pequeñas con plantas. Ratas + Gota.
- **A2 Altar del bosque**: santuario central (2 reliquias, roca elemental vacía, faroles) entre coníferas rojas/moradas; 2 islas. Sátiro, Mandrágora, Avispa, Lobo.
- **A3 La ladera**: 6 terrazas amplias de 3 tiles, sin plataformas, un árbol distinto por terraza y un mirador arriba.
- Respaldo de las salas anteriores: `_old_rooms2/` (y `_old_rooms/`).
- Ajuste posterior: decoración reducida a ~10 props por sala (un árbol protagonista + 1-2 hitos); el relleno de suelo ahora baja 10 filas bajo la sala para que el borde rocoso inferior no se vea.
- Ajuste: se quitaron las plataformas flotantes de A1–A3 y la decoración se agrupó en rincones con sentido (entrada con cartel y cerco, arboleda, santuario de salida/altar); sin árboles de fondo, porque ya hay background.
