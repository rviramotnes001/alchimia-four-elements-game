class_name Elements
extends RefCounted
## Datos fijos de los 4 elementos (colores del GDD, claves de traducción).

enum Type { WATER, EARTH, FIRE, AIR }

const NONE := -1

const NAME_KEYS := {
	Type.WATER: "ELEMENT_WATER",
	Type.EARTH: "ELEMENT_EARTH",
	Type.FIRE: "ELEMENT_FIRE",
	Type.AIR: "ELEMENT_AIR",
}

## Color principal y secundario de cada elemento (GDD, "Identidad visual").
const PRIMARY := {
	Type.WATER: Color("3ed6c8"),
	Type.EARTH: Color("d9772b"),
	Type.FIRE: Color("e0382b"),
	Type.AIR: Color("2a9d9d"),
}
const SECONDARY := {
	Type.WATER: Color("2f6fd8"),
	Type.EARTH: Color("a8325e"),
	Type.FIRE: Color("f5c63a"),
	Type.AIR: Color("f2f7f7"),
}

const NEUTRAL := Color("8c8c8c")


static func primary(element: int) -> Color:
	return PRIMARY.get(element, NEUTRAL)


static func secondary(element: int) -> Color:
	return SECONDARY.get(element, NEUTRAL)


static func name_key(element: int) -> String:
	return NAME_KEYS.get(element, "")
