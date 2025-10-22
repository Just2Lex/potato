extends Resource
class_name StatModifier

enum ModifierType {
	ADDITIVE,      # Простое сложение
	MULTIPLICATIVE # Умножение
}

@export var value: float = 0.0
@export var type: ModifierType = ModifierType.ADDITIVE
@export var source: String = ""  # Откуда пришел модификатор (предмет, перк и т.д.)

func _init(p_value: float = 0.0, p_type: ModifierType = ModifierType.ADDITIVE, p_source: String = ""):
	value = p_value
	type = p_type
	source = p_source
