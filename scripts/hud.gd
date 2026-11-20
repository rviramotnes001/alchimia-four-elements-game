class_name Hud
extends CanvasLayer
## HUD del juego (se coloca en cada nivel como instancia de res://scenes/hud.tscn).
## Izquierda: arma activa, corazones de vida (medios corazones) y ranuras de objetos.
## Derecha: monedas y cristales (esencias).

const HEART_FULL := preload("res://art/UI/Health/Full_Heart.png")
const HEART_HALF := preload("res://art/UI/Health/Half_Heart.png")
const HEART_EMPTY := preload("res://art/UI/Health/No_Heart.png")

const ICON_SWORD := preload("res://art/Player/Weapons/sword.png")
const ICON_BOW := preload("res://art/Player/Weapons/bow.png")

@onready var hearts: HBoxContainer = $LeftHud/Hearts
@onready var element_energy: ElementEnergy = $LeftHud/ElementEnergy
@onready var element_wheel: ElementWheel = $ElementWheel
@onready var weapon_icon: TextureRect = $LeftHud/WeaponIcon
@onready var coins_label: Label = $RightHud/Rows/CoinRow/CoinLabel
@onready var essences_label: Label = $RightHud/Rows/CrystalRow/CrystalLabel


func _ready() -> void:
	set_coins(0)
	set_essences(0)
	_bind_player.call_deferred()


func _bind_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("Hud: no se encontró al jugador (grupo 'player').")
		return
	player.health_changed.connect(_on_health_changed)
	player.weapon_changed.connect(_on_weapon_changed)
	player.coins_changed.connect(set_coins)
	player.essences_changed.connect(set_essences)
	set_coins(player.coins)
	set_essences(player.essences_total())
	var power: ElementalPower = player.elemental
	power.energy_changed.connect(element_energy.set_values)
	power.element_changed.connect(element_energy.set_element)
	power.power_failed.connect(element_energy.flash_empty)
	element_wheel.bind(power)
	# Sincroniza el estado actual (las señales iniciales pudieron salir antes de conectar).
	element_energy.set_values(power.energy, power.max_energy)
	element_energy.set_element(power.current)
	_on_health_changed(player.health, player.max_health)
	_on_weapon_changed(player.weapon)


func set_coins(amount: int) -> void:
	coins_label.text = str(amount)


func set_essences(amount: int) -> void:
	essences_label.text = str(amount)


## Cambia el icono del arma activa (espada, arco...).
func set_weapon_icon(texture: Texture2D) -> void:
	weapon_icon.texture = texture


func _on_weapon_changed(weapon: int) -> void:
	set_weapon_icon(ICON_BOW if weapon == Player.Weapon.BOW else ICON_SWORD)


func _on_health_changed(current: int, maximum: int) -> void:
	var count := ceili(maximum / 2.0)
	while hearts.get_child_count() < count:
		var heart := TextureRect.new()
		heart.stretch_mode = TextureRect.STRETCH_KEEP
		hearts.add_child(heart)
	while hearts.get_child_count() > count:
		hearts.get_child(hearts.get_child_count() - 1).queue_free()

	for i in count:
		var heart := hearts.get_child(i) as TextureRect
		var remaining := current - i * 2
		if remaining >= 2:
			heart.texture = HEART_FULL
		elif remaining == 1:
			heart.texture = HEART_HALF
		else:
			heart.texture = HEART_EMPTY
