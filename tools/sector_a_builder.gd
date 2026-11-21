class_name SectorABuilder
extends RefCounted
## Genera rooms/a1.tscn, a2.tscn y a3.tscn (Sector A: Camino de entrada y Subida al Claro).
## Se corre a mano (por ejemplo con editor_manage game_eval): SectorABuilder.build_all(tree)
## OJO: sobrescribe las salas. Una vez generadas se pueden editar a mano en el editor.
##
## Cada sala se describe con: tamaño en tiles, fila base del suelo, tramos de terreno
## [x_inicio, x_fin, fila_superficie], spawns, salidas y dummies. El terreno se pinta con
## TerrainTools (Terrain Set del bosque) y la decoración se coloca sola SOLO sobre tramos
## planos donde cabe entera.

const TILE := 16
## TileSet por defecto (el del bosque). Cada spec puede traer su propio "tileset" para otros capítulos.
const TILESET := "res://tiles/forest_tileset.tres"
const DUMMY := "res://scenes/training_dummy.tscn"
## Tipos de enemigo para el spec "enemies": {"k": tipo, "x": tile, "row": fila de suelo opcional,
## "air": filas por encima del suelo (voladores)}.
const ENEMY_SCENES := {
	"Rat": "res://scenes/enemy_slime.tscn", "Wolf": "res://scenes/enemy_boar.tscn",
	"Wasp": "res://scenes/enemy_bat.tscn", "Satyr": "res://scenes/enemy_satyr.tscn",
	"Mandrake": "res://scenes/enemy_mandrake.tscn", "Gota": "res://scenes/enemy_water.tscn",
}
const DECOR_DIR := "res://art/Decorations/"
## Extensión del terreno fuera de la sala, para que no se caiga al cruzar la salida.
const OVERSCAN := 2
## Capas "detrás del suelo": z (bajo el suelo y los props de medio plano) y tinte para dar profundidad.
const BACK_Z := -3
const BACK_TINT := Color(0.7, 0.78, 0.82)

## [archivo, ancho, última fila opaca]
const SMALL := [["Small Plant", 32, 26], ["Red Flowers", 30, 28], ["Blue Flowers", 23, 31],
		["Orange Flowers", 23, 30], ["Flower Purple", 23, 31], ["smallBush", 32, 28],
		["Little Rock", 32, 25], ["Small Rock", 32, 31]]
const MEDIUM := [["bigBush", 51, 26], ["Tronco", 64, 24], ["Big Rock", 32, 54]]
const TALL := [["Pink Tall Flower", 32, 49], ["Blue Tall Flower", 33, 54],
		["Yellow Tall Fruit", 30, 56], ["Flower Tree", 39, 37]]


static func specs() -> Array:
	var F := func(n: int) -> Dictionary: return {"t": "flat", "n": n}
	var R := func(n: int) -> Dictionary: return {"t": "rise", "n": n}
	var D := func(n: int) -> Dictionary: return {"t": "drop", "n": n}
	var U := func(l: int) -> Dictionary: return {"t": "up", "len": l}
	var Dn := func(l: int) -> Dictionary: return {"t": "down", "len": l}
	# Filosofía: salas tranquilas y compuestas a mano. Poco terreno variado, pocas plataformas,
	# y la decoración (árboles en 3 capas, ruinas, faroles) cuenta el lugar.
	var DIM := Color(0.58, 0.68, 0.68)   # árboles lejanos
	var HAZE := Color(0.78, 0.86, 0.84)  # segundo plano
	var T := func(k: String, c: int, x: float, l: String, tint = null, flip := false) -> Dictionary:
		var d := {"tree": k, "c": c, "x": x, "l": l, "flip": flip}
		if tint != null:
			d["tint"] = tint
		return d
	var P := func(f: String, x: float, l := "m", flip := false) -> Dictionary:
		return {"f": f, "x": x, "l": l, "flip": flip}
	return [
		{
			# A1 · Claro de entrada: un sendero tranquilo bajo sauces, con un cartel, un cerco y una roca elemental al fondo.
			"id": &"a1", "title": "ROOM_A1", "cols": 80, "rows": 24, "base": 20,
			"segments": [], "decor": false, "bg": true,
			# Camino que sube a una loma, baja a una hondonada y vuelve a subir hasta la salida.
			"profile": [F.call(12), U.call(4), F.call(10), Dn.call(4), F.call(6), Dn.call(2), F.call(1), R.call(3), F.call(3), D.call(3), F.call(2), U.call(2),
					F.call(8), R.call(1), F.call(6), U.call(2), F.call(24)],
			# Una meseta de roca que nace del suelo de la hondonada (3 tiles de alto, se salta desde el piso) y,
			# encima, dos plataformas finas flotando en escalera (cada paso sube 2 tiles; el salto llega a ~3.5).
			"platforms": [[41, 17, 3, 1], [45, 15, 3, 1]],
			"pillars": [],
			"spawns": {"default": 4, "right": 76},
			"exits": [{"side": RoomExit.ExitSide.RIGHT, "room": &"a2", "spawn": &"left"}],
			"enemies": [{"k": "Rat", "x": 21}, {"k": "Rat", "x": 47}],
			"dummies": [],
			"fixed": [],
			"props": [
				# Entrada: cartel y cerco, un arbusto y flores.
				P.call("sign_text", 2.5), P.call("Fence", 6.5, "m"),
				# Árboles lejanos para dar profundidad (entre el fondo y el sendero).
				T.call("round_l", 0, 0, "b", DIM), T.call("pine_l", 0, 33, "b", DIM), T.call("round_l", 0, 56, "b", DIM),
				# La loma: un sauce protagonista con flores y un tronco caído al pie.
				T.call("willow_l", 0, 22, "m"), P.call("Red Flowers", 18.5, "f"), P.call("Tronco", 32.5, "m"),
				# Hondonada: flores y roca pequeña.
				P.call("Blue Flowers", 38, "f"), P.call("Orange Flowers", 48, "f"),
				P.call("Small Plant", 52, "f"),
				# Último tramo: un árbol redondo, la roca elemental y faroles hacia la salida.
				T.call("round_l", 1, 65, "m"), P.call("Horn Light", 53.5), P.call("Big Element Rock", 71, "m", true),
				P.call("Bigger Light", 76),
			],
		},
		{
			# A2 · Altar del bosque: un pequeño santuario de ruinas y reliquias en el centro, rodeado de coníferas rojas y moradas.
			"id": &"a2", "title": "ROOM_A2", "cols": 80, "rows": 24, "base": 20,
			"segments": [], "decor": false, "bg": true,
			# Se entra por abajo, se sube en dos pasos a la meseta del altar (fila 17), se baja a dos arenas
			# de combate (filas 19 y 21) y se sube de nuevo hasta la salida. Columnas = tramo + 2 (el perfil empieza en -2).
			"profile": [F.call(8), R.call(1), F.call(6), U.call(2), F.call(18), Dn.call(2), F.call(6), Dn.call(2), F.call(8),
					U.call(4), F.call(28)],
			"platforms": [[47, 17, 3, 1]],
			"pillars": [],
			# Detrás de la meseta del altar: un risco en dos escalones (se sube desde la meseta) y,
			# detrás de la arena baja, un saliente.
			"back": [
				{"x0": 16, "row0": 15, "segs": [F.call(5), R.call(2), F.call(7)], "bottom": 17},
				{"x0": 43, "row0": 19, "segs": [F.call(5)], "bottom": 21},
			],
			"platforms_back": [[29, 13, 3, 1]],
			"spawns": {"default": 4, "left": 3, "right": 76},
			"exits": [
				{"side": RoomExit.ExitSide.LEFT, "room": &"a1", "spawn": &"right"},
				{"side": RoomExit.ExitSide.RIGHT, "room": &"a3", "spawn": &"left"},
			],
			# Sector A es tranquilo: 3 encuentros. La mandrágora guarda el altar, una rata en la arena baja y otra en el tramo final.
			"enemies": [{"k": "Mandrake", "x": 26}, {"k": "Rat", "x": 44}, {"k": "Rat", "x": 62}],
			"dummies": [],
			"fixed": [],
			"props": [
				# Entrada: letrero, un sauce y flores.
				P.call("Tall Sign", 2.5), T.call("willow_l", 1, 8.5, "m"), P.call("Orange Flowers", 5),
				# Árboles lejanos entre el fondo y el sendero.
				T.call("pine_l", 0, 12, "b", DIM), T.call("round_l", 0, 38, "b", DIM), T.call("pine_l", 0, 58, "b", DIM),
				# La meseta del altar: faroles, reliquias y la roca elemental vacía en el centro.
				P.call("Horn Light", 18), P.call("Yellow Reliquia", 21), P.call("Big Element Rock Not Filled", 24),
				P.call("Blue Reliquia", 27), P.call("Horn Light", 30),
				# Bajada: tronco caído y flores.
				P.call("Tronco", 36.5, "m"), P.call("Red Flowers", 39, "f"),
				P.call("Small Rock", 43, "f"), P.call("Blue Flowers", 48, "f"),
				# Tramo final: conífera, roca y farol hacia la salida.
				T.call("pine_l", 2, 60, "m"), P.call("Big Rock", 66, "m", true), P.call("Small Plant", 70, "f"),
				P.call("Bigger Light", 77),
			],
		},
		{
			# A3 · La ladera: seis terrazas amplias que suben el bosque, cada una con su árbol; en la cima, un mirador.
			"id": &"a3", "title": "ROOM_A3", "cols": 64, "rows": 40, "base": 35,
			"segments": [], "decor": false, "bg": true,
			# La ladera: sube de la fila 35 a la 13 alternando pendientes de 45° y escalones de 2 tiles.
			# Columnas = tramo + 2 (el perfil empieza en -2).
			"profile": [F.call(8), U.call(4), F.call(6), R.call(2), F.call(4), U.call(4), F.call(6), R.call(2), F.call(5),
					U.call(4), F.call(6), R.call(2), F.call(5), U.call(4), F.call(12)],
			"platforms": [],
			"pillars": [],
			# Salientes detrás de cada terraza: ruta alterna que se sube saltando (2 tiles sobre el suelo).
			"back": [
				{"x0": 12, "row0": 29, "segs": [F.call(4)], "bottom": 31},
				{"x0": 26, "row0": 23, "segs": [F.call(4)], "bottom": 25},
				{"x0": 41, "row0": 17, "segs": [F.call(4)], "bottom": 19},
				{"x0": 55, "row0": 11, "segs": [F.call(7)], "bottom": 13},
			],
			"platforms_back": [[17, 27, 3, 1], [32, 21, 3, 1]],
			"spawns": {"default": 4, "left": 3, "right": 60},
			"exits": [{"side": RoomExit.ExitSide.LEFT, "room": &"a2", "spawn": &"right"}],
			# 3 encuentros repartidos en la subida: una rata abajo, una mandrágora emboscada en la terraza media y una rata cerca de la cima.
			"enemies": [{"k": "Rat", "x": 14}, {"k": "Mandrake", "x": 30}, {"k": "Rat", "x": 48}],
			"dummies": [],
			"fixed": [],
			"props": [
				# Pie de la ladera.
				P.call("sign_no_text", 2.5), T.call("willow_l", 2, 4.5, "m"), P.call("Blue Flowers", 7, "f"),
				# Árboles lejanos para dar profundidad.
				T.call("round_l", 0, 20, "b", DIM), T.call("pine_l", 0, 44, "b", DIM), T.call("round_l", 0, 8, "b", DIM),
				# Terrazas: cada una con su rincón.
				P.call("Tronco", 13, "m"), P.call("Orange Flowers", 16, "f"),
				T.call("round_l", 3, 27, "m"), P.call("Small Rock", 24.5, "f"),
				P.call("Pink Tall Flower", 43.5, "f"),
				T.call("pine_l", 2, 41, "m"), P.call("Small Plant", 46, "f"),
				T.call("round_l", 1, 49, "m"),
				# Cima: mirador con la roca elemental y los faroles.
				P.call("Small Element Rock", 57), P.call("Horn Light", 59), P.call("Bigger Light", 62),
			],
		},
	]


static func build_all(tree: SceneTree) -> Dictionary:
	var report := {}
	for spec in specs():
		report[String(spec.id)] = build_room(tree, spec)
	return report


static func surface_at(surf: Array, x: int) -> int:
	return surf[clampi(x, 0, surf.size() - 1)]


static func make_surface(cols: int, base: int, segments: Array) -> Array:
	var surf: Array = []
	surf.resize(cols)
	surf.fill(base)
	for seg in segments:
		for x in range(seg[0], seg[1] + 1):
			surf[x] = seg[2]
	return surf


static func build_room(tree: SceneTree, spec: Dictionary) -> Dictionary:
	var cols: int = spec.cols
	var rows: int = spec.rows
	var surf := make_surface(cols, spec.base, spec.segments)
	var prof := {}
	if spec.has("profile"):
		prof = TerrainShapes.profile(-OVERSCAN, spec.base, spec.profile, rows + 10)
		surf.fill(rows)
		for c in prof.cells:
			if c.x >= 0 and c.x < cols:
				surf[c.x] = mini(surf[c.x], c.y)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(String(spec.id))

	var root := Room.new()
	root.name = String(spec.id).to_upper()
	root.room_id = spec.id
	root.room_title = spec.title
	root.cols = cols
	root.rows = rows
	tree.root.add_child(root)

	var ts := load(spec.get("tileset", TILESET)) as TileSet
	var ground := TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = ts
	_add(root, ground, root)
	var tips := TileMapLayer.new()
	tips.name = "GrassTips"
	tips.tile_set = ts
	tips.z_index = 1
	_add(root, tips, root)
	var platforms := TileMapLayer.new()
	platforms.name = "Platforms"
	platforms.tile_set = ts
	platforms.z_index = 2  # delante del jugador: al saltar desde abajo queda oculto tras la isla
	_add(root, platforms, root)
	var front := TileMapLayer.new()
	front.name = "GrassFront"
	front.tile_set = ts
	front.z_index = 2
	front.material = TerrainTools.make_front_material()
	_add(root, front, root)

	# --- capas de terreno DETRÁS del suelo (se ven más lejos y oscuras, pero tienen colisión: se pueden subir) ---
	if spec.has("back") or spec.has("platforms_back"):
		var back := TileMapLayer.new()
		back.name = "GroundBack"
		back.tile_set = ts
		back.z_index = BACK_Z
		back.modulate = BACK_TINT
		_add(root, back, root)
		var back_tips := TileMapLayer.new()
		back_tips.name = "GrassTipsBack"
		back_tips.tile_set = ts
		back_tips.z_index = BACK_Z
		back_tips.modulate = BACK_TINT
		_add(root, back_tips, root)
		var back_cells: Array[Vector2i] = []
		var back_slopes: Array = []
		var back_tops := {}  # columna -> fila de la superficie del saliente
		for b in spec.get("back", []):
			var bp := TerrainShapes.profile(int(b.x0), int(b.row0), b.segs, int(b.bottom))
			back_cells.append_array(bp.cells)
			back_slopes.append_array(bp.slopes)
			for c in bp.cells:
				back_tops[c.x] = mini(back_tops.get(c.x, 9999), c.y)
		if not back_cells.is_empty():
			TerrainTools.paint(back, back_tips, back_cells, back_slopes)
		# Solo visual: si tuviera colisión sería una pared sólida donde los enemigos nacen y el jugador camina.
		back.collision_enabled = false
		# La parte superior de cada saliente sí se pisa, pero de una sola vía: se sube saltando desde abajo
		# y se pasa de largo por delante.
		var ledges := Node2D.new()
		ledges.name = "BackLedges"
		_add(root, ledges, root)
		var col_list: Array = back_tops.keys()
		col_list.sort()
		var ci := 0
		var li := 0
		while ci < col_list.size():
			var c0: int = col_list[ci]
			var row: int = back_tops[c0]
			var c1 := c0
			while ci + 1 < col_list.size() and col_list[ci + 1] == c1 + 1 and back_tops[col_list[ci + 1]] == row:
				ci += 1
				c1 = col_list[ci]
			var body := StaticBody2D.new()
			body.name = "Ledge%d" % li
			var cs := CollisionShape2D.new()
			var rect := RectangleShape2D.new()
			rect.size = Vector2((c1 - c0 + 1) * TILE, 6)
			cs.shape = rect
			cs.one_way_collision = true
			cs.position = Vector2((c0 + (c1 - c0 + 1) * 0.5) * TILE, row * TILE + 3)
			_add(ledges, body, root)
			_add(body, cs, root)
			li += 1
			ci += 1
		var pb: Array[Vector2i] = []
		for pl in spec.get("platforms_back", []):
			for px in range(pl[0], pl[0] + pl[2]):
				for py in range(pl[1], pl[1] + pl[3]):
					pb.append(Vector2i(px, py))
		if not pb.is_empty():
			var back_plat := TileMapLayer.new()
			back_plat.name = "PlatformsBack"
			back_plat.tile_set = ts
			back_plat.z_index = BACK_Z
			back_plat.modulate = BACK_TINT
			_add(root, back_plat, root)
			back_plat.set_cells_terrain_connect(pb, 0, 1, false)

	# --- terreno ---
	var cells: Array[Vector2i] = []
	var solid := {}
	for x in range(-OVERSCAN, cols + OVERSCAN):
		for y in range(surface_at(surf, x), rows):
			cells.append(Vector2i(x, y))
			solid[Vector2i(x, y)] = true
	if spec.has("profile"):
		cells = prof.cells
		for c in cells:
			solid[c] = true
		TerrainTools.paint(ground, tips, cells, prof.slopes)
		var extra: Array[Vector2i] = []
		for pl in spec.get("platforms", []):
			for px in range(pl[0], pl[0] + pl[2]):
				for py in range(pl[1], pl[1] + pl[3]):
					extra.append(Vector2i(px, py))
					solid[Vector2i(px, py)] = true
		if not extra.is_empty():
			platforms.set_cells_terrain_connect(extra, 0, 1, false)
		var pil: Array[Vector2i] = []
		for pi in spec.get("pillars", []):
			for py in range(pi[1], pi[2] + 1):
				pil.append(Vector2i(pi[0], py))
				solid[Vector2i(pi[0], py)] = true
		if not pil.is_empty():
			ground.set_cells_terrain_connect(pil, 0, 2, false)
			TerrainTools.shade(ground)
		TerrainTools.build_front(front, [ground, platforms])
	else:
		TerrainTools.paint(ground, tips, cells)

	# --- spawns y salidas ---
	var spawns := Node2D.new()
	spawns.name = "Spawns"
	_add(root, spawns, root)
	var avoid: Array = []
	for key in spec.spawns:
		var tx: int = spec.spawns[key]
		var m := Marker2D.new()
		m.name = String(key)
		m.position = Vector2(tx * TILE + 8, surface_at(surf, tx) * TILE + 5)
		_add(spawns, m, root)
		avoid.append(Vector2(m.position.x - 24, m.position.x + 24))
	var exits := Node2D.new()
	exits.name = "Exits"
	_add(root, exits, root)
	for e in spec.exits:
		var ex := RoomExit.new()
		ex.side = e.side
		ex.target_room = e.room
		ex.target_spawn = e.spawn
		ex.name = "Exit" + str(RoomExit.ExitSide.keys()[e.side]).capitalize()
		var shape := CollisionShape2D.new()
		shape.name = "Shape"
		var rect := RectangleShape2D.new()
		shape.shape = rect
		if e.side == RoomExit.ExitSide.LEFT or e.side == RoomExit.ExitSide.RIGHT:
			rect.size = Vector2(32, rows * TILE * 2)
			var px := -16.0 if e.side == RoomExit.ExitSide.LEFT else cols * TILE + 16.0
			ex.position = Vector2(px, rows * TILE * 0.5)
		else:
			rect.size = Vector2(cols * TILE * 2, 32)
			var py := -16.0 if e.side == RoomExit.ExitSide.UP else rows * TILE + 16.0
			ex.position = Vector2(cols * TILE * 0.5, py)
		_add(exits, ex, root)
		_add(ex, shape, root)

	# --- enemigos de práctica ---
	var dummy_scene := load(DUMMY) as PackedScene
	var di := 1
	for tx in spec.dummies:
		var d := dummy_scene.instantiate() as Node2D
		d.name = "Dummy%d" % di
		d.position = Vector2(tx * TILE + 8, surface_at(surf, tx) * TILE + 5)
		root.add_child(d)
		d.owner = root
		avoid.append(Vector2(d.position.x - 20, d.position.x + 20))
		di += 1

	# --- enemigos (en el nodo Enemies; nombres únicos por sala: los usa World para recordar los vencidos) ---
	var enemies_spec: Array = spec.get("enemies", [])
	# Ritmo del juego: tipos y cantidad permitidos por zona (scripts/enemy_zones.gd, docs/ENEMIGOS.md).
	var zone_kinds: Array = []
	var zone_xs: Array = []
	for e in enemies_spec:
		zone_kinds.append(e.k)
		zone_xs.append(e.x)
	var zone_spawns: Array = spec.spawns.values()
	var zone_problems := EnemyZones.check(spec.id, zone_kinds, zone_xs, zone_spawns)
	# Un enemigo bajo una plataforma trasera se ve "enterrado" dentro de ella.
	for e in enemies_spec:
		for pl in spec.get("platforms_back", []):
			if int(e.x) >= int(pl[0]) - 1 and int(e.x) <= int(pl[0]) + int(pl[2]) and \
					surface_at(surf, int(e.x)) - int(pl[1]) <= 5 and not e.has("air"):
				zone_problems.append("%s x=%d queda bajo una plataforma trasera" % [e.k, e.x])
	for p in zone_problems:
		push_warning("Sala %s: %s" % [spec.id, p])
	if not enemies_spec.is_empty():
		var holder := Node2D.new()
		holder.name = "Enemies"
		_add(root, holder, root)
		var counts := {}
		for e in enemies_spec:
			var inst := (load(ENEMY_SCENES[e.k]) as PackedScene).instantiate() as Node2D
			counts[e.k] = counts.get(e.k, 0) + 1
			inst.name = "%s%d" % [e.k, counts[e.k]]
			if e.has("range"):
				inst.set("patrol_radius", float(e.range) * TILE)  # zona de patrulla propia (en tiles)
			var srow: int = e.get("row", surface_at(surf, int(e.x)))
			inst.position = Vector2(int(e.x) * TILE + 8, (srow - int(e.get("air", 0))) * TILE - 2)
			_add(holder, inst, root)
			avoid.append(Vector2(inst.position.x - 20, inst.position.x + 20))

	# --- decoración ---
	var decor := Node2D.new()
	decor.name = "Decor"
	if spec.get("decor", true):
		_add(root, decor, root)
	var count := 0
	for f in spec.fixed:
		_add_sprite(decor, root, f[0], f[1], f[2], f[3], surface_at(surf, int(f[3]) / TILE), count)
		avoid.append(Vector2(f[3] - f[1] * 0.5 - 4, f[3] + f[1] * 0.5 + 4))
		count += 1
	if spec.get("decor", true):
		count += _decorate(decor, root, solid, surf, cols, rng, avoid, count)

	count += _build_props(root, spec, surf)
	if spec.get("bg", false):
		_build_background(root)

	var ps := PackedScene.new()
	var pack_err := ps.pack(root)
	var path := "res://rooms/%s.tscn" % spec.id
	var save_err := ResourceSaver.save(ps, path)
	var used := ground.get_used_cells().size()
	root.queue_free()
	return {"path": path, "pack_err": pack_err, "save_err": save_err, "tiles": used, "decor": count,
			"zone_problems": zone_problems}


## ¿Es plano el suelo bajo el rango [x0, x1] (px)? Misma altura en todas las columnas y sin tiles de pendiente.
static func _flat_under(ground: TileMapLayer, surf: Array, x0: float, x1: float) -> bool:
	var c0 := floori(x0 / TILE)
	var c1 := floori(x1 / TILE)
	var row: int = surface_at(surf, c0)
	for c in range(c0, c1 + 1):
		if c < 0 or c >= surf.size() or surf[c] != row:
			return false
		var atlas := ground.get_cell_atlas_coords(Vector2i(c, row))
		if atlas.x >= 8:
			return false
	return true


static func _overlaps(taken: Array, x0: float, x1: float) -> bool:
	for t in taken:
		if x1 > t[0] and x0 < t[1]:
			return true
	return false


const TREE_SHEET :="res://art/Decorations/Trees/Trees TileSet.png"
## [y, alto] de cada fila del atlas de árboles (4 columnas de 96 px = 4 colores).
const TREES := {"willow_s": [4, 93], "willow_l": [98, 126], "round_m": [224, 98],
		"round_l": [322, 128], "pine_s": [452, 94], "pine_l": [548, 124]}
const LAYER_Z := {"b": -4, "m": -1, "f": 3}


## Decoración autoral: cada prop {f|tree+c, x (tile), l (b/m/f), tint, flip, row, dy}.
## Se recorta a su rect opaco y se ancla por la base al suelo de su columna.
static func _build_props(root: Node, spec: Dictionary, surf: Array) -> int:
	var props: Array = spec.get("props", [])
	if props.is_empty():
		return 0
	var layers := {}
	for l in ["b", "m", "f"]:
		var n := Node2D.new()
		n.name = "Props_" + l
		n.z_index = LAYER_Z[l]
		_add(root, n, root)
		layers[l] = n
	var cache := {}
	var i := 0
	var ground := root.get_node_or_null("Ground") as TileMapLayer
	var taken: Array = []  # [x0, x1] en px de los props ya colocados (capas m y f)
	# Zonas bajo plataformas traseras (hasta 5 tiles por encima del suelo): ahí un prop de suelo se ve
	# "enterrado" dentro de la plataforma, así que se evita.
	var back_zones: Array = []
	for pl in spec.get("platforms_back", []):
		var gy: int = surface_at(surf, int(pl[0]) + int(pl[2]) / 2)
		if gy - int(pl[1]) <= 5:
			back_zones.append([pl[0] * TILE - 4.0, (pl[0] + pl[2]) * TILE + 4.0])
	for p in props:
		var path: String = TREE_SHEET if p.has("tree") else DECOR_DIR + String(p.f) + ".png"
		var tex := load(path) as Texture2D
		if not cache.has(path):
			var im := tex.get_image()
			if im.is_compressed():
				im.decompress()
			cache[path] = im
		var im: Image = cache[path]
		var region := Rect2i(0, 0, im.get_width(), im.get_height())
		if p.has("tree"):
			var t: Array = TREES[p.tree]
			region = Rect2i(int(p.get("c", 0)) * 96, t[0], 96, t[1])
		var used := im.get_region(region).get_used_rect()
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(region.position + used.position, used.size)
		var spr := Sprite2D.new()
		spr.name = "%s_%d" % [String(p.get("tree", p.get("f", "x"))).replace(" ", ""), i]
		spr.texture = at
		spr.centered = false
		spr.offset = Vector2(-used.size.x * 0.5, -used.size.y)
		spr.flip_h = p.get("flip", false)
		var px: float = float(p.x)
		if not p.has("row") and ground != null:
			# Árboles: solo importa que el tronco (centro) esté en plano; el resto: todo el ancho.
			var hw := minf(used.size.x * 0.5, 14.0) if p.has("tree") else used.size.x * 0.5
			var is_bg: bool = p.get("l", "m") == "b"
			var found := false
			for step in range(0, 13):  # como mucho 6 tiles de desplazamiento
				for dir in ([1, -1] if step > 0 else [1]):
					var cand: float = float(p.x) + dir * step * 0.5
					var cx: float = cand * TILE + 8.0
					if not _flat_under(ground, surf, cx - hw, cx + hw):
						continue
					if not is_bg and _overlaps(back_zones, cx - hw, cx + hw):
						continue
					if not is_bg and step > 0 and _overlaps(taken, cx - hw - 4.0, cx + hw + 4.0):
						continue
					if step > 0:
						print("Prop %s movido de x=%.1f a x=%.1f (suelo plano)" % [spr.name, px, cand])
					px = cand
					found = true
					break
				if found:
					break
			if not found:
				push_warning("Prop %s en x=%.1f: no hay suelo plano cerca." % [spr.name, px])
				if not is_bg and _overlaps(back_zones, px * TILE + 8.0 - hw, px * TILE + 8.0 + hw):
					push_warning("Prop %s omitido: quedaría bajo una plataforma trasera." % spr.name)
					spr.free()
					continue
			if not is_bg:
				taken.append([px * TILE + 8.0 - hw, px * TILE + 8.0 + hw])
		var row: int = p.get("row", surface_at(surf, int(px)))
		spr.position = Vector2(px * TILE + 8, row * TILE + 3 + float(p.get("dy", 0)))
		if p.has("tint"):
			spr.modulate = p.tint
		_add(layers[p.get("l", "m")], spr, root)
		i += 1
	return i


const BG_DIR := "res://art/Background/Forest/"


## Fondo en capas (parallax): nubes lejanas y dos filas de colinas boscosas (BG01), una más clara y lejana.
## Las capas van ancladas a la pantalla (motion_scale.y = 0) y se repiten en horizontal.
static func _build_background(root: Node) -> void:
	var bg := ParallaxBackground.new()
	bg.name = "Background"
	bg.layer = -5
	_add(root, bg, root)
	# [textura, motion_scale x, y en pantalla (parte alta de la imagen), tinte, ancho]
	var layers := [
		["BGClouds", 0.05, 62.0, Color(1, 1, 1, 0.75), 400],
		["BG01", 0.12, 100.0, Color(0.78, 0.9, 0.9, 0.9), 400],
		["BG01", 0.30, 175.0, Color(1, 1, 1, 1), 400],
	]
	var i := 0
	for l in layers:
		var pl := ParallaxLayer.new()
		pl.name = "Layer%d_%s" % [i, l[0]]
		pl.motion_scale = Vector2(l[1], 0.0)
		pl.motion_mirroring = Vector2(l[4], 0.0)
		_add(bg, pl, root)
		var spr := Sprite2D.new()
		spr.name = "Img"
		spr.texture = load(BG_DIR + l[0] + ".png")
		spr.centered = false
		spr.position = Vector2(0, l[2])
		spr.modulate = l[3]
		if l[0] == "BGClouds":
			# Las nubes tienen el borde inferior cortado en seco: se desvanecen hacia abajo.
			var sh := Shader.new()
			sh.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec4 c = texture(TEXTURE, UV);\n\tc.a *= smoothstep(1.0, 0.45, UV.y);\n\tCOLOR = c * COLOR;\n}\n"
			var mat := ShaderMaterial.new()
			mat.shader = sh
			spr.material = mat
		_add(pl, spr, root)
		if i == layers.size() - 1:
			# Relleno bajo las colinas cercanas (en salas altas la cámara ve más abajo que la imagen).
			var tex := spr.texture as Texture2D
			var img := tex.get_image()
			var fill := ColorRect.new()
			fill.name = "Fill"
			fill.color = img.get_pixel(tex.get_width() / 2, tex.get_height() - 1)
			fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
			fill.position = Vector2(0, l[2] + tex.get_height() - 1)
			fill.size = Vector2(l[4], 200)
			_add(pl, fill, root)
		i += 1


static func _add(parent: Node, child: Node, root: Node) -> void:
	parent.add_child(child)
	child.owner = root


static func _add_sprite(decor: Node2D, root: Node, file: String, w: int, yb: int, cx: float,
		surface_row: int, idx: int) -> void:
	var spr := Sprite2D.new()
	spr.name = "%s_%d" % [file.replace(" ", ""), idx]
	spr.texture = load(DECOR_DIR + file + ".png")
	spr.centered = false
	spr.offset = Vector2(-w * 0.5, -(yb + 1))
	# La base se hunde 4 px en el pasto, igual que los pies del jugador.
	spr.position = Vector2(cx, surface_row * TILE + 4)
	_add(decor, spr, root)


## Recorre los tramos planos (iguales en altura, 3+ tiles) y coloca decoración dentro de cada uno.
static func _decorate(decor: Node2D, root: Node, solid: Dictionary, surf: Array, cols: int,
		rng: RandomNumberGenerator, avoid: Array, start_idx: int) -> int:
	var placed := 0
	var x := 0
	while x < cols:
		var s: int = surf[x]
		var x1 := x
		while x1 + 1 < cols and surf[x1 + 1] == s:
			x1 += 1
		if x1 - x + 1 >= 3:
			placed += _decorate_run(decor, root, solid, s, x, x1, rng, avoid, start_idx + placed)
		x = x1 + 1
	return placed


static func _decorate_run(decor: Node2D, root: Node, solid: Dictionary, s: int, x0: int, x1: int,
		rng: RandomNumberGenerator, avoid: Array, idx: int) -> int:
	var placed := 0
	var cursor := x0 * TILE + 8.0 + rng.randi_range(0, 16)
	var run_end := (x1 + 1) * TILE - 8.0
	var tall_used := false
	var last_file := ""
	var guard := 0
	while cursor < run_end and guard < 40:
		guard += 1
		var roll := rng.randf()
		var pool: Array = SMALL
		if roll > 0.82 and not tall_used:
			pool = TALL
		elif roll > 0.55:
			pool = MEDIUM
		var item: Array = pool[rng.randi_range(0, pool.size() - 1)]
		for _try in 4:
			if item[0] != last_file:
				break
			item = pool[rng.randi_range(0, pool.size() - 1)]
		var w: int = item[1]
		if cursor + w > run_end:
			item = SMALL[rng.randi_range(0, SMALL.size() - 1)]
			w = item[1]
			if cursor + w > run_end:
				break
		var cx := cursor + w * 0.5
		var blocked_to := -1.0
		for r in avoid:
			if cx + w * 0.5 > r.x and cx - w * 0.5 < r.y:
				blocked_to = maxf(blocked_to, r.y)
		if blocked_to > 0.0:
			cursor = blocked_to + 4.0
			continue
		if not _has_headroom(solid, s, int(cx - w * 0.5), int(cx + w * 0.5), item[2] + 1):
			cursor += 12.0
			continue
		_add_sprite(decor, root, item[0], w, item[2], cx, s, idx + placed)
		placed += 1
		last_file = item[0]
		if pool == TALL:
			tall_used = true
		cursor += w + rng.randi_range(12, 56)
		if rng.randf() < 0.3:
			cursor += rng.randi_range(16, 48)
	return placed


## ¿Hay aire sobre el tramo, a la altura del sprite? (evita meter decoración dentro de repisas)
static func _has_headroom(solid: Dictionary, s: int, px0: int, px1: int, height_px: int) -> bool:
	var rows_up := ceili(height_px / float(TILE)) + 1
	for tx in range(floori(px0 / float(TILE)), floori(px1 / float(TILE)) + 1):
		for dy in range(1, rows_up + 1):
			if solid.has(Vector2i(tx, s - dy)):
				return false
	return true
