extends Resource
class_name WeaponData

@export var weapon_id: String = ""
@export var weapon_name: String = ""
@export var description: String = ""
@export var damage: float = 10.0
@export var fire_rate: float = 1.0
@export var projectiles_per_shot: int = 1
@export var spread_angle: float = 0.0
@export var projectile_speed: float = 500.0
@export var auto_aim_range: float = 400.0
@export var projectile_scene: PackedScene
@export var weapon_type: String = "ranged"
@export var rarity: String = "common"

# Характеристики оружия (могут переопределять/дополнять характеристики игрока)
@export var crit_chance: float = 0.0      # Дополнительный шанс крита оружия
@export var crit_damage: float = 1.5      # Множитель крита оружия
