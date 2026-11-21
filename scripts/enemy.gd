@tool
class_name Enemy
extends CharacterBody2D
## Base de todos los enemigos. Crea solo su cuerpo, su Hurtbox (lo que golpean la
## espada y las flechas) y su zona de contacto (lo que daña al jugador).
## Los tipos concretos heredan y sobreescriben:
##   _setup()       datos: tamaño, color, vida (se llama ANTES de construir el cuerpo)
##   _make_frames() SpriteFrames con las animaciones (idle, walk, hurt, die...)
##   _think(delta)  la IA (mover velocity.x/y). Gravedad y move_and_slide los hace la base
##   _pick_anim()   nombre de la animación según el estado
## Mismo contrato que TrainingDummy: take_damage(amount, from_x) y push(dir, force).
##
## PISOTÓN: si `stompable` y el jugador cae sobre él, muere y el jugador rebota
## (como una plataforma). Si no es pisable, el contacto desde arriba también daña.

signal died

@export var max_health: int = 3
## Daño por contacto en MEDIOS corazones (1 = medio corazón, 2 = un corazón).
@export var contact_damage: int = 1
@export var gravity: float = 900.0
@export var body_size := Vector2(14, 12)
@export var color := Color(0.5, 0.8, 0.4)
@export var knockback := Vector2(110, -80)
@export var show_label: bool = false
@export_group("Patrulla")
## Tiempo caminando antes de detenerse (segundos, mín y máx al azar).
@export var patrol_walk_time := Vector2(2.5, 4.5)
## Tiempo detenido en idle antes de seguir patrullando.
@export var patrol_pause_time := Vector2(0.8, 1.6)
## Zona de patrulla: radio en px alrededor de su punto de origen (donde lo colocas en la sala). Da la vuelta
## al llegar al límite, en paredes, bordes y al empezar una pendiente (patrulla solo en plano). 0 = sin límite.
## Si algo lo saca de la zona (persecución, golpe), vuelve a ella antes de seguir patrullando.
@export var patrol_radius: float = 56.0
@export_group("Pisotón")
@export var stompable: bool = false
## Fuerza del rebote del jugador (salto normal = 320). Con el botón de salto sube más.
@export var stomp_bounce: float = 260.0
@export var stomp_bounce_held: float = 360.0
@export_group("Muerte")
## Si es true, al terminar su animación de muerte aparece una nube de estrellas; si no, se desvanece (fade out).
@export var death_puff: bool = false
@export_group("Botín")
## Probabilidad de soltar algo al morir (0 a 1) y cuántos objetos (mín, máx).
@export_range(0.0, 1.0, 0.05) var drop_chance: float = 0.5
@export var drop_count := Vector2i(1, 2)
## Pesos para repartir entre monedas, comida (recupera vida) y esencias.
@export var drop_weight_coin: float = 6.0
@export var drop_weight_food: float = 2.0
@export var drop_weight_essence: float = 2.0
@export_group("Sprite")
## Hacia dónde mira el dibujo original: -1 izquierda, 1 derecha.
@export var sprite_faces: int = -1

var health: int = 0
var facing: int = 1
var dead := false
var _flash := 0.0
var _stun := 0.0
var _time := 0.0
var _pause_left := 0.0
var _walk_left := 0.0
var _player_y_hist: Array[float] = []
var _home_x := 0.0

var visual: Node2D
var hurtbox: Area2D
var contact: Area2D
var label: Label
var player: Node2D
var _sprite: AnimatedSprite2D
var _melee: Area2D
var _body_shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	# Pendientes de 45° exactos cuentan como suelo (con el límite por defecto se tratan como pared
	# y el enemigo se queda trabado), y el imán al suelo lo pega al bajar.
	floor_max_angle = deg_to_rad(50.0)
	floor_snap_length = 10.0
	_setup()
	if not _uses_gravity():
		floor_snap_length = 0.0  # voladores: nada de imán al suelo
	health = max_health
	_build_body()
	if Engine.is_editor_hint():
		return  # en el editor solo se dibuja para poder colocarlo
	_home_x = global_position.x
	_update_label()


func _build_body() -> void:
	# El cuerpo se construye siempre por código. Si la escena trae hijos viejos (p. ej. al duplicar un enemigo en
	# el editor se guardan los hijos creados en tiempo de ejecución y salía un sprite doble), se descartan.
	for old in get_children():
		remove_child(old)
		old.queue_free()
	var half := body_size / 2.0
	_body_shape = CollisionShape2D.new()
	_body_shape.shape = RectangleShape2D.new()
	(_body_shape.shape as RectangleShape2D).size = body_size
	_body_shape.position = Vector2(0, -half.y)
	add_child(_body_shape)

	var frames := _make_frames()
	if frames != null:
		_sprite = AnimatedSprite2D.new()
		_sprite.sprite_frames = frames
		_sprite.centered = false
		_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var tex := frames.get_frame_texture(frames.get_animation_names()[0], 0)
		_sprite.position = Vector2(-_sprite_anchor().x, -_sprite_anchor().y) if tex else Vector2.ZERO
		var holder := Node2D.new()
		holder.add_child(_sprite)
		visual = holder
		_play("idle")
	else:
		var poly := Polygon2D.new()
		poly.color = color
		poly.polygon = PackedVector2Array([
			Vector2(-half.x, -body_size.y), Vector2(half.x, -body_size.y),
			Vector2(half.x, 0), Vector2(-half.x, 0)])
		visual = poly
	add_child(visual)

	hurtbox = Area2D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.collision_layer = 16
	hurtbox.collision_mask = 0
	var hs := CollisionShape2D.new()
	hs.shape = RectangleShape2D.new()
	(hs.shape as RectangleShape2D).size = body_size + Vector2(2, 2)
	hs.position = Vector2(0, -half.y)
	hurtbox.add_child(hs)
	add_child(hurtbox)

	contact = Area2D.new()
	contact.name = "Contact"
	contact.collision_layer = 0
	contact.collision_mask = 2
	var cs := CollisionShape2D.new()
	cs.shape = RectangleShape2D.new()
	(cs.shape as RectangleShape2D).size = body_size
	cs.position = Vector2(0, -half.y)
	contact.add_child(cs)
	add_child(contact)

	label = Label.new()
	label.scale = Vector2(0.5, 0.5)
	label.position = Vector2(-10, -body_size.y - 18)
	label.visible = show_label and not Engine.is_editor_hint()
	add_child(label)


## Para los tipos concretos: ajustar datos ANTES de construir el cuerpo.
func _setup() -> void:
	pass


## Devuelve SpriteFrames o null (null = caja de color).
func _make_frames() -> SpriteFrames:
	return null


## Punto del cuadro que va sobre los pies/centro del cuerpo: (x centro, y suelo).
func _sprite_anchor() -> Vector2:
	return Vector2(21, 22)


## IA del tipo.
func _think(_delta: float) -> void:
	pass


func _pick_anim() -> String:
	return "idle"


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if dead:
		# El cuerpo caído cae al suelo y ya no hace nada más.
		velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return
	_time += delta
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	if _flash > 0.0:
		_flash -= delta
		visual.modulate = Color(3, 3, 3) if _flash > 0.0 else Color.WHITE
	if _stun > 0.0:
		_stun -= delta
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
	else:
		_think(delta)
	if _uses_gravity() and not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
	_apply_facing()
	_play("hurt" if _stun > 0.0 and _has_anim("hurt") else _pick_anim())
	_check_contact()


## Llamar cada cuadro desde la patrulla. Devuelve true mientras toca estar detenido
## (el tipo debe quedarse quieto y mostrar idle); al terminar la pausa sigue caminando.
func patrol_paused(delta: float) -> bool:
	if _pause_left > 0.0:
		_pause_left -= delta
		return true
	if _walk_left <= 0.0:
		_walk_left = randf_range(patrol_walk_time.x, patrol_walk_time.y)
	_walk_left -= delta
	if _walk_left <= 0.0:
		_pause_left = randf_range(patrol_pause_time.x, patrol_pause_time.y)
		return true
	return false


func _uses_gravity() -> bool:
	return true


func _apply_facing() -> void:
	visual.scale.x = facing * sprite_faces if _sprite else facing


func _has_anim(anim: String) -> bool:
	return _sprite != null and _sprite.sprite_frames.has_animation(anim)


func _play(anim: String) -> void:
	if _sprite and _sprite.animation != anim and _has_anim(anim):
		_sprite.play(anim)


func _check_contact() -> void:
	if player:
		_player_y_hist.append(player.global_position.y)
		if _player_y_hist.size() > 6:
			_player_y_hist.remove_at(0)
	if not contact.monitoring:
		return  # escondida o muerta
	for body in contact.get_overlapping_bodies():
		if not body.has_method("take_hit"):
			continue
		if stompable and _is_stomp(body):
			_stomp(body)
			return
		body.take_hit(global_position.x, contact_damage)


## Pisotón = el jugador no sube y en los últimos cuadros tuvo los pies por encima de
## nuestra cabeza (un golpe de lado nunca cuenta). Se mira el historial porque el
## contacto se detecta con 1-2 cuadros de retraso y el jugador cae rápido.
func _is_stomp(body: Node2D) -> bool:
	var vy: float = body.velocity.y if "velocity" in body else 0.0
	return vy >= 0.0 and not _player_y_hist.is_empty() \
		and _player_y_hist.min() <= global_position.y - body_size.y + 4.0


func _stomp(body: Node2D) -> void:
	if body.has_method("bounce"):
		body.bounce(stomp_bounce, stomp_bounce_held)
	health = 0
	_update_label()
	_die()


## Lo llaman la espada y las flechas. from_x = posición X de quien golpea.
func take_damage(amount: int, from_x: float) -> void:
	if dead:
		return
	health -= amount
	_flash = 0.12
	_stun = 0.3
	var dir := 1.0 if global_position.x >= from_x else -1.0
	velocity = Vector2(dir * knockback.x, knockback.y)
	_on_hurt()
	_update_label()
	if health <= 0:
		_die()


## Empujón sin daño (chorro de agua, golpe de agua).
func push(direction: float, force: float) -> void:
	if dead:
		return
	velocity = Vector2(direction * force, -40.0)
	_flash = 0.08
	_stun = 0.2


func _on_hurt() -> void:
	pass


func _die() -> void:
	dead = true
	visual.modulate = Color.WHITE
	contact.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	# El cuerpo deja de estorbar al jugador pero sigue cayendo al suelo.
	collision_layer = 0
	label.visible = false
	melee_off()
	_drop_loot()
	died.emit()
	var wait := 0.5
	if _has_anim("die"):
		_sprite.play("die")
		var sf := _sprite.sprite_frames
		wait = sf.get_frame_count("die") / maxf(sf.get_animation_speed("die"), 1.0)
	await get_tree().create_timer(wait + 0.15).timeout
	if death_puff and get_parent():
		_spawn_puff()
		queue_free()
		return
	var tw := create_tween()
	tw.tween_property(visual, "modulate:a", 0.0, 0.35)
	tw.tween_callback(queue_free)


## Nube de estrellas (art/Enemies/Forest/enemy-deadth.png: 6 cuadros de 40x41).
func _spawn_puff() -> void:
	var sf := Enemy.new_frames()
	sf.add_animation("puff")
	sf.set_animation_speed("puff", 14.0)
	sf.set_animation_loop("puff", false)
	var tex: Texture2D = load("res://art/Enemies/Forest/enemy-deadth.png")
	for i in 6:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * 40, 0, 40, 41)
		sf.add_frame("puff", at)
	var puff := AnimatedSprite2D.new()
	puff.sprite_frames = sf
	puff.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	puff.z_index = 5
	puff.global_position = global_position + Vector2(0, -body_size.y / 2.0)
	get_parent().add_child(puff)
	puff.play("puff")
	puff.animation_finished.connect(puff.queue_free)


# ------------------------------------------------------------ Ataque cuerpo a cuerpo

## Crea la zona del golpe (garra, espada) delante del enemigo. Apagada hasta usarla.
func build_melee(reach: float, height: float = 20.0) -> void:
	_melee = Area2D.new()
	_melee.name = "Melee"
	_melee.collision_layer = 0
	_melee.collision_mask = 2
	_melee.monitoring = false
	var cs := CollisionShape2D.new()
	cs.shape = RectangleShape2D.new()
	(cs.shape as RectangleShape2D).size = Vector2(reach, height)
	cs.position = Vector2(0, -body_size.y * 0.55)
	_melee.add_child(cs)
	_melee.set_meta("reach", reach)
	add_child(_melee)


## Llamar cada cuadro durante el ataque: activa la zona y daña mientras `active`.
func melee_tick(active: bool, damage: int) -> void:
	if _melee == null:
		return
	var reach: float = _melee.get_meta("reach")
	_melee.position.x = facing * (body_size.x / 2.0 + reach * 0.4)
	_melee.set_deferred("monitoring", active)
	if active and _melee.monitoring:  # monitoring se activa un cuadro después
		for body in _melee.get_overlapping_bodies():
			if body.has_method("take_hit"):
				body.take_hit(global_position.x, damage)


func melee_off() -> void:
	if _melee:
		_melee.set_deferred("monitoring", false)


## Tira los dados del botín en el punto donde murió.
func _drop_loot() -> void:
	# En diferido: la muerte puede llegar desde una señal de colisión (espada, flecha).
	_spawn_loot.call_deferred(get_parent(), global_position + Vector2(0, -body_size.y * 0.5))


func _spawn_loot(parent: Node, pos: Vector2) -> void:
	if parent == null or not is_instance_valid(parent):
		return
	Pickup.roll_loot(parent, pos, drop_chance, drop_weight_coin, drop_weight_food,
		drop_weight_essence, drop_count)


func dx_to_player() -> float:
	return player.global_position.x - global_position.x if player else INF


func dy_to_player() -> float:
	return player.global_position.y - global_position.y if player else INF


## ¿Hay suelo un paso adelante? (para no caerse de las plataformas)
func ground_ahead(step: float = 10.0) -> bool:
	return not is_inf(ground_y_ahead(step))


## ¿Debe dar la vuelta una patrulla? Llamar solo mientras patrulla (no persiguiendo): pared, borde, límite de la
## zona de patrulla o comienzo de una pendiente/escalón (la patrulla es siempre en plano, caminar inclinado se ve raro).
func patrol_should_turn(step: float = 10.0) -> bool:
	if not is_on_floor():
		return false
	var dx := global_position.x - _home_x
	if patrol_radius > 0.0 and absf(dx) > patrol_radius:
		facing = -1 if dx > 0.0 else 1  # fuera de la zona: regresa a casa (puede cruzar pendientes)
		return false
	if is_on_wall():
		return true
	var gy := ground_y_ahead(step)
	if is_inf(gy) or absf(gy - global_position.y) > 3.0:
		return true
	return patrol_radius > 0.0 and dx * facing >= patrol_radius


## Altura (y global) del suelo un paso adelante, o INF si no hay.
func ground_y_ahead(step: float = 10.0) -> float:
	var space := get_world_2d().direct_space_state
	# El rayo arranca 12 px arriba de los pies: en una subida el suelo de adelante es más alto
	# y, si arrancara dentro del tile, no detectaría nada (el enemigo daría media vuelta sin razón).
	var from := global_position + Vector2(facing * (body_size.x / 2.0 + step), -12.0)
	# Llega 28 px por debajo de los pies: alcanza para bajar una pendiente de 45° (la colisión de las pendientes
	# está bajada ~5 px y la caída a un paso adelante es de 14-20 px) y sigue tratando un precipicio de 2+ tiles
	# (32 px) como borde.
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 40.0), 1)
	var hit := space.intersect_ray(q)
	return INF if hit.is_empty() else hit.position.y


func _update_label() -> void:
	if label:
		label.text = "%d/%d" % [maxi(health, 0), max_health]


# ------------------------------------------------------------ Utilidades de sprites

## Agrega una animación desde archivos numerados: "<dir>/<prefix>-00.png", "-01"...
static func add_files_anim(sf: SpriteFrames, anim: String, dir: String, prefix: String,
		count: int, fps: float, loop: bool = true) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	for i in count:
		sf.add_frame(anim, load("%s/%s-%02d.png" % [dir, prefix, i]))


## Agrega una animación desde una hoja: cada cuadro es Vector2i(columna, fila).
static func add_sheet_anim(sf: SpriteFrames, anim: String, sheet: Texture2D, cell: Vector2i,
		cells: Array, fps: float, loop: bool = true) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	for c in cells:
		var at := AtlasTexture.new()
		at.atlas = sheet
		at.region = Rect2(c.x * cell.x, c.y * cell.y, cell.x, cell.y)
		sf.add_frame(anim, at)


static func new_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	return sf
