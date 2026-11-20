class_name TerrainShapes
extends RefCounted
## Generador de formas de terreno a partir de un perfil de segmentos, de izquierda a derecha.
## Segmentos (Dictionary):
##   {t="flat", n=6}          suelo plano de n tiles
##   {t="up", len=4}          pendiente de 45° que sube (len par: 2, 4, 6, 8…)
##   {t="down", len=4}        pendiente de 45° que baja (len par)
##   {t="rise", n=3}          acantilado vertical hacia arriba (n tiles de alto)
##   {t="drop", n=3}          acantilado vertical hacia abajo
##   {t="gap", n=4}           hueco (foso)
## `cy` = fila del suelo al inicio. `bottom` = última fila sólida.
## Devuelve {cells, slopes, end_x, end_y, min_y}. Se pinta con TerrainTools.paint(...).


static func profile(x0: int, cy0: int, segs: Array, bottom: int) -> Dictionary:
	var tops: Dictionary = {}
	var slopes: Array = []
	var x := x0
	var cy := cy0
	var min_y := cy0
	for s in segs:
		match s.t:
			"flat":
				for i in int(s.n):
					tops[x + i] = cy
				x += int(s.n)
			"down":
				var l := int(s.len)
				slopes.append({"x": x, "y": cy, "len": l, "dir": 1})
				for i in l:
					tops[x + i] = cy + i
				x += l
				cy += l
			"up":
				var l := int(s.len)
				slopes.append({"x": x, "y": cy - l, "len": l, "dir": -1})
				for i in l:
					tops[x + i] = cy - 1 - i
				x += l
				cy -= l
			"rise":
				cy -= int(s.n)
			"drop":
				cy += int(s.n)
			"gap":
				x += int(s.n)
		min_y = mini(min_y, cy)
	var cells: Array[Vector2i] = []
	for cx in tops:
		for y in range(int(tops[cx]), bottom + 1):
			cells.append(Vector2i(cx, y))
	return {"cells": cells, "slopes": slopes, "end_x": x, "end_y": cy, "min_y": min_y}


## Pinta un perfil en las capas dadas. Devuelve el perfil (para saber dónde terminó).
static func paint_profile(ground: TileMapLayer, tips: TileMapLayer, x0: int, cy0: int, segs: Array, bottom: int) -> Dictionary:
	var p := profile(x0, cy0, segs, bottom)
	TerrainTools.paint(ground, tips, p.cells, p.slopes)
	return p


## Galería con todas las formas, para ver y probar el terreno. Devuelve la lista de (nombre, x inicial, x final).
static func build_gallery(ground: TileMapLayer, tips: TileMapLayer) -> Array:
	ground.clear()
	tips.clear()
	var floor_y := 30
	var bottom := 44
	var F := func(n: int) -> Dictionary: return {"t": "flat", "n": n}
	var U := func(l: int) -> Dictionary: return {"t": "up", "len": l}
	var D := func(l: int) -> Dictionary: return {"t": "down", "len": l}
	var R := func(n: int) -> Dictionary: return {"t": "rise", "n": n}
	var Dr := func(n: int) -> Dictionary: return {"t": "drop", "n": n}
	var G := func(n: int) -> Dictionary: return {"t": "gap", "n": n}
	var shapes: Array = [
		["Plano", [F.call(10)]],
		["Escalera 1x1", [F.call(2), R.call(1), F.call(2), R.call(1), F.call(2), R.call(1), F.call(3), Dr.call(1), F.call(2), Dr.call(1), F.call(2), Dr.call(1), F.call(2)]],
		["Colina 4", [F.call(2), U.call(4), F.call(6), D.call(4), F.call(2)]],
		["Valle 4", [D.call(4), F.call(6), U.call(4), F.call(2)]],
		["Colina grande 8", [F.call(2), U.call(8), F.call(4), D.call(8), F.call(2)]],
		["Valle grande 8", [D.call(8), F.call(4), U.call(8), F.call(2)]],
		["Pendiente suave 2", [F.call(2), U.call(2), F.call(2), D.call(2), F.call(2)]],
		["Escalones con pendiente", [D.call(2), F.call(3), D.call(2), F.call(3), D.call(2), F.call(3), U.call(2), F.call(3), U.call(2), F.call(3), U.call(2), F.call(2)]],
		["Zigzag", [U.call(4), D.call(2), U.call(2), D.call(4), U.call(2), D.call(2), F.call(2)]],
		["Meseta (acantilados)", [F.call(2), R.call(4), F.call(8), Dr.call(4), F.call(2)]],
		["Torre", [F.call(2), R.call(7), F.call(2), Dr.call(7), F.call(2)]],
		["Escalón + pendiente", [F.call(2), R.call(2), F.call(3), D.call(4), F.call(3), U.call(2), F.call(2)]],
		["Foso", [F.call(4), G.call(5), F.call(4)]],
		["Foso doble con isla", [F.call(3), G.call(3), F.call(2), G.call(3), F.call(3)]],
		["Cañón", [F.call(2), R.call(5), F.call(3), Dr.call(5), G.call(3), R.call(5), F.call(3), Dr.call(5), F.call(2)]],
		["Rampa larga 12", [F.call(2), U.call(12), F.call(3), D.call(12), F.call(2)]],
		["Plano final", [F.call(8)]],
	]
	var x := 0
	var index: Array = []
	var cy := floor_y
	var all_cells: Array[Vector2i] = []
	var all_slopes: Array = []
	for sh in shapes:
		var start := x
		var segs: Array = sh[1]
		var p := profile(x, cy, segs, bottom)
		all_cells.append_array(p.cells)
		all_slopes.append_array(p.slopes)
		x = p.end_x
		cy = floor_y  # cada forma vuelve al nivel base (las formas son simétricas en altura)
		index.append([sh[0], start, x])
		# 2 tiles de separación plana entre formas para que se lean
		var sep := profile(x, floor_y, [{"t": "flat", "n": 2}], bottom)
		all_cells.append_array(sep.cells)
		x = sep.end_x
	# Islas flotantes sobre el recorrido
	var isl_y := floor_y - 19
	var ix := 6
	var islands: Array = [
		["Isla plana", [F.call(6)], 3],
		["Isla lente 2", [U.call(2), F.call(4), D.call(2)], 5],
		["Isla lente 4", [U.call(4), F.call(2), D.call(4)], 7],
		["Isla V", [D.call(2), F.call(3), U.call(2)], 6],
		["Isla V grande", [D.call(4), F.call(2), U.call(4)], 8],
		["Isla escalonada", [F.call(3), R.call(1), F.call(3), R.call(1), F.call(3)], 4],
	]
	var ic: Array[Vector2i] = []
	var isl: Array = []
	for it in islands:
		var q := profile(ix, isl_y, it[1], isl_y + int(it[2]))
		# el grosor se mide desde el punto más bajo del perfil
		ic.append_array(q.cells)
		isl.append_array(q.slopes)
		index.append([it[0], ix, q.end_x])
		ix = q.end_x + 10
	all_cells.append_array(ic)
	all_slopes.append_array(isl)
	TerrainTools.paint(ground, tips, all_cells, all_slopes)
	return index
