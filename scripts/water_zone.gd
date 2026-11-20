@tool
class_name WaterZone
extends Area2D
## Zona de agua (lago, río, sala sumergida). Se dimensiona con el CollisionShape2D (rectángulo).
## El jugador nada dentro; sin Respiración acuática se le acaba el aire bajo la superficie.

@export var color: Color = Color(0.24, 0.55, 0.85, 0.35)
@export var surface_color: Color = Color(0.7, 0.95, 1.0, 0.8)

@onready var _shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	z_index = 10
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.has_method("enter_water"):
		body.enter_water(self)


func _on_body_exited(body: Node) -> void:
	if body.has_method("exit_water"):
		body.exit_water(self)


func _rect() -> Rect2:
	var shape := _shape.shape as RectangleShape2D if _shape else null
	if shape == null:
		return Rect2()
	return Rect2(_shape.position - shape.size / 2.0, shape.size)


## Y global de la superficie del agua.
func surface_y() -> float:
	return global_position.y + _rect().position.y


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()


func _draw() -> void:
	var r := _rect()
	if r.size == Vector2.ZERO:
		return
	draw_rect(r, color)
	draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), surface_color)
