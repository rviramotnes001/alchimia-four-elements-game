# Mapa de salas y conexiones

Actualizado 2026-11-18. Cada flecha es un `RoomExit`; el nombre entre paréntesis es el spawn de destino.

```
 Sector A - Camino de entrada
 ┌──────────────┐        ┌──────────────┐        ┌───────────────────┐
 │ A1  80x24    │ ─────► │ A2  80x24    │ ─────► │ A3  64x40         │
 │ (inicio)     │ ◄───── │ combate      │ ◄───── │ Subida al Claro   │
 └──────────────┘        └──────────────┘        └───────────────────┘
        A1.right → A2 (left)   A2.right → A3 (left)    A3.right → B1 (pendiente)
        A2.left  → A1 (right)  A3.left  → A2 (right)
```

| Sala | Tamaño (tiles) | Entradas (spawn) | Salidas |
|---|---|---|---|
| a1 | 80x24 | default (inicio), right (desde A2) | right → a2 |
| a2 | 80x24 | left (desde A1), right (desde A3) | left → a1, right → a3 |
| a3 | 64x40 | left (desde A2), right (futura, desde B1) | left → a2 (la derecha queda con muro hasta que exista b1) |

Enemigos (actualizado 2026-11-18, salas rehechas): A1 = 2 ratas + gota; A2 = sátiro, mandrágora, avispa, lobo; A3 = sátiro, mandrágora, avispa, lobo (cima). Los vencidos no reaparecen.

Pendiente: Sector B (Claro Cristalino, salas 4-7) cuelga de la cima de A3; después C, D y E (ver GDD sección 5).
