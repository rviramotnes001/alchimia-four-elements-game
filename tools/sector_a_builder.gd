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
			"id": &"a1", "title": "ROOM_A1", "cols": 80, "rows": 24, "base": 19,
			"segments": [], "decor": false,
			"profile": [F.call(18), R.call(1), F.call(14), R.call(1), F.call(10), D.call(1), F.call(8), D.call(1), F.call(28)],
			"platforms": [],
			"pillars": [],
			"spawns": {"default": 4, "right": 76},
			"exits": [{"side": RoomExit.ExitSide.RIGHT, "room": &"a2", "spawn": &"left"}],
			"enemies": [{"k": "Rat", "x": 22}, {"k": "Gota", "x": 47}, {"k": "Rat", "x": 66}],
			"dummies": [],
			"fixed": [],
			"props": [
				P.call("sign_text", 6), P.call("Fence", 9.5),
				T.call("willow_l", 2, 26, "m"), P.call("Red Flowers", 23.5), P.call("Small Plant", 29),
				T.call("round_l", 0, 48, "m"), P.call("Tronco", 43.5),
				P.call("Horn Light", 62), P.call("Big Element Rock", 66, "m", true), P.call("Bigger Light", 74),
			],
		},
		{
			# A2 · Altar del bosque: un pequeño santuario de ruinas y reliquias en el centro, rodeado de coníferas rojas y moradas.
			"id": &"a2", "title": "ROOM_A2", "cols": 80, "rows": 24, "base": 19,
			"segments": [], "decor": false,
			"profile": [F.call(16), R.call(1), F.call(12), D.call(1), F.call(10), R.call(1), F.call(6), R.call(1), F.call(10), D.call(1), F.call(8), D.call(1), F.call(22)],
			"platforms": [],
			"pillars": [],
			"spawns": {"default": 4, "left": 3, "right": 76},
			"exits": [
				{"side": RoomExit.ExitSide.LEFT, "room": &"a1", "spawn": &"right"},
				{"side": RoomExit.ExitSide.RIGHT, "room": &"a3", "spawn": &"left"},
			],
			"enemies": [{"k": "Satyr", "x": 24}, {"k": "Mandrake", "x": 34}, {"k": "Wasp", "x": 42, "air": 6}, {"k": "Wolf", "x": 66}],
			"dummies": [],
			"fixed": [],
			"props": [
				P.call("Tall Sign", 5),
				T.call("willow_l", 1, 17, "m"), P.call("Orange Flowers", 14),
				P.call("Horn Light", 36), P.call("Yellow Reliquia", 38), P.call("Big Element Rock Not Filled", 42),
				P.call("Blue Reliquia", 46), P.call("Horn Light", 48),
				T.call("pine_l", 2, 60, "m"), P.call("Big Rock", 64, "m", true), P.call("Bigger Light", 74),
			],
		},
		{
			# A3 · La ladera: seis terrazas amplias que suben el bosque, cada una con su árbol; en la cima, un mirador.
			"id": &"a3", "title": "ROOM_A3", "cols": 64, "rows": 40, "base": 35,
			"segments": [], "decor": false,
			"profile": [F.call(14), R.call(3), F.call(8), R.call(3), F.call(8), R.call(3), F.call(8), R.call(3), F.call(8), R.call(3), F.call(8), R.call(3), F.call(10)],
			"platforms": [],
			"pillars": [],
			"spawns": {"default": 4, "left": 3, "right": 60},
			"exits": [{"side": RoomExit.ExitSide.LEFT, "room": &"a2", "spawn": &"right"}],
			"enemies": [{"k": "Satyr", "x": 20}, {"k": "Mandrake", "x": 31}, {"k": "Wasp", "x": 42, "air": 5}, {"k": "Wolf", "x": 58}],
			"dummies": [],
			"fixed": [],
			"props": [
				P.call("sign_no_text", 5), T.call("willow_l", 2, 9, "m"),
				T.call("round_l", 3, 31, "m"), P.call("Tronco", 27.5),
				T.call("round_l", 1, 50, "m"),
				P.call("Small Element Rock", 57), P.call("Horn Light", 59), P.call("Bigger Light", 61),
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

	var ts := load(TILESET) as TileSet
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
	if not enemies_spec.is_empty():
		var holder := Node2D.new()
		holder.name = "Enemies"
		_add(root, holder, root)
		var counts := {}
		for e in enemies_spec:
			var inst := (load(ENEMY_SCENES[e.k]) as PackedScene).instantiate() as Node2D
			counts[e.k] = counts.get(e.k, 0) + 1
			inst.name = "%s%d" % [e.k, counts[e.k]]
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

	var ps := PackedScene.new()
	var pack_err := ps.pack(root)
	var path := "res://rooms/%s.tscn" % spec.id
	var save_err := ResourceSaver.save(ps, path)
	var used := ground.get_used_cells().size()
	root.queue_free()
	return {"path": path, "pack_err": pack_err, "save_err": save_err, "tiles": used, "decor": count}


const TREE_SHEET := "res://art/Decorations/Trees/Trees TileSet.png"
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
		var row: int = p.get("row", surface_at(surf, int(p.x)))
		spr.position = Vector2(float(p.x) * TILE + 8, row * TILE + 3 + float(p.get("dy", 0)))
		if p.has("tint"):
			spr.modulate = p.tint
		_add(layers[p.get("l", "m")], spr, root)
		i += 1
	return i


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
