class_name Player
extends CharacterBody2D
## Erek: movimiento de plataformas + ataque con espada.
## El origen del nodo está en los PIES del personaje (centro).
## Todos los números de "sensación" están en @export para ajustarlos en el Inspector.

signal attack_started
signal hurt_started
signal died
signal health_changed(current: int, maximum: int)
signal coins_changed(amount: int)
signal essences_changed(total: int)
signal weapon_changed(weapon: int)

enum State { NORMAL, ATTACK, HURT, DEAD }
enum Weapon { SWORD, BOW }

@export_group("Movimiento")
@export var run_speed: float = 130.0
@export var ground_accel: float = 1400.0
@export var ground_friction: float = 1800.0
@export var air_accel: float = 1000.0
@export var air_friction: float = 500.0

@export_group("Salto")
@export var jump_velocity: float = -320.0
@export var gravity_up: float = 900.0
@export var gravity_down: float = 1250.0
@export var max_fall_speed: float = 380.0
@export var jump_cut: float = 0.45
@export var coyote_time: float = 0.09
@export var jump_buffer_time: float = 0.1

@export_group("Ataque")
@export var attack_move_factor: float = 0.35
@export var attack_cooldown: float = 0.08
@export var attack_damage: int = 1
## Cuadros de la animación "attack" en los que la espada hace daño (inicio, fin).
@export var attack_active_frames: Vector2i = Vector2i(4, 8)
## Pausa breve al conectar un golpe (segundos). 0 la desactiva.
@export var hitstop: float = 0.06

@export_group("Arco")
@export var arrow_scene: PackedScene = preload("res://scenes/arrow.tscn")
@export var arrow_damage: int = 1
## Cuadro de "bow_attack" (y de "bow_attack_air") en el que sale la flecha.
@export var bow_release_frame: int = 5
@export var bow_release_frame_air: int = 4
## Al disparar el arco en el suelo el personaje se planta (0 = no se mueve).
@export var bow_ground_move_factor: float = 0.0
## Al disparar en el aire la gravedad se reduce para apuntar (1 = normal).
@export var bow_air_gravity_scale: float = 0.25
@export var bow_muzzle: Vector2 = Vector2(18.0, -17.0)
@export var water_jet_scene: PackedScene = preload("res://scenes/water_jet.tscn")
## Fuerza extra del empujón del golpe de espada de agua.
@export var water_sword_push: float = 150.0

@export_group("Agua")
@export var swim_speed_factor: float = 0.6
## Velocidad a la que se hunde sin nadar.
@export var swim_sink_speed: float = 35.0
@export var swim_drag: float = 500.0
## Impulso hacia arriba de cada brazada (botón de salto).
@export var swim_stroke_velocity: float = -130.0
@export var swim_dive_speed: float = 90.0
## Segundos de aire bajo el agua si NO se tiene Respiración acuática.
@export var max_oxygen: float = 6.0
@export var oxygen_regen: float = 6.0
@export var drown_damage: int = 1

@export_group("Vida")
## En MEDIOS corazones: 6 = 3 corazones.
@export var max_health: int = 6
@export var respawn_delay: float = 1.5

@export_group("Daño")
@export var hurt_time: float = 0.4
@export var knockback: Vector2 = Vector2(110.0, -150.0)
@export var invulnerable_time: float = 1.0

var state: State = State.NORMAL
var weapon: Weapon = Weapon.SWORD
var facing: int = 1
var _arrow_fired := false
var _water_zone: WaterZone = null
## Lo que hay al alcance para interactuar con E (lo asignan los puntos de riego, NPCs, etc.).
var interactable: Node = null
var oxygen: float = 0.0
## Elemento del golpe/flecha/poder en curso (Elements.NONE = normal).
var _swing_element: int = Elements.NONE
var _cast_element: int = Elements.NONE

var _coyote := 0.0
var _jump_buffer := 0.0
var _attack_cd := 0.0
var _hurt_timer := 0.0
var _invulnerable := 0.0
var _land_timer := 0.0
var _was_on_floor := true
var _prev_vy := 0.0

var health: int = 0
var _spawn_position := Vector2.ZERO
var _hit_targets: Array[Node] = []

@onready var visual: Node2D = $Visual
@onready var sprite: AnimatedSprite2D = $Visual/Sprite
@onready var sword_hitbox: Area2D = $SwordHitbox
@onready var elemental: ElementalPower = $Elemental
@onready var oxygen_meter: OxygenMeter = $OxygenMeter


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)
	sword_hitbox.area_entered.connect(_on_sword_hit)
	elemental.power_used.connect(_on_power_used)
	add_to_group("player")
	health = max_health
	oxygen = max_oxygen
	_spawn_position = global_position
	sprite.play("idle")
	health_changed.emit(health, max_health)
	weapon_changed.emit(weapon)


func _physics_process(delta: float) -> void:
	# Pendientes de 45° suaves: límite por encima de 45° y pegado al suelo al bajar.
	floor_max_angle = deg_to_rad(50.0)
	floor_snap_length = 18.0
	floor_constant_speed = true
	_attack_cd = maxf(_attack_cd - delta, 0.0)
	_land_timer = maxf(_land_timer - delta, 0.0)
	_update_invulnerability(delta)
	_update_oxygen(delta)

	match state:
		State.NORMAL, State.ATTACK:
			_move(delta)
		State.HURT:
			_hurt_timer -= delta
			_apply_gravity(delta)
			velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
			if _hurt_timer <= 0.0:
				state = State.NORMAL
		State.DEAD:
			_apply_gravity(delta)
			velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)

	_prev_vy = velocity.y
	_try_step_up(delta)
	var was_floor := _grounded()
	move_and_slide()
	_stick_to_slope(was_floor)
	_snap_on_slope()
	_detect_landing()
	_update_animation()


# ---------------------------------------------------------------- Movimiento

## Escalón automático: el suelo plano tiene la colisión hundida unos px y las pendientes de 45°
## empiezan al ras del tile, lo que deja un escalón de ~5 px. Si algo bloquea el avance a esa altura
## y arriba hay espacio, el jugador sube solo.
const STEP_HEIGHT := 6.0


## Suelo "pegado": al bajar una pendiente la caja queda unos px en el aire y Godot pierde el suelo (el
## personaje caía a escalones y la animación pasaba a "caer"). Si el suelo está justo debajo, se baja el
## cuerpo y se cuenta como en el suelo.
var _stuck := false
var _floor_n := Vector2.UP


func _grounded() -> bool:
	return is_on_floor() or _stuck


func _stick_to_slope(was_floor: bool) -> void:
	_stuck = false
	if is_on_floor():
		_floor_n = get_floor_normal()
		return
	if not was_floor or velocity.y < 0.0:
		return
	var col := KinematicCollision2D.new()
	if test_move(global_transform, Vector2(0.0, 18.0), col) and col.get_normal().y < -0.5:
		global_position.y += col.get_travel().y
		velocity.y = 0.0
		_floor_n = col.get_normal()
		_stuck = true


## En pendientes el movimiento sale en fracciones de píxel; con el snap de píxel de Godot, x e y se
## redondean en fotogramas distintos y el sprite "tiembla". Aquí se alinea x a un píxel entero y se
## ajusta y sobre la misma pendiente, así el sprite sube y baja en una escalera limpia de 45°.
func _snap_on_slope() -> void:
	var on_slope := _grounded() and absf(_floor_n.x) >= 0.05
	if not on_slope:
		return
	var n := _floor_n
	if absf(n.y) < 0.1:
		return
	var rx := roundf(global_position.x)
	var dy := -n.x * (rx - global_position.x) / n.y
	global_position = Vector2(rx, floorf(global_position.y + dy))


func _try_step_up(delta: float) -> void:
	if not _grounded() or velocity.y < 0.0 or absf(velocity.x) < 1.0:
		return
	# En pendientes no hace falta (la colisión es continua) y provocaba saltitos.
	if absf(_floor_n.x) > 0.05:
		return
	var motion := Vector2(velocity.x * delta, 0.0)
	var hit := KinematicCollision2D.new()
	if not test_move(global_transform, motion, hit):
		return
	# Solo escalones: una pendiente (normal inclinada) la resuelve move_and_slide sin saltos.
	if absf(hit.get_normal().y) > 0.3:
		return
	var raised := global_transform.translated(Vector2(0.0, -STEP_HEIGHT))
	if test_move(global_transform, Vector2(0.0, -STEP_HEIGHT)) or test_move(raised, motion):
		return
	global_position.y -= STEP_HEIGHT


func _move(delta: float) -> void:
	var on_floor := _grounded()
	var swimming := is_swimming()
	_apply_gravity(delta)

	# En el agua pero con el cuerpo fuera de la superficie se puede saltar para salir.
	if on_floor or (_water_zone != null and not swimming):
		_coyote = coyote_time
	else:
		_coyote -= delta

	# Salto: buffer + coyote time
	if Input.is_action_just_pressed("jump"):
		_jump_buffer = jump_buffer_time
	else:
		_jump_buffer -= delta
	if swimming:
		_swim_input(delta)
		_jump_buffer = 0.0
	elif _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_jump_buffer = 0.0
		_coyote = 0.0
	# Soltar el botón antes corta el salto (altura variable)
	if not swimming and Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut

	# Dirección horizontal
	var dir := Input.get_axis("move_left", "move_right")
	var factor := attack_move_factor if state == State.ATTACK else 1.0
	if state == State.ATTACK and sprite.animation == "bow_attack":
		factor = bow_ground_move_factor
	if swimming:
		factor *= swim_speed_factor
	if dir != 0.0:
		if state == State.NORMAL:
			facing = 1 if dir > 0.0 else -1
		var accel := ground_accel if on_floor else air_accel
		velocity.x = move_toward(velocity.x, dir * run_speed * factor, accel * delta)
	else:
		var fric := ground_friction if on_floor else air_friction
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)

	# Interactuar (E)
	if state == State.NORMAL and interactable != null and Input.is_action_just_pressed("interact"):
		if interactable.has_method("interact"):
			interactable.interact(self)

	# Cambiar de arma (espada <-> arco)
	if state == State.NORMAL and Input.is_action_just_pressed("weapon_swap"):
		weapon = Weapon.BOW if weapon == Weapon.SWORD else Weapon.SWORD
		weapon_changed.emit(weapon)

	# Ataque
	if state == State.NORMAL and _attack_cd <= 0.0 and Input.is_action_just_pressed("attack"):
		_start_attack()


## Nadar: brazada con el botón de salto, bajar con abajo (S / flecha abajo).
func _swim_input(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		velocity.y = swim_stroke_velocity
	elif Input.is_action_pressed("move_down"):
		velocity.y = move_toward(velocity.y, swim_dive_speed, 900.0 * delta)


func enter_water(zone: WaterZone) -> void:
	_water_zone = zone


func exit_water(zone: WaterZone) -> void:
	if _water_zone == zone:
		_water_zone = null


## Con el cuerpo (centro) bajo la superficie del agua.
func is_swimming() -> bool:
	return _water_zone != null and global_position.y - 14.0 > _water_zone.surface_y()


## Con la cabeza bajo la superficie: aquí se gasta el aire.
func is_head_underwater() -> bool:
	return _water_zone != null and global_position.y - 26.0 > _water_zone.surface_y()


func _update_oxygen(delta: float) -> void:
	if state == State.DEAD:
		return
	if is_head_underwater() and not elemental.water_breathing_active():
		oxygen = maxf(oxygen - delta, 0.0)
		if oxygen <= 0.0:
			take_hit(global_position.x, drown_damage, false)
	else:
		oxygen = minf(oxygen + oxygen_regen * delta, max_oxygen)
	oxygen_meter.set_ratio(oxygen / max_oxygen)


func _apply_gravity(delta: float) -> void:
	if is_swimming():
		velocity.y = move_toward(velocity.y, swim_sink_speed, swim_drag * delta)
		return
	if _grounded():
		return
	var g := gravity_up if velocity.y < 0.0 else gravity_down
	if state == State.ATTACK and sprite.animation == "bow_attack_air":
		g *= bow_air_gravity_scale
	velocity.y = minf(velocity.y + g * delta, max_fall_speed)


func _detect_landing() -> void:
	var on_floor := _grounded()
	if on_floor and not _was_on_floor and _prev_vy > 220.0 and state == State.NORMAL:
		_land_timer = 0.12
	_was_on_floor = on_floor


# -------------------------------------------------------------------- Ataque

func _start_attack() -> void:
	state = State.ATTACK
	_hit_targets.clear()
	_arrow_fired = false
	_cast_element = Elements.NONE
	_swing_element = Elements.NONE
	if weapon == Weapon.BOW:
		sprite.play("bow_attack" if _grounded() else "bow_attack_air")
	else:
		# Espada elemental: gasta un poco de energía si hay elemento activo.
		_swing_element = elemental.try_weapon_element(elemental.weapon_cost_sword)
		_tint_weapon(_swing_element)
		sprite.play("attack")
	attack_started.emit()


## Poder elemental (K): reutiliza la animación del arco y suelta el proyectil en el cuadro de disparo.
func _start_cast(element: int) -> void:
	state = State.ATTACK
	_hit_targets.clear()
	_arrow_fired = false
	_swing_element = Elements.NONE
	_cast_element = element
	sprite.play("bow_attack" if _grounded() else "bow_attack_air")
	attack_started.emit()


func _tint_weapon(element: int) -> void:
	sprite.self_modulate = Color.WHITE if element == Elements.NONE \
		else Elements.primary(element).lerp(Color.WHITE, 0.55)


func _on_animation_finished() -> void:
	if state == State.ATTACK and sprite.animation in ["attack", "bow_attack", "bow_attack_air"]:
		_end_attack()


func _fire_arrow() -> void:
	_arrow_fired = true
	var spawn_pos := global_position + Vector2(bow_muzzle.x * facing, bow_muzzle.y)
	if _cast_element == Elements.Type.WATER:
		var jet: WaterJet = water_jet_scene.instantiate()
		jet.direction = facing
		jet.global_position = spawn_pos
		get_parent().add_child(jet)
		return
	var arrow: Arrow = arrow_scene.instantiate()
	arrow.direction = facing
	arrow.damage = arrow_damage
	arrow.element = elemental.try_weapon_element(elemental.weapon_cost_arrow)
	arrow.global_position = spawn_pos
	get_parent().add_child(arrow)


func _end_attack() -> void:
	state = State.NORMAL
	_attack_cd = attack_cooldown
	_swing_element = Elements.NONE
	_cast_element = Elements.NONE
	_tint_weapon(Elements.NONE)
	sword_hitbox.set_deferred("monitoring", false)


## El hitbox solo está activo durante los cuadros del golpe.
func _on_frame_changed() -> void:
	if state == State.ATTACK and not _arrow_fired:
		if (sprite.animation == "bow_attack" and sprite.frame >= bow_release_frame) \
				or (sprite.animation == "bow_attack_air" and sprite.frame >= bow_release_frame_air):
			_fire_arrow()
	if sprite.animation != "attack" or state != State.ATTACK:
		return
	var active := sprite.frame >= attack_active_frames.x and sprite.frame <= attack_active_frames.y
	sword_hitbox.set_deferred("monitoring", active)


func _on_sword_hit(area: Area2D) -> void:
	var target := area.get_parent()
	if target == null or target in _hit_targets:
		return
	var reacts := target.has_method("on_element_hit") and _swing_element != Elements.NONE
	if not target.has_method("take_damage") and not reacts:
		return
	_hit_targets.append(target)
	if target.has_method("take_damage"):
		target.take_damage(attack_damage, global_position.x)
		elemental.on_hit_landed()
		_hit_stop()
	if reacts:
		target.on_element_hit(_swing_element, self)
	if _swing_element == Elements.Type.WATER and target.has_method("push"):
		target.push(facing, water_sword_push)


## Por ahora solo un destello del color del elemento. El efecto real de cada poder
## (Chorro de agua, etc.) se conecta aquí más adelante.
func _on_power_used(element: int) -> void:
	if element == Elements.Type.WATER and state == State.NORMAL:
		_start_cast(element)
	var tween := create_tween()
	sprite.modulate = Elements.primary(element).lerp(Color.WHITE, 0.4)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)


func _hit_stop() -> void:
	if hitstop <= 0.0:
		return
	Engine.time_scale = 0.05
	# Este temporizador ignora el time_scale para poder restaurarlo a tiempo.
	await get_tree().create_timer(hitstop, true, false, true).timeout
	Engine.time_scale = 1.0


# ------------------------------------------------------------ Daño y muerte

## Llamar desde enemigos/trampas. from_x = posición X de quien golpea.
## damage va en MEDIOS corazones: 1 = medio corazón (enemigos y trampas fáciles),
## 2 = un corazón (los difíciles).
func take_hit(from_x: float, damage: int = 1, with_knockback: bool = true) -> void:
	if state == State.DEAD or _invulnerable > 0.0:
		return
	health = maxi(health - damage, 0)
	health_changed.emit(health, max_health)
	if health <= 0:
		die()
		return
	if not with_knockback:
		# Daño por ahogo: sin retroceso, solo invulnerabilidad breve.
		_invulnerable = invulnerable_time
		return
	state = State.HURT
	sword_hitbox.set_deferred("monitoring", false)
	_hurt_timer = hurt_time
	_invulnerable = invulnerable_time
	var away := -1.0 if from_x > global_position.x else 1.0
	velocity = Vector2(knockback.x * away, knockback.y)
	facing = -int(away)
	sprite.play("hurt")
	hurt_started.emit()


## Cartera: monedas y esencias (viajan con el jugador entre salas).
var coins: int = 0
## Esencias por elemento (índice = Elements.Type: agua, tierra, fuego, aire).
var essence_counts: Array[int] = [0, 0, 0, 0]


func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)


func add_essence(element: int, amount: int = 1) -> void:
	essence_counts[clampi(element, 0, 3)] += amount
	essences_changed.emit(essences_total())


func essences_total() -> int:
	return essence_counts[0] + essence_counts[1] + essence_counts[2] + essence_counts[3]


## Cura en MEDIOS corazones (1 = medio corazón, 2 = corazón completo).
func heal(half_hearts: int) -> void:
	if state == State.DEAD:
		return
	health = mini(health + half_hearts, max_health)
	health_changed.emit(health, max_health)


## Rebote al pisar un enemigo (o un resorte): como una plataforma que te lanza.
## Si mantienes el botón de salto subes más.
func bounce(force: float, force_held: float = -1.0) -> void:
	if state == State.DEAD:
		return
	var f := force_held if force_held > 0.0 and Input.is_action_pressed("jump") else force
	velocity.y = -f
	_coyote = 0.0
	_jump_buffer = 0.0


func die() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	_invulnerable = 0.0
	velocity.x = 0.0
	sword_hitbox.set_deferred("monitoring", false)
	sprite.visible = true
	sprite.play("dead")
	died.emit()
	await get_tree().create_timer(respawn_delay).timeout
	respawn()


## Reaparece con la vida llena. Más adelante será en el último checkpoint.
func respawn() -> void:
	global_position = _spawn_position
	velocity = Vector2.ZERO
	health = max_health
	health_changed.emit(health, max_health)
	state = State.NORMAL
	_invulnerable = 1.0
	sprite.play("idle")


func _update_invulnerability(delta: float) -> void:
	if _invulnerable <= 0.0:
		sprite.visible = true
		return
	_invulnerable -= delta
	# Parpadeo mientras es invulnerable
	sprite.visible = int(_invulnerable * 20.0) % 2 == 0 or state == State.DEAD


# ---------------------------------------------------------------- Animación

func _update_animation() -> void:
	visual.scale.x = float(facing)
	sword_hitbox.position.x = 17.0 * facing
	# La animación de muerte es más alta (50 px) y necesita subirse 7 px.
	sprite.offset.y = -7.0 if sprite.animation == "dead" else 0.0

	if state != State.NORMAL:
		return

	var anim := "idle"
	if not _grounded():
		if velocity.y < -40.0:
			anim = "jump"
		elif velocity.y < 60.0:
			anim = "apex"
		else:
			anim = "fall"
	elif _land_timer > 0.0 and absf(velocity.x) < 10.0:
		anim = "land"
	elif absf(velocity.x) > 12.0:
		anim = "run"

	# Nota: idle_bow, jump_bow, apex_bow y fall_bow existen en erek_frames.tres
	# pero no se usan (muy pocos cuadros). El arco solo se ve al disparar.

	if sprite.animation != anim:
		sprite.play(anim)
