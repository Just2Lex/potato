extends Resource
class_name PlayerStats

# Импортируем StatModifier
const StatModifier = preload("res://scripts/stats/StatModifier.gd")

# Движение
@export_group("Movement")
@export var base_max_speed: float = 300.0
@export var base_acceleration: float = 1500.0
@export var base_friction: float = 1200.0

# Атакующие характеристики
@export_group("Attack Stats")
@export var base_attack_power: float = 1.0           # Множитель урона оружия
@export var base_attack_speed: float = 1.0           # Множитель скорости атаки оружия
@export var base_crit_chance: float = 0.05           # Базовый шанс крита (может модифицироваться оружием)
@export var base_crit_damage: float = 1.5            # Базовый множитель крита (может модифицироваться оружием)
@export var base_vampirism: float = 0.0              # Процент вампиризма (0-1)

# Защитные характеристики
@export_group("Defense Stats")
@export var base_max_health: float = 100.0           # Максимальное здоровье
@export var base_health_regeneration: float = 0.0    # Регенерация здоровья в 5 секунд
@export var base_armor: float = 0.0                  # Броня (фиксированное уменьшение урона)
@export var base_shield_efficiency: float = 1.0      # Эффективность щитов
@export var base_dodge_chance: float = 0.0           # Шанс уклонения (0-1)
@export var base_counter_chance: float = 0.0         # Шанс контратаки (0-1)
@export var base_counter_damage: float = 1.0         # Сила контратаки (множитель к полученному урону)

# Разные характеристики
@export_group("Utility Stats")
@export var base_move_speed_multiplier: float = 1.0  # Множитель скорости передвижения
@export var base_pickup_multiplier: float = 1.0      # Множитель сбора
@export var base_luck: float = 1.0                   # Удача

# Текущее здоровье и щиты
var current_health: float = base_max_health
var current_shields: float = 0.0

# Модификаторы от предметов/баффов
var max_speed_modifiers: Array = []
var acceleration_modifiers: Array = []
var friction_modifiers: Array = []
var attack_power_modifiers: Array = []
var attack_speed_modifiers: Array = []
var crit_chance_modifiers: Array = []
var crit_damage_modifiers: Array = []
var vampirism_modifiers: Array = []
var max_health_modifiers: Array = []
var health_regeneration_modifiers: Array = []
var armor_modifiers: Array = []
var shield_efficiency_modifiers: Array = []
var dodge_chance_modifiers: Array = []
var counter_chance_modifiers: Array = []
var counter_damage_modifiers: Array = []
var move_speed_multiplier_modifiers: Array = []
var pickup_multiplier_modifiers: Array = []
var luck_modifiers: Array = []

# Финальные значения (база + модификаторы)
var max_speed: float:
	get: return base_max_speed * _calculate_multiplier(max_speed_modifiers)

var acceleration: float:
	get: return base_acceleration * _calculate_multiplier(acceleration_modifiers)

var friction: float:
	get: return base_friction * _calculate_multiplier(friction_modifiers)

var attack_power: float:
	get: return base_attack_power * _calculate_multiplier(attack_power_modifiers)

var attack_speed: float:
	get: return base_attack_speed * _calculate_multiplier(attack_speed_modifiers)

var crit_chance: float:
	get: return clamp(base_crit_chance + _calculate_additive(crit_chance_modifiers), 0.0, 1.0)

var crit_damage: float:
	get: return base_crit_damage * _calculate_multiplier(crit_damage_modifiers)

var vampirism: float:
	get: return clamp(base_vampirism + _calculate_additive(vampirism_modifiers), 0.0, 1.0)

var max_health: float:
	get: return base_max_health * _calculate_multiplier(max_health_modifiers)

var health_regeneration: float:
	get: return base_health_regeneration + _calculate_additive(health_regeneration_modifiers)

var armor: float:
	get: return base_armor + _calculate_additive(armor_modifiers)  # Фиксированное значение

var shield_efficiency: float:
	get: return base_shield_efficiency * _calculate_multiplier(shield_efficiency_modifiers)

var dodge_chance: float:
	get: return clamp(base_dodge_chance + _calculate_additive(dodge_chance_modifiers), 0.0, 1.0)

var counter_chance: float:
	get: return clamp(base_counter_chance + _calculate_additive(counter_chance_modifiers), 0.0, 1.0)

var counter_damage: float:
	get: return base_counter_damage * _calculate_multiplier(counter_damage_modifiers)

var move_speed_multiplier: float:
	get: return base_move_speed_multiplier * _calculate_multiplier(move_speed_multiplier_modifiers)

var pickup_multiplier: float:
	get: return base_pickup_multiplier * _calculate_multiplier(pickup_multiplier_modifiers)

var luck: float:
	get: return base_luck * _calculate_multiplier(luck_modifiers)

# Вспомогательные методы для расчетов
func _calculate_multiplier(modifiers: Array) -> float:
	var result = 1.0
	for modifier in modifiers:
		if modifier is StatModifier and modifier.type == StatModifier.ModifierType.MULTIPLICATIVE:
			result *= modifier.value
	return result

func _calculate_additive(modifiers: Array) -> float:
	var result = 0.0
	for modifier in modifiers:
		if modifier is StatModifier and modifier.type == StatModifier.ModifierType.ADDITIVE:
			result += modifier.value
	return result

# Инициализация текущего здоровья
func initialize_current_health() -> void:
	current_health = max_health
	current_shields = 0.0

# Методы для изменения здоровья и щитов
func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)

func take_damage(amount: float) -> float:
	# Сначала урон поглощается щитами
	var damage_to_shields = min(current_shields, amount)
	current_shields -= damage_to_shields
	var remaining_damage = amount - damage_to_shields
	
	# Затем урон наносится здоровью, уменьшенный на броню
	var damage_after_armor = max(0, remaining_damage - armor)
	current_health -= damage_after_armor
	
	# Возвращаем фактически нанесенный урон (для контратаки и т.д.)
	return damage_after_armor + damage_to_shields

func add_shields(amount: float) -> void:
	current_shields += amount * shield_efficiency

func get_health_percentage() -> float:
	return current_health / max_health if max_health > 0 else 0

func get_total_health() -> float:
	return current_health + current_shields

func get_max_total_health() -> float:
	return max_health  # Щиты могут быть сверх максимума

# Методы для добавления модификаторов
func add_max_speed_modifier(modifier: StatModifier) -> void:
	max_speed_modifiers.append(modifier)

func add_acceleration_modifier(modifier: StatModifier) -> void:
	acceleration_modifiers.append(modifier)

func add_friction_modifier(modifier: StatModifier) -> void:
	friction_modifiers.append(modifier)

func add_attack_power_modifier(modifier: StatModifier) -> void:
	attack_power_modifiers.append(modifier)

func add_attack_speed_modifier(modifier: StatModifier) -> void:
	attack_speed_modifiers.append(modifier)

func add_crit_chance_modifier(modifier: StatModifier) -> void:
	crit_chance_modifiers.append(modifier)

func add_crit_damage_modifier(modifier: StatModifier) -> void:
	crit_damage_modifiers.append(modifier)

func add_vampirism_modifier(modifier: StatModifier) -> void:
	vampirism_modifiers.append(modifier)

func add_max_health_modifier(modifier: StatModifier) -> void:
	max_health_modifiers.append(modifier)
	# При изменении максимального здоровья, пропорционально изменяем текущее
	var health_ratio = current_health / max_health
	current_health = max_health * health_ratio

func add_health_regeneration_modifier(modifier: StatModifier) -> void:
	health_regeneration_modifiers.append(modifier)

func add_armor_modifier(modifier: StatModifier) -> void:
	armor_modifiers.append(modifier)

func add_shield_efficiency_modifier(modifier: StatModifier) -> void:
	shield_efficiency_modifiers.append(modifier)

func add_dodge_chance_modifier(modifier: StatModifier) -> void:
	dodge_chance_modifiers.append(modifier)

func add_counter_chance_modifier(modifier: StatModifier) -> void:
	counter_chance_modifiers.append(modifier)

func add_counter_damage_modifier(modifier: StatModifier) -> void:
	counter_damage_modifiers.append(modifier)

func add_move_speed_multiplier_modifier(modifier: StatModifier) -> void:
	move_speed_multiplier_modifiers.append(modifier)

func add_pickup_multiplier_modifier(modifier: StatModifier) -> void:
	pickup_multiplier_modifiers.append(modifier)

func add_luck_modifier(modifier: StatModifier) -> void:
	luck_modifiers.append(modifier)

# Метод для получения всех статов в виде словаря
func get_stats_dict() -> Dictionary:
	return {
		# Movement
		"max_speed": max_speed,
		"acceleration": acceleration,
		"friction": friction,
		
		# Attack
		"attack_power": attack_power,
		"attack_speed": attack_speed,
		"crit_chance": crit_chance,
		"crit_damage": crit_damage,
		"vampirism": vampirism,
		
		# Defense
		"max_health": max_health,
		"current_health": current_health,
		"current_shields": current_shields,
		"health_regeneration": health_regeneration,
		"armor": armor,
		"shield_efficiency": shield_efficiency,
		"dodge_chance": dodge_chance,
		"counter_chance": counter_chance,
		"counter_damage": counter_damage,
		
		# Utility
		"move_speed_multiplier": move_speed_multiplier,
		"pickup_multiplier": pickup_multiplier,
		"luck": luck
	}
