class_name IrrigationPoint
extends Node2D
## Punto de riego: una semilla en el suelo. Con Riego (E, gasta energía) o con el Chorro de agua
## brota una enredadera con una plataforma vegetal (de las que se atraviesa desde abajo).

signal grown

## Altura de la plataforma sobre el suelo (el salto de Erek llega a ~57 px).
@export var grow_height: float = 44.0
@export var grow_time: float = 0.9
@export var is_grown: bool = false

var _player: Player = null
var _bumped := false

@onready var prompt: Label = $Prompt
@onready var stem: Polygon2D = $Vine/Stem
@onready var platform: StaticBody2D = $Vine/Platform
@onready var platform_shape: CollisionShape2D = $Vine/Platform/CollisionShape2D
@onready var interact_area: Area2D = $InteractArea


func _ready() -> void:
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	platform_shape.disabled = true
	if is_grown:
		_set_grown_state()
	else:
		stem.scale.y = 0.0
		platform.position.y = 0.0
		platform.visible = false
	prompt.visible = false


func _process(_delta: float) -> void:
	prompt.visible = _player != null and not is_grown and _player.elemental.irrigation_active()


## Lo llama el jugador al pulsar E dentro del área.
func interact(player: Player) -> void:
	if is_grown or not player.elemental.irrigation_active():
		return
	if not player.elemental.spend_energy(player.elemental.irrigation_cost):
		player.elemental.power_failed.emit()
		return
	grow()


## El agua (chorro, flecha de agua) también la hace crecer.
func on_element_hit(element: int, _source: Node) -> void:
	if element == Elements.Type.WATER:
		grow()


func grow() -> void:
	if is_grown:
		return
	is_grown = true
	platform.visible = true
	var tween := create_tween().set_parallel(true)
	tween.tween_property(stem, "scale:y", grow_height, grow_time).set_trans(Tween.TRANS_SINE)
	tween.tween_property(platform, "position:y", -grow_height, grow_time).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(func():
		platform_shape.set_deferred("disabled", false)
		grown.emit())


func _set_grown_state() -> void:
	stem.scale.y = grow_height
	platform.position.y = -grow_height
	platform.visible = true
	platform_shape.disabled = false


func _on_body_entered(body: Node) -> void:
	if body is Player:
		_player = body
		body.interactable = self


func _on_body_exited(body: Node) -> void:
	if body is Player:
		if body.interactable == self:
			body.interactable = null
		_player = null
