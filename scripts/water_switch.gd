class_name WaterSwitch
extends Node2D
## Interruptor lejano: se activa con agua (chorro o flecha de agua). Abre/cierra compuertas.

signal toggled(active: bool)

@export var active: bool = false
## Si es true, una vez activado ya no se apaga.
@export var one_shot: bool = false
## Cosas con set_open(bool), p. ej. una compuerta (scenes/gate.tscn).
@export var targets: Array[NodePath] = []

@onready var lamp: Polygon2D = $Lamp


func _ready() -> void:
	_apply(false)


func on_element_hit(element: int, _source: Node) -> void:
	if element != Elements.Type.WATER:
		return
	if active and one_shot:
		return
	active = not active
	_apply(true)
	toggled.emit(active)


func _apply(notify: bool) -> void:
	lamp.color = Color("3ed6c8") if active else Color("3a3a48")
	if notify:
		for path in targets:
			var target := get_node_or_null(path)
			if target and target.has_method("set_open"):
				target.set_open(active)
