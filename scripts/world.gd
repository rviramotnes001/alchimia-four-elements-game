class_name World
extends Node2D
## Mundo: contiene la sala actual, al jugador y al HUD (que persisten entre salas).
## Cambia de sala con un fundido: borra la sala vieja, instancia la nueva y coloca al jugador
## en el spawn pedido, con los límites de cámara de la nueva sala.
## Para añadir una sala: crea rooms/<id>.tscn y regístrala en ROOMS.

signal room_changed(room: Room)

const ROOMS := {
	&"a1": "res://rooms/a1.tscn",
	&"a2": "res://rooms/a2.tscn",
	&"a3": "res://rooms/a3.tscn",
}
const FADE_TIME := 0.18

@export var start_room: StringName = &"a1"
@export var start_spawn: StringName = &"default"

var current_room: Room
## Salas ya visitadas (para el mapa que se revela, más adelante).
var visited: Dictionary = {}
## Enemigos vencidos por sala (id de sala -> nombres de nodo): no reaparecen al volver (vida única).
var defeated: Dictionary = {}
var _changing := false

@onready var holder: Node2D = $RoomHolder
@onready var player: Player = $Player
@onready var fade: ColorRect = $Fade/Rect


func _ready() -> void:
	add_to_group("world")
	fade.modulate.a = 1.0
	_enter_room(start_room, start_spawn)
	await get_tree().physics_frame
	await _fade_to(0.0)


## Cambia de sala (lo llama RoomExit). Ignora ids sin registrar.
func change_room(room_id: StringName, spawn_name: StringName) -> void:
	if _changing:
		return
	if not ROOMS.has(room_id):
		push_warning("World: la sala '%s' no está registrada." % room_id)
		return
	_changing = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	await _fade_to(1.0)
	_enter_room(room_id, spawn_name)
	await get_tree().physics_frame
	player.process_mode = Node.PROCESS_MODE_INHERIT
	await _fade_to(0.0)
	_changing = false


func _enter_room(room_id: StringName, spawn_name: StringName) -> void:
	if current_room:
		holder.remove_child(current_room)
		current_room.queue_free()
	_clear_projectiles()
	var scene := load(ROOMS[room_id]) as PackedScene
	current_room = scene.instantiate() as Room
	holder.add_child(current_room)
	var pos := current_room.get_spawn(spawn_name)
	player.global_position = pos
	player.velocity = Vector2.ZERO
	# Si muere, reaparece a la entrada de esta sala (hasta que existan los checkpoints).
	player._spawn_position = pos
	var cam := player.get_node("Camera2D") as Camera2D
	current_room.apply_camera_limits(cam)
	cam.reset_smoothing()
	visited[room_id] = true
	_track_enemies(room_id)
	room_changed.emit(current_room)


## Quita los enemigos ya vencidos de esta sala y anota los que mueran de ahora en adelante.
func _track_enemies(room_id: StringName) -> void:
	var enemies := current_room.get_node_or_null("Enemies")
	if enemies == null:
		return
	var gone: Array = defeated.get(room_id, [])
	for e in enemies.get_children():
		if e.name in gone:
			e.queue_free()
		elif e.has_signal("died"):
			e.died.connect(_on_enemy_died.bind(room_id, e.name))


func _on_enemy_died(room_id: StringName, enemy_name: StringName) -> void:
	if not defeated.has(room_id):
		defeated[room_id] = []
	if enemy_name not in defeated[room_id]:
		defeated[room_id].append(enemy_name)


func _clear_projectiles() -> void:
	for child in get_children():
		var script := child.get_script() as Script
		if script and script.resource_path in ["res://scripts/arrow.gd", "res://scripts/water_jet.gd"]:
			child.queue_free()


func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", alpha, FADE_TIME)
	await tween.finished
