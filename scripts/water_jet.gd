class_name WaterJet
extends Area2D
## Chorro de agua (poder principal del Agua). Vuela recto, empuja enemigos sin dañarlos y
## activa lo que reacciona al agua (on_element_hit). Se detiene al tocar algo.

@export var speed: float = 230.0
@export var lifetime: float = 0.45
@export var push_force: float = 170.0

var direction: int = 1


func _ready() -> void:
	$Visual.scale.x = direction
	area_entered.connect(_on_area_entered)
	body_entered.connect(func(_b): queue_free())
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta


func _on_area_entered(area: Area2D) -> void:
	var target := area.get_parent()
	if target == null:
		return
	var hit := false
	if target.has_method("on_element_hit"):
		target.on_element_hit(Elements.Type.WATER, self)
		hit = true
	if target.has_method("push"):
		target.push(direction, push_force)
		hit = true
	if hit:
		queue_free()
