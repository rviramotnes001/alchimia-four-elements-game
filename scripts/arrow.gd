class_name Arrow
extends Area2D
## Flecha del arco: vuela recta, daña al primer enemigo y desaparece al tocar el mundo.
## Si es elemental (element != NONE) también activa lo que reacciona a ese elemento.

@export var speed: float = 260.0
@export var damage: int = 1
@export var lifetime: float = 1.4

var direction: int = 1
var element: int = Elements.NONE


func _ready() -> void:
	$Sprite.flip_h = direction < 0
	if element != Elements.NONE:
		$Sprite.modulate = Elements.primary(element).lerp(Color.WHITE, 0.35)
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta


func _on_area_entered(area: Area2D) -> void:
	var target := area.get_parent()
	if target == null:
		return
	var hit := false
	if target.has_method("take_damage"):
		target.take_damage(damage, global_position.x - direction * 10.0)
		hit = true
	if element != Elements.NONE and target.has_method("on_element_hit"):
		target.on_element_hit(element, self)
		hit = true
	if element == Elements.Type.WATER and target.has_method("push"):
		target.push(direction, 90.0)
	if hit:
		queue_free()


func _on_body_entered(_body: Node) -> void:
	queue_free()
