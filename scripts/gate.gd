class_name Gate
extends StaticBody2D
## Compuerta que sube al abrirse (set_open(true)). La usan interruptores y antorchas.

@export var open_height: float = 44.0
@export var open_time: float = 0.5
@export var is_open: bool = false

@onready var shape: CollisionShape2D = $CollisionShape2D
var _closed_y := 0.0
var _tween: Tween


func _ready() -> void:
	_closed_y = position.y
	if is_open:
		position.y = _closed_y - open_height
		shape.set_deferred("disabled", true)


func set_open(value: bool) -> void:
	is_open = value
	if _tween:
		_tween.kill()
	if value:
		shape.set_deferred("disabled", true)
	_tween = create_tween()
	_tween.tween_property(self, "position:y", _closed_y - open_height if value else _closed_y, open_time)\
		.set_trans(Tween.TRANS_SINE)
	if not value:
		_tween.tween_callback(func(): shape.set_deferred("disabled", false))
