extends Node
class_name WeaponGrantManager

signal weapon_granted(weapon_data: WeaponData)
signal weapon_grant_failed(reason: String)

@export var available_weapons: Array[WeaponData] = []

func _ready():
	# Инициализируем список доступного оружия
	initialize_available_weapons()

func initialize_available_weapons() -> void:
	if available_weapons.is_empty():
		# Автоматически создаем базовые оружия если список пуст
		available_weapons = [
			TestWeaponFactory.create_pistol(),
			TestWeaponFactory.create_shotgun(),
			TestWeaponFactory.create_rifle()
		]
	print("WeaponGrantManager initialized with ", available_weapons.size(), " weapons")

# Выдать случайное оружие игроку
func grant_random_weapon(player: Node) -> bool:
	if available_weapons.is_empty():
		weapon_grant_failed.emit("No weapons available")
		return false
	
	var random_weapon = available_weapons[randi() % available_weapons.size()]
	return grant_specific_weapon(player, random_weapon)

# Выдать конкретное оружие игроку
func grant_specific_weapon(player: Node, weapon_data: WeaponData) -> bool:
	if not player or not player.has_method("pickup_weapon"):
		weapon_grant_failed.emit("Player not valid")
		return false
	
	var success = player.pickup_weapon(weapon_data)
	if success:
		weapon_granted.emit(weapon_data)
		print("Weapon granted: ", weapon_data.weapon_name)
	else:
		weapon_grant_failed.emit("No free weapon slots")
	
	return success

# Выдать оружие по типу
func grant_weapon_by_type(player: Node, weapon_type: String) -> bool:
	var weapon_data = get_weapon_by_type(weapon_type)
	if weapon_data:
		return grant_specific_weapon(player, weapon_data)
	else:
		weapon_grant_failed.emit("Weapon type not found: " + weapon_type)
		return false

func get_weapon_by_type(weapon_type: String) -> WeaponData:
	for weapon in available_weapons:
		if weapon.weapon_id == weapon_type:
			return weapon
	return null

# Получить список доступного оружия (для UI)
func get_available_weapons() -> Array[WeaponData]:
	return available_weapons

# Добавить новое оружие в доступный список
func add_available_weapon(weapon_data: WeaponData) -> void:
	if not available_weapons.has(weapon_data):
		available_weapons.append(weapon_data)
		print("Added weapon to available list: ", weapon_data.weapon_name)
