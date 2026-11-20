class_name ElementWheel
extends Control
## Rueda de elementos en el centro de la pantalla. Solo muestra los desbloqueados.
## Posiciones: arriba Agua, derecha Tierra, abajo Fuego, izquierda Aire.
## Se dibuja con rectángulos (pixel art limpio). Más adelante se cambia por arte propio.

const SLOT_SIZE := 28
const DISTANCE := 38

var unlocked: Array[int] = []
var hover: int = Elements.NONE

@onready var name_label: Label = $NameLabel


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func bind(power: ElementalPower) -> void:
	power.wheel_opened.connect(_on_opened.bind(power))
	power.wheel_closed.connect(func(): visible = false)
	power.wheel_hover_changed.connect(set_hover)
	power.unlocked_changed.connect(func(): _read_unlocked(power))
	_read_unlocked(power)


func _read_unlocked(power: ElementalPower) -> void:
	unlocked.clear()
	for element in power.unlocked:
		unlocked.append(element)
	queue_redraw()


func _on_opened(power: ElementalPower) -> void:
	_read_unlocked(power)
	set_hover(power.hover)
	visible = true


func set_hover(element: int) -> void:
	hover = element
	name_label.text = tr(Elements.name_key(element)) if element != Elements.NONE else tr("ELEMENT_NONE")
	queue_redraw()


func _slot_center(slot: int) -> Vector2:
	var c := (size / 2.0).floor()
	match slot:
		0: return c + Vector2(0, -DISTANCE)
		1: return c + Vector2(DISTANCE, 0)
		2: return c + Vector2(0, DISTANCE)
		_: return c + Vector2(-DISTANCE, 0)


func _draw() -> void:
	var dark := Color("1b1b24")
	var center := (size / 2.0).floor()
	# Centro = "sin elemento" (jugador normal).
	var none_hover := hover == Elements.NONE
	var half := 9 if none_hover else 7
	var none_rect := Rect2(center - Vector2(half, half), Vector2(half, half) * 2.0)
	draw_rect(none_rect, Color(0, 0, 0, 0.55))
	draw_rect(none_rect.grow(-1), Color.WHITE if none_hover else dark)
	draw_rect(none_rect.grow(-3), Elements.NEUTRAL)
	for slot in ElementalPower.WHEEL_SLOTS.size():
		var element: int = ElementalPower.WHEEL_SLOTS[slot]
		if element not in unlocked:
			continue
		var is_hover := element == hover
		var s := SLOT_SIZE + (6 if is_hover else 0)
		var rect := Rect2(_slot_center(slot) - Vector2(s, s) / 2.0, Vector2(s, s)).abs()
		rect.position = rect.position.floor()
		draw_rect(rect, Color(0, 0, 0, 0.55))
		draw_rect(rect.grow(-1), Color.WHITE if is_hover else dark)
		draw_rect(rect.grow(-3), Elements.primary(element))
		draw_rect(rect.grow(-9 if not is_hover else -11), Elements.secondary(element))
