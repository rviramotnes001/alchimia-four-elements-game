class_name Hazard
extends Area2D
## Peligro fijo (pinchos, etc.). Daña al jugador mientras lo toque.
## El jugador tiene invulnerabilidad tras cada golpe, así que no recibe daño en cadena.

## Daño en MEDIOS corazones: 1 = medio corazón (fácil), 2 = un corazón (difícil).
@export var damage: int = 1


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("take_hit"):
			body.take_hit(global_position.x, damage)
