@tool
class_name ForestGround
extends TileMapLayer
## Capa de suelo de bosque con acabado automático EN EL EDITOR.
## Pinta con el pincel de Terrenos (modo Connect) y, un instante después de cada trazo, esta capa coloca sola:
##   - el relleno con sombra pegado a los bordes (piezas de las columnas 1 y 4 / filas 3 y 6),
##   - las puntas de pasto en la capa hermana "GrassTips" (si existe).
## Uso: añade un nodo TileMapLayer, ponle el TileSet forest_tileset y adjunta este script (o usa el nodo
## "ForestGround" desde el diálogo de añadir nodo). En el juego no hace nada: el resultado ya está guardado.

@export var auto_finish := true
@export var tips_layer_name := "GrassTips"

const CHECK_EVERY := 0.25

var _timer := 0.0
var _last_sig := 0
var _busy := false


func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
		_last_sig = _signature()


func _process(delta: float) -> void:
	if not Engine.is_editor_hint() or not auto_finish or _busy:
		return
	_timer += delta
	if _timer < CHECK_EVERY:
		return
	_timer = 0.0
	var sig := _signature()
	if sig != _last_sig:
		_finish()


## Firma barata del contenido de la capa para detectar cambios (celdas y piezas).
func _signature() -> int:
	var h := 17
	for c in get_used_cells():
		var a := get_cell_atlas_coords(c)
		h = (h * 31 + c.x * 73856093 + c.y * 19349663 + a.x * 83492791 + a.y * 2654435761) & 0x7fffffffffff
	return h


func _finish() -> void:
	_busy = true
	TerrainTools.shade(self)
	var tips := get_parent().get_node_or_null(tips_layer_name) as TileMapLayer
	if tips != null:
		TerrainTools.rebuild_tips(self, tips)
	var front := get_parent().get_node_or_null("GrassFront") as TileMapLayer
	if front != null:
		TerrainTools.build_front(front, [self, get_parent().get_node_or_null("Platforms")])
	_last_sig = _signature()
	_busy = false
