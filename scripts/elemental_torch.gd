class_name ElementalTorch
extends Node2D
## Antorcha: el agua la apaga y el fuego la enciende. Puede abrir/cerrar compuertas.

signal extinguished
signal lit_again

@export var lit: bool = true
## Compuertas o cosas con set_open(bool). Se abren cuando la antorcha se apaga.
@export var targets: Array[NodePath] = []

@onready var flame: Node2D = $Flame


func _ready() -> void:
	_apply(false)


func on_element_hit(element: int, _source: Node) -> void:
	if element == Elements.Type.WATER and lit:
		lit = false
		_apply(true)
		extinguished.emit()
	elif element == Elements.Type.FIRE and not lit:
		lit = true
		_apply(true)
		lit_again.emit()


func _apply(notify: bool) -> void:
	flame.visible = lit
	if notify:
		for path in targets:
			var target := get_node_or_null(path)
			if target and target.has_method("set_open"):
				target.set_open(not lit)
