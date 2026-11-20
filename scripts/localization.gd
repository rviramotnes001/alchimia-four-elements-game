extends Node
## Idioma del juego. Por defecto SIEMPRE inglés (no usa el idioma del sistema).
## Los textos viven en res://translations/texts.csv (columnas: keys, en, es).
## En los nodos de texto se escribe la CLAVE (ej. HUD_LIVES) y Godot la traduce solo.
## Desde código: tr("HUD_LIVES").
## F1 cambia de idioma mientras desarrollamos; luego irá en el menú de opciones.

signal language_changed(language: String)

const SUPPORTED: Array[String] = ["en", "es"]
const DEFAULT_LANGUAGE := "en"
const SETTINGS_PATH := "user://settings.cfg"

var language: String = DEFAULT_LANGUAGE


func _ready() -> void:
	var config := ConfigFile.new()
	var saved := DEFAULT_LANGUAGE
	if config.load(SETTINGS_PATH) == OK:
		saved = str(config.get_value("general", "language", DEFAULT_LANGUAGE))
	set_language(saved, false)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		toggle_language()


func set_language(new_language: String, save: bool = true) -> void:
	if new_language not in SUPPORTED:
		new_language = DEFAULT_LANGUAGE
	language = new_language
	TranslationServer.set_locale(language)
	if save:
		var config := ConfigFile.new()
		config.load(SETTINGS_PATH)
		config.set_value("general", "language", language)
		config.save(SETTINGS_PATH)
	language_changed.emit(language)


func toggle_language() -> void:
	var index := SUPPORTED.find(language)
	set_language(SUPPORTED[(index + 1) % SUPPORTED.size()])
