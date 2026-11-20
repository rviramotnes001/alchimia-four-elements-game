class_name EnemyShot
extends Area2D
## Proyectil de enemigo (gota de agua). Vuela recto, daña al jugador y se rompe
## al tocar el mundo. Se crea con EnemyShot.spawn(...).

var direction := 1
var speed := 120.0
var damage := 1
var lifetime := 1.6


static func spawn(parent: Node, pos: Vector2, dir: int, dmg: int = 1, spd: float = 120.0) -> EnemyShot:
	var s := EnemyShot.new()
	s.direction = dir
	s.damage = dmg
	s.speed = spd
	parent.add_child(s)
	s.global_position = pos
	return s


func _ready() -> void:
	collision_layer = 0
	collision_mask = 3  # mundo (1) + jugador (2)
	var cs := CollisionShape2D.new()
	cs.shape = CircleShape2D.new()
	(cs.shape as CircleShape2D).radius = 3.0
	add_child(cs)
	# Gota: cuerpo celeste con núcleo claro y cola.
	var drop := Polygon2D.new()
	drop.color = Color(0.3, 0.85, 1.0)
	drop.polygon = PackedVector2Array([Vector2(-5 * direction, 0), Vector2(0, -3), Vector2(4 * direction, 0), Vector2(0, 3)])
	add_child(drop)
	var core := Polygon2D.new()
	core.color = Color(0.85, 1.0, 1.0)
	core.polygon = PackedVector2Array([Vector2(0, -1), Vector2(2 * direction, 0), Vector2(0, 1)])
	add_child(core)
	z_index = 4
	body_entered.connect(_on_body)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta


func _on_body(body: Node) -> void:
	if body.has_method("take_hit"):
		body.take_hit(global_position.x - direction * 6.0, damage)
	queue_free()
