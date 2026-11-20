@tool
class_name EnemyMandrake
extends Enemy
## Mandrágora emboscadora. Escondida bajo tierra (solo se ve un brote) hasta que te
## acercas; entonces sale de golpe, te persigue y ataca con sus raíces. Si te alejas
## mucho vuelve a enterrarse. Mientras está enterrada no se le puede dañar.
## Se puede PISAR una vez fuera.

const DIR := "res://art/Enemies/Forest/Plant"

enum State { HIDDEN, EMERGE, CHASE, ATTACK, RECOVER, BURROW }

@export var trigger_range: float = 60.0
@export var chase_speed: float = 62.0
@export var attack_range: float = 26.0
@export var attack_damage: int = 1
@export var attack_cooldown: float = 0.9
@export var give_up_range: float = 170.0
## Cuadros de "attack" con daño (0-3 = prepara la raíz).
@export var hit_frames := Vector2i(4, 5)

var state: State = State.HIDDEN
var _timer := 0.0
var _atk_cd := 0.0
var _far_time := 0.0


func _setup() -> void:
	max_health = 3
	body_size = Vector2(16, 28)
	contact_damage = 1
	stompable = true
	drop_chance = 0.7
	drop_weight_coin = 3.0
	drop_weight_food = 3.0
	drop_weight_essence = 4.0
	sprite_faces = -1
	facing = -1


func _make_frames() -> SpriteFrames:
	var sf := Enemy.new_frames()
	Enemy.add_files_anim(sf, "idle", DIR, "mandrake-idle", 4, 6.0)
	Enemy.add_files_anim(sf, "show", DIR, "mandrake-show", 5, 10.0, false)
	Enemy.add_files_anim(sf, "run", DIR, "mandrake-run", 6, 11.0)
	Enemy.add_files_anim(sf, "attack", DIR, "mandrake-attack", 7, 11.0, false)
	Enemy.add_files_anim(sf, "hurt", DIR, "mandrake-hurt", 3, 10.0, false)
	Enemy.add_files_anim(sf, "die", DIR, "mandrake-die", 10, 10.0, false)
	return sf


func _sprite_anchor() -> Vector2:
	return Vector2(36, 37)


func _build_body() -> void:
	super._build_body()
	build_melee(attack_range, 22.0)
	if not Engine.is_editor_hint():
		_set_hidden(true)
	elif _sprite:
		_sprite.animation = "show"
		_sprite.frame = 0  # en el editor se ve el brote


## Escondida: solo se ve el brote, sin daño ni colisión con ataques.
func _set_hidden(h: bool) -> void:
	contact.set_deferred("monitoring", not h)
	hurtbox.set_deferred("monitorable", not h)
	if h and _sprite:
		_sprite.animation = "show"
		_sprite.frame = 0
		_sprite.pause()


func _think(delta: float) -> void:
	_atk_cd = maxf(_atk_cd - delta, 0.0)
	match state:
		State.HIDDEN:
			velocity.x = 0.0
			if player and absf(dx_to_player()) < trigger_range and absf(dy_to_player()) < 30.0:
				state = State.EMERGE
				facing = 1 if dx_to_player() >= 0.0 else -1
				_sprite.play("show")
		State.EMERGE:
			velocity.x = 0.0
			if not _sprite.is_playing():
				_set_hidden(false)
				state = State.CHASE
				_far_time = 0.0
		State.CHASE:
			facing = 1 if dx_to_player() >= 0.0 else -1
			if absf(dx_to_player()) > give_up_range or absf(dy_to_player()) > 50.0:
				_far_time += delta
			else:
				_far_time = 0.0
			if _far_time > 2.0:
				_set_hidden(true)  # deja de ser dañable mientras se entierra
				state = State.BURROW
				_sprite.play_backwards("show")
			elif _atk_cd <= 0.0 and absf(dx_to_player()) < attack_range and absf(dy_to_player()) < 26.0:
				state = State.ATTACK
				velocity.x = 0.0
				_sprite.play("attack")
				_atk_cd = attack_cooldown
			elif is_on_floor() and (is_on_wall() or not ground_ahead(6.0)):
				velocity.x = 0.0
			else:
				velocity.x = facing * chase_speed
		State.ATTACK:
			velocity.x = 0.0
			var f := _sprite.frame
			melee_tick(f >= hit_frames.x and f <= hit_frames.y, attack_damage)
			if not _sprite.is_playing():
				melee_off()
				state = State.RECOVER
				_timer = 0.4
		State.RECOVER:
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				state = State.CHASE
		State.BURROW:
			velocity.x = 0.0
			if not _sprite.is_playing():
				state = State.HIDDEN
				_set_hidden(true)


func _pick_anim() -> String:
	match state:
		State.HIDDEN, State.EMERGE, State.BURROW, State.ATTACK:
			return _sprite.animation  # estos estados controlan su propia animación
		State.CHASE:
			return "run" if absf(velocity.x) > 1.0 else "idle"
	return "idle"


func _on_hurt() -> void:
	melee_off()
	if state == State.ATTACK:
		state = State.RECOVER
		_timer = 0.3
