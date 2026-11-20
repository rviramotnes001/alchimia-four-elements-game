class_name TrainingDummy
extends CharacterBody2D
## Muñeco de práctica: recibe daño, retrocede, parpadea y reaparece.
## Sirve para probar la espada y el arco antes de tener enemigos reales.

@export var max_health: int = 5
@export var gravity: float = 900.0
@export var respawn_time: float = 1.5

var health: int = 0
var _flash := 0.0

@onready var visual: Polygon2D = $Visual
@onready var label: Label = $Label
@onready var hurtbox: Area2D = $Hurtbox
@onready var shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	health = max_health
	_update_label()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
	move_and_slide()

	if _flash > 0.0:
		_flash -= delta
		visual.modulate = Color(3.0, 3.0, 3.0) if _flash > 0.0 else Color.WHITE


## Lo llaman la espada y las flechas. from_x = posición X de quien golpea.
func take_damage(amount: int, from_x: float) -> void:
	if health <= 0:
		return
	health -= amount
	var dir := 1.0 if global_position.x >= from_x else -1.0
	velocity = Vector2(dir * 120.0, -90.0)
	_flash = 0.12
	_update_label()
	if health <= 0:
		_die()


## Empujón sin daño (chorro de agua, golpe de agua). direction: 1 derecha, -1 izquierda.
func push(direction: float, force: float) -> void:
	if health <= 0:
		return
	velocity = Vector2(direction * force, -40.0)
	_flash = 0.08


func _die() -> void:
	visual.visible = false
	label.visible = false
	hurtbox.set_deferred("monitorable", false)
	await get_tree().create_timer(respawn_time).timeout
	health = max_health
	visual.visible = true
	label.visible = true
	hurtbox.set_deferred("monitorable", true)
	_update_label()


func _update_label() -> void:
	label.text = "%d/%d" % [health, max_health]
