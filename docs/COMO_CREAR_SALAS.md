# Cómo funcionan las salas (sistema real)

Reescrita el 2026-11-18. La versión anterior describía un sistema por datos (`rooms/*.gd`) que nunca existió.

## Piezas
| Archivo | Qué hace |
|---|---|
| `scenes/world.tscn` (escena principal) | Contiene la sala actual (`RoomHolder`), al **jugador** y al **HUD**, el cielo y el fundido. El jugador y el HUD persisten entre salas. |
| `scripts/world.gd` (`World`) | `ROOMS` registra cada sala (id → escena). `change_room(id, spawn)` hace fundido, cambia la sala, coloca al jugador y aplica los límites de cámara. Guarda `visited`. |
| `scripts/room.gd` (`Room`) | Raíz de cada sala: `cols`, `rows`, `room_id`, `room_title`. Da `get_spawn()`, límites de cámara y crea muros invisibles en los lados izquierdo y derecho **sin salida**. |
| `scripts/room_exit.gd` (`RoomExit`) | Franja pegada al borde. Al tocarla el jugador cambia a `target_room` / `target_spawn`. Lado: `ExitSide` LEFT, RIGHT, UP, DOWN. |
| `scripts/terrain_tools.gd` (`TerrainTools`) | Pinta terreno con el Terrain Set del bosque y arregla los pies de escalón. |
| `tools/sector_a_builder.gd` (`SectorABuilder`) | Genera `rooms/a1-a3.tscn` desde una descripción corta. |
| `tiles/forest_tileset.tres` | TileSet 16 px con colisión y Terrain Set 0 ("Ground"). |

## Estructura de una sala (`rooms/<id>.tscn`)
- Raíz con `room.gd`.
- `Ground` (TileMapLayer) y `GrassTips` (TileMapLayer, z 1, sin colisión: las puntas de pasto).
- `Spawns`: Marker2D con nombre (`default`, `left`, `right`...). Su posición son los **pies** del jugador.
- `Exits`: RoomExit con su CollisionShape2D, fuera del borde de la sala.
- `Decor`: Sprite2D sin colisión. Enemigos/objetos como instancias.
- El terreno se extiende 2 tiles fuera de la sala (OVERSCAN) para que nadie caiga al cruzar una salida.

## Añadir o conectar una sala
1. Crear `rooms/<id>.tscn` (con el constructor o a mano) y registrarla en `World.ROOMS`.
2. En la sala origen añadir un `RoomExit` con `target_room` y `target_spawn` (el spawn **de la sala destino**).
3. En la sala destino crear el Marker2D de ese spawn y, para volver, su propio `RoomExit`.
4. Cuidar que el suelo en el borde de unión quede a una altura razonable en ambas salas.

## Con el constructor
`SectorABuilder.specs()` describe cada sala: `cols`, `rows`, `base` (fila del suelo), `segments` `[x0, x1, fila]`, `spawns`, `exits`, `dummies` y `fixed` (decoración fija). Se ejecuta con `editor_manage game_eval` → `return SectorABuilder.build_all(get_tree())`. **Sobrescribe** las salas: si editaste una a mano, no la regeneres.

## Medidas
Tile = 16 px. Pantalla 640x360 (40 x 22,5 tiles). Salto de Erek ≈ 57 px (3,5 tiles), sin escalón automático: un escalón de 1 tile exige saltar. Escalones de 2 tiles se suben bien; 3 tiles es el límite.

## Límites actuales
- La sala se genera con terreno rectangular; las pendientes diagonales y cuevas aún no existen.
- Reaparición: en la entrada de la sala actual (aún sin checkpoints).
- Lo que se recuerda entre salas (monedas, checkpoint, enemigos) aún no está implementado.
- Textos: `room_title` es una clave pendiente de conectar a Localization.
