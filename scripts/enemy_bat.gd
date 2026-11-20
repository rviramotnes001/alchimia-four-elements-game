@tool
class_name EnemyBat
extends Enemy
## Avispa (el nombre de clase "Bat" se quedó del prototipo). Vuela (sin gravedad).
## Flota sobre su punto de origen; si te acercas se lanza hacia ti en picada y
## luego vuelve a su sitio. Se puede PISAR en pleno vuelo (rebote). Con la espada
## cuando pase cerca, o derríbala con el arco antes de que llegue.

const DIR := "res://art/Enemies/Forest/Wasp"

enum State { HOVER, SWOOP, PAUSE, RETURN }

@export var detect_range: float = 110.0
@export var swoop_speed: float = 120.0
@export var return_speed: float = 60.0
@export var cooldown: float = 1.4
## Se queda quieta (idle) tras la picada: ventana para que la golpees.
@export var recover_time: float = 1.0
## Patrulla: recorre +-patrol_range px alrededor de su origen mientras no te ve.
@export var patrol_range: float = 45.0
@export var patrol_speed: float = 32.0

var state: State = State.HOVER
var _home := Vector2.ZERO
var _cool := 0.0
var _target := Vector2.ZERO
var _swoop_t := 0.0
var _pdir := 1
var _rec := 0.0


func _setup() -> void:
	max_health = 1
	body_size = Vector2(16, 16)
	knockback = Vector2(90, -30)
	stompable = true
	drop_chance = 0.45
	drop_weight_coin = 5.0
	drop_weight_food = 1.0
	drop_weight_essence = 4.0
	sprite_faces = -1
	_home = global_position + Vector2(0, -body_size.y / 2.0)


func _make_frames() -> SpriteFrames:
	var sf := Enemy.new_frames()
	Enemy.add_files_anim(sf, "idle", DIR, "wasp-idle", 6, 10.0)
	Enemy.add_files_anim(sf, "move", DIR, "wasp-move", 3, 12.0)
	Enemy.add_files_anim(sf, "attack", DIR, "wasp-attack", 2, 12.0)
	Enemy.add_files_anim(sf, "hurt", DIR, "wasp-hurt", 3, 10.0, false)
	Enemy.add_files_anim(sf, "die", DIR, "_asp-die", 13, 14.0, false)
	return sf


func _sprite_anchor() -> Vector2:
	return Vector2(21, 34)  # el centro del cuerpo queda a 8 px sobre el origen


func _uses_gravity() -> bool:
	return false


func _think(delta: float) -> void:
	_cool = maxf(_cool - delta, 0.0)
	match state:
		State.HOVER:
			# Patrulla de lado a lado con un leve vaivén vertical.
			var by := _home.y + sin(_time * 3.0) * 5.0
			if patrol_paused(delta):
				velocity = Vector2(0.0, (by - _center().y) * 4.0)  # flota en idle
			else:
				if (_center().x - _home.x) * _pdir >= patrol_range:
					_pdir = -_pdir
				velocity = Vector2(_pdir * patrol_speed, (by - _center().y) * 4.0)
				facing = _pdir
			if player and _cool <= 0.0 and _center().distance_to(player.global_position) < detect_range:
				state = State.SWOOP
				_swoop_t = 1.1
				_target = player.global_position + Vector2(0, -10)
				facing = 1 if _target.x >= global_position.x else -1
		State.SWOOP:
			_swoop_t -= delta
			var to := _target - _center()
			velocity = to.normalized() * swoop_speed
			if to.length() < 6.0 or _swoop_t <= 0.0 or is_on_wall() or is_on_floor():
				state = State.PAUSE
				_rec = recover_time
				_cool = cooldown
		State.PAUSE:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			_rec -= delta
			if _rec <= 0.0:
				state = State.RETURN
		State.RETURN:
			var to := _home - _center()
			velocity = to.normalized() * return_speed
			if absf(velocity.x) > 8.0:
				facing = 1 if velocity.x > 0.0 else -1
			if to.length() < 6.0:
				state = State.HOVER


func _pick_anim() -> String:
	match state:
		State.SWOOP:
			return "attack"
		State.HOVER:
			return "move" if absf(velocity.x) > 1.0 else "idle"
		State.PAUSE:
			return "idle"
	return "move"


func _center() -> Vector2:
	return global_position + Vector2(0, -body_size.y / 2.0)


func _on_hurt() -> void:
	state = State.RETURN
	_cool = cooldown
