class_name Room
extends Node2D
## Sala del mundo. Cada sala es una escena (rooms/*.tscn) con este script en la raíz y:
##   Ground (TileMapLayer), GrassTips (TileMapLayer), Decor (Node2D con sprites),
##   Spawns (Node2D con Marker2D: "default", "left", "right"...),
##   Exits (Node2D con RoomExit), más enemigos/objetos.
## El jugador y el HUD NO viven aquí: los pone el nodo World (scripts/world.gd).

const TILE := 16

@export var room_id: StringName = &""
## Clave de texto del nombre de la sala (se mostrará al entrar; aún sin sistema de textos).
@export var room_title: String = ""
@export var cols: int = 80
@export var rows: int = 24


func _ready() -> void:
	_build_walls()


func pixel_size() -> Vector2:
	return Vector2(cols, rows) * TILE


## Punto de entrada (pies del jugador). Cae a "default" si no existe el pedido.
func get_spawn(spawn_name: StringName) -> Vector2:
	var spawns := get_node_or_null("Spawns")
	if spawns:
		var marker := spawns.get_node_or_null(NodePath(String(spawn_name)))
		if marker == null:
			marker = spawns.get_node_or_null("default")
		if marker is Node2D:
			return (marker as Node2D).global_position
	push_warning("Room %s: sin spawn '%s'." % [room_id, spawn_name])
	return global_position + Vector2(32, 0)


func apply_camera_limits(cam: Camera2D) -> void:
	var size := pixel_size()
	cam.limit_left = int(global_position.x)
	cam.limit_top = int(global_position.y)
	cam.limit_right = int(global_position.x + size.x)
	cam.limit_bottom = int(global_position.y + size.y)


## Lados con salida (RoomExit.ExitSide) de esta sala.
func exit_sides() -> Array:
	var sides := []
	for e in find_children("*", "RoomExit", true, false):
		sides.append((e as RoomExit).side)
	return sides


## Muro invisible en cada lado izquierdo/derecho que NO tiene salida.
func _build_walls() -> void:
	var sides := exit_sides()
	var size := pixel_size()
	if not sides.has(RoomExit.ExitSide.LEFT):
		_add_wall(Vector2(-8.0, size.y * 0.5), Vector2(16.0, size.y * 3.0))
	if not sides.has(RoomExit.ExitSide.RIGHT):
		_add_wall(Vector2(size.x + 8.0, size.y * 0.5), Vector2(16.0, size.y * 3.0))


func _add_wall(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = "Wall"
	body.position = pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)
