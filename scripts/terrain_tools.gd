class_name TerrainTools
extends RefCounted
## Pinta terreno de bosque con el Terrain Set de `tiles/forest_tileset.tres` y corrige lo que el
## atlas no cubre: no tiene esquinas interiores, así que al pie de un escalón Godot coloca una
## esquina de borde junto a una pared y queda una grieta. `fix_step_feet` lo arregla.
## Uso: TerrainTools.paint(ground_layer, tips_layer, celdas_solidas)

const SRC := 0
const TERRAIN_SET := 0
const TERRAIN := 0
## Fila del atlas con el borde superior (pasto) y fila con las puntas de pasto (solo decoración).
const ROW_TOP := 2
const ROW_TIPS := 1
## El Terrain Set está en modo "Match Sides" (solo 4 lados): no necesita las correcciones de esquinas
## internas que hacían falta con "Corners and Sides". Ponlo en true solo si vuelves a ese modo.
const LEGACY_FIXES := false


## `slopes`: arreglo de Dictionary {x, y, len, dir} (ver `slope_cells`). Las diagonales cuentan como suelo
## para el Terrain y se reemplazan después por las piezas de 45° del atlas.
static func paint(ground: TileMapLayer, tips: TileMapLayer, cells: Array[Vector2i], slopes: Array = []) -> void:
	var diag: Dictionary = {}
	var all_cells: Array[Vector2i] = cells.duplicate()
	for s in slopes:
		for d in slope_cells(s.x, s.y, s.len, s.dir):
			diag[d] = true
			if not all_cells.has(d):
				all_cells.append(d)
	ground.set_cells_terrain_connect(all_cells, TERRAIN_SET, TERRAIN)
	if LEGACY_FIXES:
		fix_step_feet(ground, 7, diag)
	for d in diag:
		ground.set_cell(d, SRC, slope_tile(d, slopes))
	_fill_under_slopes(ground, slopes, diag)
	_place_rock_bands(ground, diag)
	_place_underside(ground, diag, slopes)
	_place_bridges(ground, slopes)
	shade(ground)
	rebuild_tips(ground, tips)


## El atlas no tiene esquinas interiores y el Terrain deja paredes/bordes sueltos dentro de la masa
## (junto a pendientes, escalones, fosos). Toda celda rodeada de suelo por los 4 lados pasa a relleno.
static func _fill_under_slopes(ground: TileMapLayer, _slopes: Array, diag: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for c in ground.get_used_cells():
		if diag.has(c) or ground.get_cell_source_id(c) != SRC:
			continue
		if is_solid(ground, c + Vector2i.UP) and is_solid(ground, c + Vector2i.DOWN) \
				and is_solid(ground, c + Vector2i.LEFT) and is_solid(ground, c + Vector2i.RIGHT):
			ground.set_cell(c, SRC, Vector2i(2 + rng.randi() % 2, 4 + rng.randi() % 2))


## Celdas diagonales de una pendiente de 45° (len par). (x,y) = primera celda diagonal; el suelo plano de arriba
## está en la fila y y el de abajo en la fila y+len. dir = 1: baja hacia la derecha. dir = -1: sube hacia la
## derecha (x es la celda de la izquierda, la más baja).
static func slope_cells(x: int, y: int, length: int, dir: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for i in length:
		if dir > 0:
			out.append(Vector2i(x + i, y + i))
		else:
			out.append(Vector2i(x + i, y + length - 1 - i))
	return out


## Cada tramo de 45° del atlas son 2x2 tiles: la diagonal usa 2 y una tercera pieza casi transparente (3 px de
## pasto) cierra el escalón entre ellas. Va en la celda de aire justo encima de la segunda diagonal del par.
## Por eso la longitud de la pendiente debe ser par.
## Bajo cada diagonal el atlas trae una pieza con la franja de roca que sigue la pendiente
## (8,3) bajo (8,2), (9,4) bajo (9,3), (11,3) bajo (11,2) y (10,4) bajo (10,3).
static func _place_rock_bands(ground: TileMapLayer, diag: Dictionary) -> void:
	var band := {Vector2i(8, 2): Vector2i(8, 3), Vector2i(9, 3): Vector2i(9, 4),
			Vector2i(11, 2): Vector2i(11, 3), Vector2i(10, 3): Vector2i(10, 4)}
	for d in diag:
		var below: Vector2i = d + Vector2i.DOWN
		if diag.has(below) or ground.get_cell_source_id(below) != SRC:
			continue
		var a := ground.get_cell_atlas_coords(d)
		if band.has(a):
			ground.set_cell(below, SRC, band[a])


## Acabado hecho a mano por el usuario en A1: bajo la franja de roca de cada diagonal (2 filas debajo de ella)
## va una pieza de roca que sigue la pendiente, para que la masa oscura no quede cortada recta:
## (8,4) bajo las bajadas y (11,4) bajo las subidas.
static func _place_underside(ground: TileMapLayer, diag: Dictionary, slopes: Array) -> void:
	for s in slopes:
		for d in slope_cells(s.x, s.y, s.len, s.dir):
			var c: Vector2i = d + Vector2i(0, 2)
			if diag.has(c) or ground.get_cell_source_id(c) != SRC:
				continue
			ground.set_cell(c, SRC, Vector2i(8, 4) if s.dir > 0 else Vector2i(11, 4))


static func _place_bridges(ground: TileMapLayer, slopes: Array) -> void:
	for s in slopes:
		var cells := slope_cells(s.x, s.y, s.len, s.dir)
		for i in cells.size():
			var c: Vector2i = cells[i]
			if s.dir > 0 and i % 2 == 1:
				ground.set_cell(c + Vector2i.UP, SRC, Vector2i(9, 2))
			elif s.dir < 0 and i % 2 == 0:
				ground.set_cell(c + Vector2i.UP, SRC, Vector2i(10, 2))


## Pieza del atlas para una celda diagonal (alterna dos variantes para que no se vea repetido).
static func slope_tile(c: Vector2i, slopes: Array) -> Vector2i:
	for s in slopes:
		if slope_cells(s.x, s.y, s.len, s.dir).has(c):
			var even: bool = (c.x - s.x) % 2 == 0
			if s.dir > 0:
				return Vector2i(8, 2) if even else Vector2i(9, 3)
			return Vector2i(10, 3) if even else Vector2i(11, 2)
	return Vector2i(8, 2)


static func is_solid(layer: TileMapLayer, c: Vector2i) -> bool:
	return layer.get_cell_source_id(c) != -1


static func is_surface(layer: TileMapLayer, c: Vector2i) -> bool:
	return is_solid(layer, c) and not is_solid(layer, c + Vector2i.UP)


## Pie de escalón: celda de suelo (superficie) con una masa más alta pegada al lado.
## El suelo pasa a borde plano y la masa alta recibe pared de roca a esa altura.
static func fix_step_feet(layer: TileMapLayer, seed_value: int = 7, skip: Dictionary = {}) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for c in layer.get_used_cells():
		if layer.get_cell_source_id(c) != SRC or not is_surface(layer, c) or skip.has(c):
			continue
		var right := c + Vector2i.RIGHT
		var left := c + Vector2i.LEFT
		if skip.has(left) or skip.has(left + Vector2i.UP) or skip.has(right) or skip.has(right + Vector2i.UP):
			continue
		if is_solid(layer, right) and is_solid(layer, right + Vector2i.UP):
			layer.set_cell(c, SRC, Vector2i(1 + rng.randi() % 4, ROW_TOP))
			layer.set_cell(right, SRC, Vector2i(0, 4 + rng.randi() % 2))
		if is_solid(layer, left) and is_solid(layer, left + Vector2i.UP):
			layer.set_cell(c, SRC, Vector2i(1 + rng.randi() % 4, ROW_TOP))
			layer.set_cell(left, SRC, Vector2i(5, 4 + rng.randi() % 2))


## Capa de pasto frontal: copia solo la franja de arriba (13 px) de los tiles planos de superficie y se dibuja
## DELANTE del jugador, así los pies quedan metidos en el pasto en lugar de verse encima.
const FRONT_SHADER := "shader_type canvas_item;
varying vec2 lp;
void vertex() { lp = VERTEX; }
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float px = UV.x / TEXTURE_PIXEL_SIZE.x;
	vec2 f = vec2(mod(lp.x + 0.001, 16.0), mod(lp.y + 0.001, 16.0));
	bool keep = f.y <= 13.0;
	if (px >= 128.0 && px < 160.0) {
		keep = f.y >= f.x - 4.0 && f.y <= f.x + 14.0;
	} else if (px >= 160.0 && px < 192.0) {
		keep = f.y >= (16.0 - f.x) - 4.0 && f.y <= (16.0 - f.x) + 14.0;
	}
	if (!keep) { c.a = 0.0; }
	COLOR = c;
}
"


static func make_front_material() -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = FRONT_SHADER
	var m := ShaderMaterial.new()
	m.shader = sh
	return m


## `layers`: capas con suelo (Ground, Platforms…). Copia las superficies planas (Main Grass fila 2, x<=5, y
## Small Grass fila 2) y las 4 piezas de pendiente; el shader recorta cada una según su forma.
static func build_front(front: TileMapLayer, layers: Array) -> void:
	front.clear()
	for l in layers:
		if l == null:
			continue
		for c in l.get_used_cells():
			var src: int = l.get_cell_source_id(c)
			var a: Vector2i = l.get_cell_atlas_coords(c)
			var is_slope := src == SRC and (a == Vector2i(8, 2) or a == Vector2i(9, 3) or a == Vector2i(10, 3) or a == Vector2i(11, 2))
			if is_slope:
				continue  # en pendientes no se dibuja pasto frontal
			if a.y != ROW_TOP or (src == SRC and a.x > 5) or (src != SRC and src != 1):
				continue
			if l.get_cell_source_id(c + Vector2i.UP) != -1 and l.get_cell_atlas_coords(c + Vector2i.UP).y == ROW_TOP \
					and l.get_cell_source_id(c + Vector2i.UP) == src:
				continue
			front.set_cell(c, src, a)


## Puntas de pasto: una por cada tile de borde superior, en la celda de arriba (sin colisión).
static func rebuild_tips(ground: TileMapLayer, tips: TileMapLayer) -> void:
	tips.clear()
	for c in ground.get_used_cells():
		if ground.get_cell_source_id(c) != SRC:
			continue
		var a := ground.get_cell_atlas_coords(c)
		if a.y == ROW_TOP and a.x <= 5:
			tips.set_cell(c + Vector2i.UP, SRC, Vector2i(a.x, ROW_TIPS))


## Relleno con sombra: el atlas trae un anillo interior (columnas 1 y 4, filas 3 y 6) con la sombra de los bordes.
## Terrain no puede distinguirlas del relleno normal, así que se colocan aquí según qué vecinos son "borde":
## una celda de relleno pegada a un borde arriba/abajo/izquierda/derecha usa la pieza con sombra de ese lado.
static func pillar_caps(ground: TileMapLayer) -> void:
	for c in ground.get_used_cells():
		if ground.get_cell_source_id(c) != 2:
			continue
		var a := ground.get_cell_atlas_coords(c)
		if a.y == 0 or a.y == 5:
			a = Vector2i(0, 2)
		var up := ground.get_cell_source_id(c + Vector2i.UP) == 2
		var dn := ground.get_cell_source_id(c + Vector2i.DOWN) == 2 or is_solid(ground, c + Vector2i.DOWN)
		var want := a
		if not up:
			want = Vector2i(0, 0)
		elif not dn:
			want = Vector2i(0, 5)
		if want != ground.get_cell_atlas_coords(c):
			ground.set_cell(c, 2, want)


static func shade(ground: TileMapLayer, _seed_value: int = 5) -> void:
	pillar_caps(ground)
	var cells := ground.get_used_cells()
	var plan: Dictionary = {}
	for c in cells:
		if ground.get_cell_source_id(c) != SRC or not _is_fill(ground, c):
			continue
		var t := _is_shell(ground, c + Vector2i.UP)
		var b := _is_shell(ground, c + Vector2i.DOWN)
		var l := _is_shell(ground, c + Vector2i.LEFT)
		var r := _is_shell(ground, c + Vector2i.RIGHT)
		var h := absi((c.x * 73856093) ^ (c.y * 19349663))
		var v := h % 2
		var tile := Vector2i(2 + v, 4 + (h / 2) % 2)
		if t and l and not b and not r:
			tile = Vector2i(1, 3)
		elif t and r and not b and not l:
			tile = Vector2i(4, 3)
		elif b and l and not t and not r:
			tile = Vector2i(1, 6)
		elif b and r and not t and not l:
			tile = Vector2i(4, 6)
		elif t and not (b or l or r):
			tile = Vector2i(2 + v, 3)
		elif b and not (t or l or r):
			tile = Vector2i(2 + v, 6)
		elif l and not (t or b or r):
			tile = Vector2i(1, 4 + v)
		elif r and not (t or b or l):
			tile = Vector2i(4, 4 + v)
		plan[c] = tile
	for c in plan:
		if ground.get_cell_atlas_coords(c) != plan[c]:
			ground.set_cell(c, SRC, plan[c])


## Relleno = celdas con los 4 lados sólidos y pieza del anillo interior (no pendientes ni bordes).
static func _is_fill(ground: TileMapLayer, c: Vector2i) -> bool:
	var a := ground.get_cell_atlas_coords(c)
	if a.x < 1 or a.x > 4 or a.y < 3 or a.y > 6:
		return false
	return is_solid(ground, c + Vector2i.UP) and is_solid(ground, c + Vector2i.DOWN) \
			and is_solid(ground, c + Vector2i.LEFT) and is_solid(ground, c + Vector2i.RIGHT)


## Borde (pieza del marco del atlas con algún lado al aire). Las pendientes no cuentan.
static func _is_shell(ground: TileMapLayer, c: Vector2i) -> bool:
	if not is_solid(ground, c):
		return false
	var a := ground.get_cell_atlas_coords(c)
	if a.x > 5:
		return false
	return not (is_solid(ground, c + Vector2i.UP) and is_solid(ground, c + Vector2i.DOWN) \
			and is_solid(ground, c + Vector2i.LEFT) and is_solid(ground, c + Vector2i.RIGHT))
