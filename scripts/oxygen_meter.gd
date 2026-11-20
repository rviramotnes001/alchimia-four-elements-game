class_name OxygenMeter
extends Node2D
## Burbujas de aire sobre la cabeza del jugador. Solo se ven cuando falta aire.

@export var bubbles: int = 6

var ratio: float = 1.0


func _ready() -> void:
	visible = false


func set_ratio(value: float) -> void:
	ratio = clampf(value, 0.0, 1.0)
	visible = ratio < 0.999
	queue_redraw()


func _draw() -> void:
	var filled := int(ceil(ratio * bubbles))
	var total_w := bubbles * 5 - 1
	for i in bubbles:
		var x := -total_w / 2 + i * 5
		var color := Color("bff4ff") if i < filled else Color(0.1, 0.1, 0.2, 0.6)
		draw_rect(Rect2(x, 0, 4, 4), Color("1b1b24"))
		draw_rect(Rect2(x + 1, 1, 2, 2), color)
