class_name ElementEnergy
extends Control
## Cuadrito con el color del elemento activo + barra de energía elemental.
## Todo se dibuja con rectángulos para que quede nítido en pixel art.

@export var bar_width: int = 40
@export var bar_height: int = 4
@export var chip_size: int = 7

var element: int = Elements.NONE
var ratio: float = 1.0
var _flash := 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(chip_size + 3 + bar_width + 2, chip_size)


func set_values(current: float, maximum: float) -> void:
	ratio = clampf(current / maxf(maximum, 0.001), 0.0, 1.0)
	queue_redraw()


func set_element(value: int) -> void:
	element = value
	queue_redraw()


## Parpadeo rojo corto cuando no alcanza la energía.
func flash_empty() -> void:
	_flash = 0.3
	queue_redraw()


func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash = maxf(_flash - delta, 0.0)
		queue_redraw()


func _draw() -> void:
	var dark := Color("1b1b24")
	# Cuadrito del elemento (borde + relleno primario + centro secundario)
	draw_rect(Rect2(0, 0, chip_size, chip_size), dark)
	draw_rect(Rect2(1, 1, chip_size - 2, chip_size - 2), Elements.primary(element))
	if element != Elements.NONE:
		draw_rect(Rect2(2, 2, chip_size - 4, chip_size - 4), Elements.secondary(element))

	# Barra
	var bx := chip_size + 3
	var by := (chip_size - bar_height - 2) / 2
	draw_rect(Rect2(bx, by, bar_width + 2, bar_height + 2), dark)
	var fill_w := int(round(bar_width * ratio))
	var color := Elements.primary(element)
	if _flash > 0.0 and int(_flash * 20.0) % 2 == 0:
		color = Color("e0382b")
	if fill_w > 0:
		draw_rect(Rect2(bx + 1, by + 1, fill_w, bar_height), color)
