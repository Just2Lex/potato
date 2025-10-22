extends Node
class_name Constants

# Группы
const GROUP_PLAYER: String = "player"
const GROUP_ENEMIES: String = "enemies"
const GROUP_PROJECTILES: String = "projectiles"
const GROUP_ITEMS: String = "items"
const GROUP_WEAPONS: String = "weapons"

# Слои физики
enum PhysicsLayers {
	PLAYER = 1,
	ENEMIES = 2,
	PLAYER_PROJECTILES = 4,
	ENEMY_PROJECTILES = 8,
	ITEMS = 16,
	WEAPONS = 32
}

# Пути к сценам
const SCENE_PLAYER: String = "res://scenes/Player.tscn"
const SCENE_BASIC_ENEMY: String = "res://scenes/Enemy/TestEnemy.tscn"
const SCENE_BASIC_PROJECTILE: String = "res://scenes/Weapon/BasicProjectile.tscn"
const SCENE_WEAPON_BASE: String = "res://scenes/Weapon/WeaponBase.tscn"

# Максимальное количество слотов оружия
const MAX_WEAPON_SLOTS: int = 6

# Input Actions для выдачи оружия
const INPUT_GRANT_WEAPON_RANDOM: String = "grant_weapon_random"
const INPUT_GRANT_WEAPON_PISTOL: String = "grant_weapon_pistol"
const INPUT_GRANT_WEAPON_SHOTGUN: String = "grant_weapon_shotgun"
const INPUT_GRANT_WEAPON_RIFLE: String = "grant_weapon_rifle"
const INPUT_GRANT_WEAPON_ALL: String = "grant_weapon_all"
const INPUT_TOGGLE_DEBUG: String = "toggle_debug_info"
