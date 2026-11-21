# Enemigos: ritmo y zonas

Objetivo: que el jugador **no se sienta atacado todo el tiempo**. Los enemigos son un *encuentro* con sentido, no relleno.
El registro vive en `scripts/enemy_zones.gd` (`EnemyZones`); el generador y `World` avisan (`push_warning`) si una sala rompe las reglas.

## Ritmo (calma → tensión → alivio)
- Una sala suele tener **0 a 2 encuentros**. Hay salas sin enemigos a propósito (descanso, puzzle, tienda, vista bonita).
- Un encuentro = **un enemigo (o dos muy distintos)** con una idea: guardar un altar, vigilar una salida, emboscar en una subida.
- **Separación mínima entre enemigos: 20 tiles** (sin oleadas) y **12 tiles** desde cualquier entrada/salida.
- **Un solo volador** por sala. Los duros (Lobo, Sátiro) cuentan doble en el presupuesto.
- Los enemigos vencidos no reaparecen en la partida (`World.defeated`), así que volver a una sala es tranquilo.
- Colócalos en tramos planos, nunca dentro de tiles con colisión.

## Zonas (siguen el GDD, sección 5)
| Sector | Nombre | Profundidad | Enemigos permitidos |
|---|---|---|---|
| A | Camino de entrada | 0 | Rata, Mandrágora |
| B | Claro Cristalino | 1 | Rata, Mandrágora, Avispa |
| C | Río y Cascadas | 2 | Lobo, Avispa, Gota, Rata |
| D | Raíces del Gran Árbol | 3 | Mandrágora, Sátiro, Gota |
| E | Lago del Gólem | 4 | Lobo, Sátiro, Gota, Avispa, Mandrágora |

Cuanto más adentro del bosque, más variedad y más dureza; cada sector introduce algo nuevo y no reutiliza todo.

## Presupuesto por sala (puntos de amenaza)
`EnemyZones.ROOMS`: sector + presupuesto. Rata/Mandrágora/Avispa/Gota = 1 punto, Lobo/Sátiro = 2.
- Sector A hoy: **A1 = 1** (una rata en la loma), **A2 = 2** (mandrágora que guarda el altar + rata en la arena baja), **A3 = 2** (rata en la terraza media + mandrágora cerca de la cima).

## Para añadir una sala o sector
1. Registra la sala en `EnemyZones.ROOMS` (sector y presupuesto) y, si es un sector nuevo, ajusta `SECTORS`.
2. Pon `"enemies": [{k, x}, ...]` en el spec (`tools/sector_a_builder.gd`) o coloca las escenas en el nodo `Enemies` de la sala.
3. Corre el juego: los avisos de `EnemyZones` salen en la consola/depurador si algo no cumple.

## Pendiente
- Jefes y mini-jefes (Gólem de Agua, mini-jefe del sector D) quedan fuera de este presupuesto.
- Variantes "evolucionadas por el agua" por sector (GDD sección 4).
