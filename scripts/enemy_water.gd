@tool
class_name EnemyWater
extends Enemy
## Gota de agua (elemento menor). Pequeña y frágil: patrulla despacio y, si te ve al
## frente a unos 150 px, se prepara y dispara una gota de agua en línea recta
## (la puedes saltar o esquivar). Cuerpo a cuerpo es inofensiva salvo el contacto.
## Se puede PISAR.

const SHEET := "res://art/Enemies/Forest/Mini Element/Water_Enemy.png"
const CELL := Vector2i(64, 64)

enum State { PATROL, AIM, RECOVER }

@export var patrol_speed: float = 16.0
@export var sight_range: float = 150.0
@export var shot_damage: int = 1
@export var shot_speed: float = 120.0
@export var shoot_cooldown: float = 1.6
## Cuadro de "attack" en el que sale la gota (0-2 = preparación).
@export var shoot_frame: int = 3

var state: State = State.PATROL
var _cd := 0.0
var _shot_fired := false


func _setup() -> void:
	max_health = 2
	body_size = Vector2(10, 14)
	stompable = true
	drop_chance = 0.6
	drop_weight_coin = 3.0
	drop_weight_food = 1.0
	drop_weight_essence = 6.0
	contact_damage = 1
	sprite_faces = 1  # este dibujo mira a la derecha (el chorro sale a la derecha)
	facing = -1 if randf() < 0.5 else 1


func _make_frames() -> SpriteFrames:
	var sf := Enemy.new_frames()
	var tex: Texture2D = load(SHEET)
	var row := func(r: int, n: int) -> Array:
		var a := []
		for c in n:
			a.append(Vector2i(c, r))
		return a
	Enemy.add_sheet_anim(sf, "idle", tex, CELL, row.call(1, 6), 8.0)
	Enemy.add_sheet_anim(sf, "walk", tex, CELL, row.call(0, 8), 9.0)
	Enemy.add_sheet_anim(sf, "attack", tex, CELL, row.call(2, 10), 11.0, false)
	Enemy.add_sheet_anim(sf, "hurt", tex, CELL, row.call(3, 6), 12.0, false)
	Enemy.add_sheet_anim(sf, "die", tex, CELL, row.call(4, 8), 10.0, false)
	return sf


func _sprite_anchor() -> Vector2:
	return Vector2(31, 64)


func _think(delta: float) -> void:
	_cd = maxf(_cd - delta, 0.0)
	match state:
		State.PATROL:
			if patrol_paused(delta):
				velocity.x = 0.0
			else:
				if is_on_floor() and (is_on_wall() or not ground_ahead(6.0)):
					facing = -facing
				velocity.x = facing * patrol_speed
			if _cd <= 0.0 and _sees_player():
				state = State.AIM
				velocity.x = 0.0
				_shot_fired = false
				_sprite.play("attack")
		State.AIM:
			velocity.x = 0.0
			if not _shot_fired and _sprite.frame >= shoot_frame:
				_shot_fired = true
				var pos := global_position + Vector2(facing * (body_size.x / 2.0 + 6.0), -body_size.y * 0.5)
				EnemyShot.spawn(get_parent(), pos, facing, shot_damage, shot_speed)
			if not _sprite.is_playing():
				state = State.RECOVER
				_cd = shoot_cooldown
		State.RECOVER:
			velocity.x = 0.0
			if _cd <= shoot_cooldown - 0.5:
				state = State.PATROL


func _sees_player() -> bool:
	if player == null:
		return false
	var dx := dx_to_player()
	return absf(dx) < sight_range and absf(dy_to_player()) < 24.0 and signf(dx) == float(facing)


func _pick_anim() -> String:
	match state:
		State.PATROL:
			return "walk" if absf(velocity.x) > 1.0 else "idle"
		State.AIM:
			return "attack"
	return "idle"


func _on_hurt() -> void:
	if state == State.AIM:
		state = State.RECOVER
		_cd = shoot_cooldown * 0.5
