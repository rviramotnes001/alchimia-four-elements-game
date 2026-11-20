@tool
class_name EnemySatyr
extends Enemy
## Sátiro guerrero. Patrulla; si te ve (al frente a ~130 px o muy cerca por detrás)
## te PERSIGUE corriendo y, ya cerca, hace un tajo con su espada: primero la levanta
## (tu aviso para saltar o alejarte) y luego corta. No se puede pisar. Pierde el
## interés si te alejas mucho o cambias de nivel, y vuelve a patrullar.

const DIR := "res://art/Enemies/Forest/Satyr"

enum State { PATROL, CHASE, ATTACK, RECOVER }

@export var patrol_speed: float = 22.0
@export var chase_speed: float = 78.0
@export var sight_range: float = 130.0
@export var lose_range: float = 190.0
@export var attack_range: float = 34.0
@export var attack_damage: int = 2
@export var attack_cooldown: float = 1.0
## Cuadros de "attack" en los que la espada hace daño (0-2 = levanta la espada).
@export var slash_frames := Vector2i(3, 4)

var state: State = State.PATROL
var _timer := 0.0
var _atk_cd := 0.0


func _setup() -> void:
	max_health = 4
	body_size = Vector2(18, 30)
	contact_damage = 1
	drop_chance = 0.85
	drop_count = Vector2i(2, 3)
	drop_weight_coin = 5.0
	drop_weight_food = 2.0
	drop_weight_essence = 3.0
	sprite_faces = -1
	facing = -1


func _make_frames() -> SpriteFrames:
	var sf := Enemy.new_frames()
	Enemy.add_files_anim(sf, "idle", DIR, "satyr-idle", 4, 6.0)
	Enemy.add_files_anim(sf, "run", DIR, "satyr-run", 6, 9.0)
	Enemy.add_files_anim(sf, "chase", DIR, "satyr-run", 6, 13.0)
	Enemy.add_files_anim(sf, "attack", DIR, "satyr-attack", 7, 9.0, false)
	Enemy.add_files_anim(sf, "hurt", DIR, "satyr-hurt", 3, 10.0, false)
	Enemy.add_files_anim(sf, "die", DIR, "satyr-die", 8, 9.0, false)
	return sf


func _sprite_anchor() -> Vector2:
	return Vector2(48, 45)


func _build_body() -> void:
	super._build_body()
	build_melee(attack_range, 26.0)


func _think(delta: float) -> void:
	_atk_cd = maxf(_atk_cd - delta, 0.0)
	match state:
		State.PATROL:
			if patrol_paused(delta):
				velocity.x = 0.0
			else:
				if is_on_floor() and (is_on_wall() or not ground_ahead()):
					facing = -facing
				velocity.x = facing * patrol_speed
			if _spots_player():
				state = State.CHASE
		State.CHASE:
			facing = 1 if dx_to_player() >= 0.0 else -1
			if absf(dx_to_player()) > lose_range or absf(dy_to_player()) > 40.0:
				state = State.PATROL
			elif _atk_cd <= 0.0 and absf(dx_to_player()) < attack_range and absf(dy_to_player()) < 26.0:
				_start_attack()
			elif is_on_floor() and (is_on_wall() or not ground_ahead(6.0)):
				velocity.x = 0.0  # no se tira al vacío ni empuja paredes
			else:
				velocity.x = facing * chase_speed
		State.ATTACK:
			var f := _sprite.frame
			var active := f >= slash_frames.x and f <= slash_frames.y
			velocity.x = facing * 50.0 if active else 0.0
			melee_tick(active, attack_damage)
			if not _sprite.is_playing():
				melee_off()
				state = State.RECOVER
				_timer = 0.5
				velocity.x = 0.0
		State.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
			_timer -= delta
			if _timer <= 0.0:
				state = State.CHASE if _spots_player() else State.PATROL


func _start_attack() -> void:
	state = State.ATTACK
	facing = 1 if dx_to_player() >= 0.0 else -1
	velocity.x = 0.0
	_sprite.play("attack")
	_atk_cd = attack_cooldown


func _spots_player() -> bool:
	if player == null or absf(dy_to_player()) > 30.0:
		return false
	var dx := dx_to_player()
	if absf(dx) < 40.0:
		return true
	return absf(dx) < sight_range and signf(dx) == float(facing)


func _pick_anim() -> String:
	match state:
		State.PATROL:
			return "run" if absf(velocity.x) > 1.0 else "idle"
		State.CHASE:
			return "chase" if absf(velocity.x) > 1.0 else "idle"
		State.ATTACK:
			return "attack"
	return "idle"


func _on_hurt() -> void:
	melee_off()
	if state == State.ATTACK:
		state = State.RECOVER
		_timer = 0.4
