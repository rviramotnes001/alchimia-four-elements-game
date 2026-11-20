class_name RoomExit
extends Area2D
## Salida de sala: una franja pegada al borde. Al tocarla el jugador, World cambia de sala.
## `target_room` es el id registrado en World.ROOMS y `target_spawn` el Marker2D de esa sala.

enum ExitSide { LEFT, RIGHT, UP, DOWN }

@export var side: ExitSide = ExitSide.RIGHT
@export var target_room: StringName = &""
@export var target_spawn: StringName = &"default"


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var world := get_tree().get_first_node_in_group("world")
	if world and world.has_method("change_room"):
		world.change_room.call_deferred(target_room, target_spawn)
