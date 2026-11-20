class_name ElementalPower
extends Node
## Estructura del poder elemental (hijo del jugador):
## - elementos desbloqueados y elemento activo,
## - barra de energía que se recarga sola (más rápido al golpear),
## - rueda de elementos (Q mantener / LB) y cambio rápido (Q toque, teclas 1-4),
## - tecla de poder (K / B) que gasta energía. El efecto de cada poder se conecta después
##   escuchando la señal power_used.

signal energy_changed(current: float, maximum: float)
signal element_changed(element: int)
signal unlocked_changed
signal wheel_opened
signal wheel_closed
signal wheel_hover_changed(element: int)
signal power_used(element: int)
signal power_failed

@export_group("Energía")
@export var max_energy: float = 100.0
@export var regen_per_second: float = 14.0
## Segundos sin recargar después de gastar energía.
@export var regen_delay: float = 0.8
@export var power_cost: float = 25.0
## Energía que se gana al conectar un golpe.
@export var energy_on_hit: float = 6.0

@export_group("Armas elementales")
## Energía por golpe de espada / por flecha cuando hay un elemento activo.
@export var weapon_cost_sword: float = 3.0
@export var weapon_cost_arrow: float = 5.0

@export_group("Poderes de Agua")
## TEMPORAL para pruebas. En el juego: el Chorro se obtiene en el Altar de la Chispa;
## Respiración acuática y Riego, al vencer al Gólem.
@export var water_jet: bool = true
@export var water_breathing: bool = true
@export var irrigation: bool = true
@export var jet_cost: float = 25.0
@export var irrigation_cost: float = 20.0

@export_group("Rueda")
## Segundos manteniendo Q para abrir la rueda (menos que eso = cambio rápido).
@export var hold_time: float = 0.2
@export var stick_deadzone: float = 0.5

@export_group("Elementos")
## TEMPORAL para pruebas: luego empieza vacío y se desbloquea en el juego.
@export var unlocked: Array[Elements.Type] = [
	Elements.Type.WATER, Elements.Type.EARTH, Elements.Type.FIRE, Elements.Type.AIR,
]

## Posición de cada elemento en la rueda (arriba, derecha, abajo, izquierda).
const WHEEL_SLOTS: Array[int] = [
	Elements.Type.WATER, Elements.Type.EARTH, Elements.Type.FIRE, Elements.Type.AIR,
]

var energy: float = 0.0
var current: int = Elements.NONE
var hover: int = Elements.NONE
var wheel_is_open := false

var _regen_cd := 0.0
var _hold := 0.0
var _holding := false
var _moved := false
var _mouse_start := Vector2.ZERO

@onready var player: Player = get_parent() as Player


func _ready() -> void:
	energy = max_energy
	if not unlocked.is_empty():
		current = unlocked[0]
	# Las señales se emiten al terminar de armar la escena para que el HUD ya esté conectado.
	_emit_state.call_deferred()


func _emit_state() -> void:
	energy_changed.emit(energy, max_energy)
	element_changed.emit(current)
	unlocked_changed.emit()


func _process(delta: float) -> void:
	_update_regen(delta)
	_update_quick_select()
	_update_wheel(delta)
	if Input.is_action_just_pressed("power"):
		use_power()


# ------------------------------------------------------------------ Desbloqueo

func is_unlocked(element: int) -> bool:
	return element in unlocked


func unlock(element: Elements.Type) -> void:
	if element in unlocked:
		return
	unlocked.append(element)
	if current == Elements.NONE:
		select(element)
	unlocked_changed.emit()


func select(element: int) -> void:
	if element != Elements.NONE and not is_unlocked(element):
		return
	if element == current:
		return
	current = element
	element_changed.emit(current)


# ---------------------------------------------------------------------- Energía

func _update_regen(delta: float) -> void:
	_regen_cd = maxf(_regen_cd - delta, 0.0)
	if _regen_cd > 0.0 or energy >= max_energy:
		return
	energy = minf(energy + regen_per_second * delta, max_energy)
	energy_changed.emit(energy, max_energy)


func add_energy(amount: float) -> void:
	if amount <= 0.0 or energy >= max_energy:
		return
	energy = minf(energy + amount, max_energy)
	energy_changed.emit(energy, max_energy)


func spend_energy(amount: float) -> bool:
	if energy < amount:
		return false
	energy -= amount
	_regen_cd = regen_delay
	energy_changed.emit(energy, max_energy)
	return true


## Los poderes automáticos de Agua solo funcionan con el Agua seleccionada
## (con "sin elemento" Erek es un jugador normal).
func water_breathing_active() -> bool:
	return water_breathing and current == Elements.Type.WATER


func irrigation_active() -> bool:
	return irrigation and current == Elements.Type.WATER


## Elementos que se aplican a las armas: la espada y las flechas toman su color, gastan
## energía y activan lo que reacciona a ese elemento (antorchas, interruptores...).
## El efecto propio de cada uno en combate (Agua empuja; los demás) se agrega con sus zonas.
const WEAPON_ELEMENTS: Array[int] = [
	Elements.Type.WATER, Elements.Type.EARTH, Elements.Type.FIRE, Elements.Type.AIR,
]


## Pide energía para un golpe/flecha elemental. Devuelve el elemento que se aplica,
## o Elements.NONE (golpe normal) si no hay elemento, no hay energía o aún no existe.
func try_weapon_element(cost: float) -> int:
	if current not in WEAPON_ELEMENTS or energy < cost:
		return Elements.NONE
	spend_energy(cost)
	return current


## Llamar al conectar un golpe (la recarga es más rápida golpeando).
func on_hit_landed() -> void:
	add_energy(energy_on_hit)


# ------------------------------------------------------------------------ Poder

func use_power() -> void:
	if current == Elements.NONE or player == null or player.state != Player.State.NORMAL:
		return
	if wheel_is_open:
		return
	var cost := power_cost
	if current == Elements.Type.WATER:
		if not water_jet:
			return
		cost = jet_cost
	if not spend_energy(cost):
		power_failed.emit()
		return
	power_used.emit(current)


# ------------------------------------------------------------ Cambio de elemento

func _update_quick_select() -> void:
	if Input.is_action_just_pressed("element_0"):
		select(Elements.NONE)
	for i in 4:
		if Input.is_action_just_pressed("element_%d" % (i + 1)):
			select(WHEEL_SLOTS[i])


func _update_wheel(delta: float) -> void:
	if Input.is_action_just_pressed("element_wheel"):
		_holding = true
		_hold = 0.0
		_mouse_start = get_viewport().get_mouse_position()
	if _holding and Input.is_action_pressed("element_wheel"):
		_hold += delta
		if not wheel_is_open and _hold >= hold_time and not unlocked.is_empty():
			_open_wheel()
		if wheel_is_open:
			_update_hover()
	if _holding and not Input.is_action_pressed("element_wheel"):
		_holding = false
		if wheel_is_open:
			_close_wheel()
		else:
			_cycle_next()


func _open_wheel() -> void:
	_moved = false
	wheel_is_open = true
	hover = current
	wheel_opened.emit()
	wheel_hover_changed.emit(hover)


func _close_wheel() -> void:
	wheel_is_open = false
	if hover != Elements.NONE:
		select(hover)
	wheel_closed.emit()


## Elige con el stick derecho (mando) o moviendo el ratón desde donde estaba al abrir.
func _update_hover() -> void:
	var dir := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	if dir.length() < stick_deadzone:
		var mouse_delta := get_viewport().get_mouse_position() - _mouse_start
		dir = mouse_delta if mouse_delta.length() > 12.0 else Vector2.ZERO
	if dir == Vector2.ZERO:
		# Volver al centro después de haber elegido algo = "sin elemento".
		if _moved and hover != Elements.NONE:
			hover = Elements.NONE
			wheel_hover_changed.emit(hover)
		return
	_moved = true
	var slot: int
	if absf(dir.x) > absf(dir.y):
		slot = 1 if dir.x > 0.0 else 3
	else:
		slot = 2 if dir.y > 0.0 else 0
	var element := WHEEL_SLOTS[slot]
	if is_unlocked(element) and element != hover:
		hover = element
		wheel_hover_changed.emit(hover)


## Un toque de Q: pasa al siguiente elemento y, después del último, a "sin elemento" (normal).
func _cycle_next() -> void:
	if unlocked.is_empty():
		return
	var order: Array[int] = [Elements.NONE]
	for element in WHEEL_SLOTS:
		if is_unlocked(element):
			order.append(element)
	var idx := order.find(current)
	select(order[(idx + 1) % order.size()])
