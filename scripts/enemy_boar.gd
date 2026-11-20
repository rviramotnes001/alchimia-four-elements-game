@tool
class_name EnemyBoar
extends Enemy
## Lobo (el nombre de clase "Boar" se quedó del prototipo). Patrulla lento; si te ve
## al frente en su mismo nivel, se detiene, avisa (parpadea rojo) y embiste en
## línea recta. Si choca con una pared o llega al borde se aturde: es tu ventana
## para golpearlo. Si ya estás cerca hace un zarpazo (se prepara con el brazo atrás
## y luego golpea). NO se puede pisar (daña aunque caigas encima).

const DIR := "res://art/Enemies/Forest/Wolf"

enum State { PATROL, WINDUP, CHARGE, ATTACK, RECOVER }

@export var patrol_speed: float = 22.0
@export var charge_speed: float = 190.0
@export var sight_range: float = 140.0
@export var windup_time: float = 0.5
@export var charge_time: float = 0.7
@export var recover_time: float = 0.9
## Zarpazo cuerpo a cuerpo.
@export var attack_range: float = 36.0
@export var attack_damage: int = 2
@export var attack_cooldown: float = 0.9
## Cuadros de la animación "attack" en los que la garra hace daño (0-2 = preparación).
@export var claw_frames := Vector2i(3, 5)

var state: State = State.PATROL
var _timer := 0.0
var _atk_cd := 0.0
var _claw: Area2D


func _setup() -> void:
	max_health = 3
	body_size = Vector2(24, 26)
	contact_damage = 2
	drop_chance = 0.9
	drop_count = Vector2i(2, 3)
	drop_weight_coin = 5.0
	drop_weight_food = 3.0
	drop_weight_essence = 2.0
	sprite_faces = -1
	facing = -1


func _make_frames() -> SpriteFrames:
	var sf := Enemy.new_frames()
	Enemy.add_files_anim(sf, "idle", DIR, "werewolf-idle", 4, 6.0)
	Enemy.add_files_anim(sf, "run", DIR, "werewolf-run", 6, 8.0)
	Enemy.add_files_anim(sf, "charge", DIR, "werewolf-run", 6, 16.0)
	Enemy.add_files_anim(sf, "attack", DIR, "werewolf-attack", 7, 10.0, false)
	Enemy.add_files_anim(sf, "hurt", DIR, "werewolf-hurt", 3, 10.0, false)
	Enemy.add_files_anim(sf, "die", DIR, "werewolf-die", 9, 10.0, false)
	return sf


func _sprite_anchor() -> Vector2:
	return Vector2(45, 42)


func _build_body() -> void:
	super._build_body()
	# Garra: zona delante del lobo, activa solo en los cuadros del zarpazo.
	_claw = Area2D.new()
	_claw.name = "Claw"
	_claw.collision_layer = 0
	_claw.collision_mask = 2
	_claw.monitoring = false
	var cs := CollisionShape2D.new()
	cs.shape = RectangleShape2D.new()
	(cs.shape as RectangleShape2D).size = Vector2(attack_range * 0.8, 20)
	cs.position = Vector2(0, -body_size.y * 0.55)
	_claw.add_child(cs)
	add_child(_claw)


func _start_attack() -> void:
	state = State.ATTACK
	facing = 1 if dx_to_player() >= 0.0 else -1
	velocity.x = 0.0
	_sprite.play("attack")
	_atk_cd = attack_cooldown
	visual.modulate = Color.WHITE


func _player_close() -> bool:
	return player != null and _atk_cd <= 0.0 and absf(dx_to_player()) < attack_range \
		and absf(dy_to_player()) < 24.0


func _think(delta: float) -> void:
	_atk_cd = maxf(_atk_cd - delta, 0.0)
	match state:
		State.PATROL:
			if patrol_paused(delta):
				velocity.x = 0.0  # se detiene en idle y luego sigue
			else:
				if is_on_floor() and (is_on_wall() or not ground_ahead()):
					facing = -facing
				velocity.x = facing * patrol_speed
			if _player_close():
				_start_attack()
			elif _sees_player():
				state = State.WINDUP
				_timer = windup_time
				velocity.x = 0.0
		State.WINDUP:
			velocity.x = 0.0
			facing = 1 if dx_to_player() >= 0.0 else -1
			visual.modulate = Color(1.6, 0.5, 0.5) if int(_time * 16.0) % 2 == 0 else Color.WHITE
			_timer -= delta
			if _timer <= 0.0:
				visual.modulate = Color.WHITE
				state = State.CHARGE
				_timer = charge_time
		State.CHARGE:
			velocity.x = facing * charge_speed
			_timer -= delta
			if _player_close():
				_start_attack()
			elif is_on_wall() or not ground_ahead(4.0) or _timer <= 0.0:
				state = State.RECOVER
				_timer = recover_time
				velocity.x = 0.0
		State.ATTACK:
			var f := _sprite.frame
			# Pequeño impulso hacia delante mientras se lanza el zarpazo.
			velocity.x = facing * 70.0 if f >= claw_frames.x and f <= claw_frames.y else 0.0
			var active := f >= claw_frames.x and f <= claw_frames.y
			_claw.position.x = facing * (body_size.x / 2.0 + attack_range * 0.3)
			_claw.set_deferred("monitoring", active)
			if active and _claw.monitoring:
				for body in _claw.get_overlapping_bodies():
					if body.has_method("take_hit"):
						body.take_hit(global_position.x, attack_damage)
			if not _sprite.is_playing():
				_end_attack()
		State.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
			_timer -= delta
			if _timer <= 0.0:
				state = State.PATROL


func _end_attack() -> void:
	_claw.set_deferred("monitoring", false)
	state = State.RECOVER
	_timer = 0.5
	velocity.x = 0.0


func _pick_anim() -> String:
	match state:
		State.PATROL:
			return "run" if absf(velocity.x) > 1.0 else "idle"
		State.CHARGE:
			return "charge"
		State.ATTACK:
			return "attack"
	return "idle"


func _sees_player() -> bool:
	if player == null:
		return false
	var dx := dx_to_player()
	return absf(dx) < sight_range and absf(dy_to_player()) < 24.0 \
		and signf(dx) == float(facing)


func _on_hurt() -> void:
	if state == State.ATTACK:
		_claw.set_deferred("monitoring", false)
	if state == State.WINDUP or state == State.CHARGE or state == State.ATTACK:
		state = State.RECOVER
		_timer = recover_time * 0.5
		visual.modulate = Color.WHITE
