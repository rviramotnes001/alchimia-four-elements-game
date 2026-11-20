class_name Pickup
extends CharacterBody2D
## Objeto recogible que sueltan los enemigos: monedas, comida (recupera vida) y esencias.
## Salta al aparecer, cae al suelo, flota un poco y se va hacia el jugador si pasa cerca
## (monedas y esencias). Desaparece solo tras un rato (parpadea antes).
## Se crea con Pickup.spawn(...) o Pickup.roll_loot(...).

enum Kind { COIN, HEART, ESSENCE }

const COIN_TEXTURES := {
	1: "res://art/Collectibles/Bronze Coin.png",
	5: "res://art/Collectibles/Silver Coin.png",
	10: "res://art/Collectibles/Gold Coin.png",
}
const FOOD_TEXTURES := {
	2: "res://art/Collectibles/Apple.png",    # valor = medios corazones que cura
	1: "res://art/Collectibles/Banana.png",
}
## Esencia por color (el orden coincide con Elements.Type: agua, tierra, fuego, aire).
const ESSENCE_TEXTURES := [
	"res://art/Collectibles/Essence/Blue Essence.png",
	"res://art/Collectibles/Essence/Green Essences.png",
	"res://art/Collectibles/Essence/Red Essence.png",
	"res://art/Collectibles/Essence/Yellow Essence.png",
]

const GRAVITY := 700.0
const LIFETIME := 14.0
const BLINK_TIME := 3.0
const MAGNET_RANGE := 42.0
const MAGNET_SPEED := 170.0
## Tamaño en el mundo respecto al dibujo original (los iconos son grandes para el HUD).
const WORLD_SCALE := 0.6

var kind: int = Kind.COIN
## Moneda: valor (1, 5, 10). Comida: medios corazones. Esencia: índice del elemento (0-3).
var value: int = 1

var _age := 0.0
var _bounced := false
var _collected := false
var _sprite: Sprite2D
var _grab: Area2D


## Crea un recogible en `pos` con un saltito.
static func spawn(parent: Node, pos: Vector2, p_kind: int, p_value: int = 1) -> Pickup:
	var p := Pickup.new()
	p.kind = p_kind
	p.value = p_value
	parent.add_child(p)
	p.global_position = pos
	p.velocity = Vector2(randf_range(-55.0, 55.0), randf_range(-190.0, -140.0))
	return p


## Tira los dados de un botín: devuelve true si soltó algo.
## Los pesos reparten entre moneda, comida y esencia.
static func roll_loot(parent: Node, pos: Vector2, chance: float, w_coin: float, w_heart: float,
		w_essence: float, count := Vector2i(1, 2)) -> bool:
	if randf() > chance:
		return false
	var total := w_coin + w_heart + w_essence
	if total <= 0.0:
		return false
	for i in randi_range(count.x, count.y):
		var r := randf() * total
		if r < w_coin:
			var c := randf()
			spawn(parent, pos, Kind.COIN, 1 if c < 0.7 else (5 if c < 0.95 else 10))
		elif r < w_coin + w_heart:
			spawn(parent, pos, Kind.HEART, 2 if randf() < 0.5 else 1)
		else:
			spawn(parent, pos, Kind.ESSENCE, randi_range(0, 3))
	return true


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	(shape.shape as RectangleShape2D).size = Vector2(6, 6)
	shape.position = Vector2(0, -3)
	add_child(shape)

	_sprite = Sprite2D.new()
	_sprite.texture = load(_texture_path())
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2.ONE * WORLD_SCALE
	var h := _sprite.texture.get_height() * WORLD_SCALE
	_sprite.position = Vector2(0, -h / 2.0 - 2.0)
	_sprite.z_index = 3
	add_child(_sprite)

	_grab = Area2D.new()
	_grab.collision_layer = 0
	_grab.collision_mask = 2
	var gs := CollisionShape2D.new()
	gs.shape = CircleShape2D.new()
	(gs.shape as CircleShape2D).radius = 11.0
	gs.position = Vector2(0, -8)
	_grab.add_child(gs)
	add_child(_grab)


func _texture_path() -> String:
	match kind:
		Kind.HEART:
			return FOOD_TEXTURES.get(value, FOOD_TEXTURES[1])
		Kind.ESSENCE:
			return ESSENCE_TEXTURES[clampi(value, 0, 3)]
	return COIN_TEXTURES.get(value, COIN_TEXTURES[1])


func _physics_process(delta: float) -> void:
	if _collected:
		return
	_age += delta
	if _age >= LIFETIME:
		queue_free()
		return
	if _age > LIFETIME - BLINK_TIME:
		_sprite.visible = int(_age * 12.0) % 2 == 0

	var player := get_tree().get_first_node_in_group("player") as Node2D
	var magnet := false
	if player and kind != Kind.HEART and _age > 0.35:
		var to := player.global_position + Vector2(0, -12) - global_position
		if to.length() < MAGNET_RANGE:
			magnet = true
			velocity = to.normalized() * MAGNET_SPEED
	if not magnet:
		velocity.y += GRAVITY * delta
		velocity.x = move_toward(velocity.x, 0.0, 60.0 * delta)
	var was_air := not is_on_floor()
	move_and_slide()
	if not magnet and is_on_floor() and was_air and not _bounced:
		_bounced = true
		velocity.y = -70.0  # un rebotito
	# Flota suavemente cuando está quieto.
	if is_on_floor():
		_sprite.offset.y = sin(_age * 4.0) * 1.2

	if _age > 0.25:
		for body in _grab.get_overlapping_bodies():
			if body.is_in_group("player") and _try_collect(body):
				return


func _try_collect(player: Node) -> bool:
	match kind:
		Kind.COIN:
			player.add_coins(value)
		Kind.ESSENCE:
			player.add_essence(value)
		Kind.HEART:
			if player.health >= player.max_health:
				return false  # con la vida llena se queda en el suelo por si la necesitas
			player.heal(value)
	_collected = true
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_sprite, "position:y", _sprite.position.y - 10.0, 0.18)
	tw.tween_property(_sprite, "modulate:a", 0.0, 0.18)
	tw.chain().tween_callback(queue_free)
	return true
