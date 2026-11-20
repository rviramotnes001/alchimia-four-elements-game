@tool
class_name EnemySlime
extends Enemy
## Rata (el nombre de clase "Slime" se quedó del prototipo). Patrulla de un lado a
## otro y da la vuelta al chocar con una pared o al llegar al borde de una
## plataforma. No te persigue. Se puede PISAR: muere y te da un rebote.

const SHEET := "res://art/Enemies/Forest/Rat/rat-Sheet.png"
const CELL := Vector2i(42, 22)

@export var speed: float = 28.0


func _setup() -> void:
	max_health = 2
	body_size = Vector2(16, 11)
	stompable = true
	drop_chance = 0.55
	drop_weight_coin = 8.0
	drop_weight_food = 1.0
	drop_weight_essence = 1.0
	sprite_faces = -1
	facing = -1 if randf() < 0.5 else 1


func _make_frames() -> SpriteFrames:
	var sf := Enemy.new_frames()
	var tex: Texture2D = load(SHEET)
	# Hoja 4 columnas x 7 filas: fila 0 = quieta, fila 1 = correr (cuerpo que se estira y encoge).
	Enemy.add_sheet_anim(sf, "idle", tex, CELL,
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)], 5.0)
	Enemy.add_sheet_anim(sf, "walk", tex, CELL,
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], 9.0)
	Enemy.add_sheet_anim(sf, "hurt", tex, CELL, [Vector2i(0, 3), Vector2i(1, 3)], 8.0, false)
	Enemy.add_sheet_anim(sf, "die", tex, CELL,
		[Vector2i(2, 3), Vector2i(0, 5), Vector2i(1, 5), Vector2i(1, 5)], 7.0, false)
	return sf


func _sprite_anchor() -> Vector2:
	return Vector2(19, 19)  # centro del cuerpo y planta de las patas


func _think(delta: float) -> void:
	if patrol_paused(delta):
		velocity.x = 0.0
		return
	if is_on_floor() and (is_on_wall() or not ground_ahead()):
		facing = -facing
	velocity.x = facing * speed


func _pick_anim() -> String:
	return "walk" if absf(velocity.x) > 1.0 else "idle"
