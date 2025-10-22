extends Node
class_name TestWeaponFactory

# Фабрика для создания тестового оружия
static func create_pistol() -> WeaponData:
	var pistol_data = WeaponData.new()
	pistol_data.weapon_id = "pistol"
	pistol_data.weapon_name = "Pistol"
	pistol_data.description = "Basic pistol with moderate damage"
	pistol_data.damage = 15.0
	pistol_data.fire_rate = 1.0
	pistol_data.projectiles_per_shot = 1
	pistol_data.spread_angle = 0.05
	pistol_data.projectile_speed = 600.0
	pistol_data.auto_aim_range = 500.0
	pistol_data.weapon_type = "ranged"
	pistol_data.rarity = "common"
	
	# Указываем сцену пистолета вместо базовой
	pistol_data.projectile_scene = load("res://scenes/Weapon/BasicProjectile.tscn")
	# Если создали отдельную сцену пистолета, можно указать её здесь:
	# pistol_data.weapon_scene = load("res://scenes/Weapon/Pistol.tscn")
	
	return pistol_data

static func create_shotgun() -> WeaponData:
	var shotgun_data = WeaponData.new()
	shotgun_data.weapon_id = "shotgun"
	shotgun_data.weapon_name = "Shotgun"
	shotgun_data.description = "Fires multiple projectiles in a spread"
	shotgun_data.damage = 8.0
	shotgun_data.fire_rate = 0.7  # Медленнее чем пистолет
	shotgun_data.projectiles_per_shot = 5
	shotgun_data.spread_angle = 0.3  # Большой разброс
	shotgun_data.projectile_speed = 500.0
	shotgun_data.auto_aim_range = 300.0  # Ближняя дистанция
	shotgun_data.weapon_type = "ranged"
	shotgun_data.rarity = "uncommon"
	shotgun_data.projectile_scene = load("res://scenes/Weapon/BasicProjectile.tscn")
	
	return shotgun_data

static func create_rifle() -> WeaponData:
	var rifle_data = WeaponData.new()
	rifle_data.weapon_id = "rifle"
	rifle_data.weapon_name = "Assault Rifle"
	rifle_data.description = "Rapid-fire weapon with good accuracy"
	rifle_data.damage = 10.0
	rifle_data.fire_rate = 4.0  # 4 выстрела в секунду
	rifle_data.projectiles_per_shot = 1
	rifle_data.spread_angle = 0.08
	rifle_data.projectile_speed = 700.0
	rifle_data.auto_aim_range = 600.0
	rifle_data.weapon_type = "ranged"
	rifle_data.rarity = "uncommon"
	rifle_data.projectile_scene = load("res://scenes/Weapon/BasicProjectile.tscn")
	
	return rifle_data

# Получить случайное тестовое оружие
static func get_random_weapon() -> WeaponData:
	var weapons = [create_pistol(), create_shotgun(), create_rifle()]
	return weapons[randi() % weapons.size()]
