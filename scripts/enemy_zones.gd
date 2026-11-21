class_name EnemyZones
extends RefCounted
## Registro de enemigos por zona: qué tipos salen en cada sector del bosque y cuántos por sala.
## Idea: cuanto más adentro del bosque, más variedad y más dureza, pero SIEMPRE con espacios tranquilos
## entre encuentros (ritmo: calma -> tensión -> alivio). Reglas completas en docs/ENEMIGOS.md.
##
## Para una sala nueva: añádela a ROOMS (sector + presupuesto de enemigos) y úsala en el spec con
## "enemies": [{k, x}, ...]. El generador (tools/sector_a_builder.gd) y World avisan con push_warning
## si algo rompe las reglas.

## Tipos (claves de los specs): Rat, Mandrake, Wasp, Gota, Wolf, Satyr.
## `kinds`: lo que puede aparecer en ese sector. `tough`: tipos duros (daño 2 o muy móviles) que cuentan doble.
const SECTORS := {
	# A · Camino de entrada: tutorial. Solo lo básico; la mandrágora es el primer "enemigo de verdad" (GDD).
	"A": {"name": "Camino de entrada", "depth": 0, "kinds": ["Rat", "Mandrake"]},
	# B · Claro Cristalino: aún tranquilo; entra la avispa (vuela) pero sin chocar con enemigos duros.
	"B": {"name": "Claro Cristalino", "depth": 1, "kinds": ["Rat", "Mandrake", "Wasp"]},
	# C · Río y Cascadas: agua. Lobo y avispa (GDD) y los espíritus de agua (Gota).
	"C": {"name": "Río y Cascadas", "depth": 2, "kinds": ["Wolf", "Wasp", "Gota", "Rat"]},
	# D · Raíces del Gran Árbol: plantas y sátiros (GDD).
	"D": {"name": "Raíces del Gran Árbol", "depth": 3, "kinds": ["Mandrake", "Satyr", "Gota"]},
	# E · Lago del Gólem: mezcla de todo, el más duro.
	"E": {"name": "Lago del Gólem", "depth": 4, "kinds": ["Wolf", "Satyr", "Gota", "Wasp", "Mandrake"]},
}
const TOUGH := ["Wolf", "Satyr"]

## Salas registradas: sector y presupuesto (puntos de amenaza máximos; los duros valen 2).
## Una sala sin enemigos (descanso, tienda, puzzle) es válida y a veces la mejor opción.
const ROOMS := {
	&"a1": {"sector": "A", "budget": 2},
	&"a2": {"sector": "A", "budget": 3},
	&"a3": {"sector": "A", "budget": 3},
}

## Separación mínima entre enemigos de una misma sala, en tiles (que no haya "oleadas").
const MIN_GAP := 16
## Distancia mínima a una entrada/salida de la sala, en tiles (el jugador no aparece con un enemigo encima).
const MIN_FROM_SPAWN := 10
## Como mucho un volador por sala.
const MAX_FLYERS := 1


static func sector_of(room_id: StringName) -> String:
	return ROOMS.get(room_id, {}).get("sector", "")


## Revisa una sala. `kinds` y `xs` van en paralelo (tipo y columna de cada enemigo), `spawns` = columnas de entradas.
## Devuelve la lista de problemas (vacía = todo bien).
static func check(room_id: StringName, kinds: Array, xs: Array, spawns: Array = []) -> Array[String]:
	var out: Array[String] = []
	if not ROOMS.has(room_id):
		out.append("sala '%s' sin registrar en EnemyZones.ROOMS" % room_id)
		return out
	var room: Dictionary = ROOMS[room_id]
	var sector: Dictionary = SECTORS[room.sector]
	var points := 0
	var flyers := 0
	for k in kinds:
		points += 2 if k in TOUGH else 1
		if k == "Wasp":
			flyers += 1
		if k not in sector.kinds:
			out.append("%s no pertenece al sector %s (%s): permitidos %s" % [k, room.sector, sector.name, sector.kinds])
	if points > int(room.budget):
		out.append("amenaza %d > presupuesto %d (los duros cuentan doble)" % [points, room.budget])
	if flyers > MAX_FLYERS:
		out.append("%d voladores (máximo %d)" % [flyers, MAX_FLYERS])
	for i in xs.size():
		for j in range(i + 1, xs.size()):
			if absf(float(xs[i]) - float(xs[j])) < MIN_GAP:
				out.append("%s y %s a menos de %d tiles entre sí" % [kinds[i], kinds[j], MIN_GAP])
		for s in spawns:
			if absf(float(xs[i]) - float(s)) < MIN_FROM_SPAWN:
				out.append("%s a menos de %d tiles de una entrada" % [kinds[i], MIN_FROM_SPAWN])
	return out


## Revisa una sala ya instanciada (la usa World en builds de depuración).
static func check_room(room: Room) -> Array[String]:
	var kinds: Array = []
	var xs: Array = []
	var holder := room.get_node_or_null("Enemies")
	if holder:
		for e in holder.get_children():
			kinds.append(String(e.name).rstrip("0123456789"))
			xs.append(e.position.x / 16.0)
	var spawns: Array = []
	var sp := room.get_node_or_null("Spawns")
	if sp:
		for m in sp.get_children():
			spawns.append((m as Node2D).position.x / 16.0)
	return check(room.room_id, kinds, xs, spawns)
