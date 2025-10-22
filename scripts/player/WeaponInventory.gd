extends Node
class_name WeaponInventory

signal weapon_added(slot_index: int, weapon_data: WeaponData)
signal weapon_removed(slot_index: int)
signal weapon_swapped(slot_from: int, slot_to: int)

@export var max_slots: int = 6

var weapons: Array = []  # Массив WeaponData для каждого слота
var weapon_nodes: Array = []  # Массив нод оружия для каждого слота
var weapon_slots: Node2D  # Ссылка на контейнер слотов оружия

func _ready():
	# Инициализируем пустые слоты
	weapons.resize(max_slots)
	weapon_nodes.resize(max_slots)
	
	for i in range(max_slots):
		weapons[i] = null
		weapon_nodes[i] = null
	
	# Получаем ссылку на WeaponSlots
	_initialize_weapon_slots()

# Инициализирует ссылку на контейнер слотов оружия
func _initialize_weapon_slots() -> void:
	var player = get_parent()
	if player:
		weapon_slots = player.get_node_or_null("WeaponSlots")
		if weapon_slots:
			print("WeaponSlots found: ", weapon_slots.name)
		else:
			print("WARNING: WeaponSlots node not found in player")
	else:
		print("ERROR: Player parent node is null")

# Добавить оружие в первый свободный слот
func add_weapon(weapon_data: WeaponData) -> bool:
	for i in range(max_slots):
		if weapons[i] == null:
			return equip_weapon(i, weapon_data)
	return false  # Все слоты заняты

# Экипировать оружие в конкретный слот
func equip_weapon(slot_index: int, weapon_data: WeaponData) -> bool:
	if slot_index < 0 or slot_index >= max_slots:
		return false  # ← если return здесь, то код ниже не выполнится
	
	# Проверяем, инициализированы ли weapon_slots
	if not weapon_slots:
		_initialize_weapon_slots()
		if not weapon_slots:
			print("ERROR: Cannot equip weapon - WeaponSlots not available")
			return false
	
	# Если слот уже занят, сначала удаляем старое оружие
	if weapons[slot_index] != null:
		unequip_weapon(slot_index)
	
	weapons[slot_index] = weapon_data
	
	# Создаем ноду оружия
	var weapon_scene = load("res://scenes/Weapon/WeaponBase.tscn")
	var weapon_node = weapon_scene.instantiate()
	weapon_nodes[slot_index] = weapon_node
	
	# Настраиваем оружие
	weapon_node.setup_from_data(weapon_data)
	weapon_node.slot_index = slot_index
	
	# Добавляем как дочерний элемент в соответствующий Marker2D
	var slot_name = "Slot" + str(slot_index)
	var slot_node = weapon_slots.get_node_or_null(slot_name)
	
	print("=== EQUIPING WEAPON ===")
	print("Slot: ", slot_index)
	print("Weapon: ", weapon_data.weapon_name)
	print("Slot node: ", slot_node)
	print("Weapon node: ", weapon_node)
	print("Weapon position: ", weapon_node.position)
	print("Weapon global position: ", weapon_node.global_position)
	
	if slot_node:
		slot_node.add_child(weapon_node)
		# Настраиваем позицию оружия относительно маркера
		weapon_node.position = Vector2.ZERO
		print("Weapon added to slot node: ", slot_name)
		print("Final weapon position: ", weapon_node.global_position)
	else:
		# Fallback - добавляем прямо к контейнеру слотов
		weapon_slots.add_child(weapon_node)
		print("WARNING: Slot node '", slot_name, "' not found, adding to WeaponSlots directly")
	
	weapon_added.emit(slot_index, weapon_data)
	return true

	if slot_node:
		slot_node.add_child(weapon_node)
		weapon_node.position = Vector2.ZERO
		print("Weapon added to slot node: ", slot_name)
		
		# ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ВИДИМОСТИ
		var sprite = weapon_node.get_node_or_null("Sprite2D")
		if sprite:
			print("Weapon sprite visibility check:")
			print("  - Visible: ", sprite.visible)
			print("  - Texture: ", sprite.texture)
			print("  - Global Position: ", weapon_node.global_position)
			print("  - Scale: ", sprite.scale)
			print("  - Modulate: ", sprite.modulate)
		
	else:
		# Fallback - добавляем прямо к контейнеру слотов
		weapon_slots.add_child(weapon_node)
		print("WARNING: Slot node '", slot_name, "' not found, adding to WeaponSlots directly")
	
	weapon_added.emit(slot_index, weapon_data)
	return true

# Снять оружие со слота
func unequip_weapon(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= max_slots:
		return
	
	if weapon_nodes[slot_index]:
		weapon_nodes[slot_index].queue_free()
		weapon_nodes[slot_index] = null
	
	weapons[slot_index] = null
	weapon_removed.emit(slot_index)

# Поменять оружие местами между слотами
func swap_weapons(slot_a: int, slot_b: int) -> void:
	if slot_a < 0 or slot_a >= max_slots or slot_b < 0 or slot_b >= max_slots:
		return
	
	var temp_weapon = weapons[slot_a]
	var temp_node = weapon_nodes[slot_a]
	
	weapons[slot_a] = weapons[slot_b]
	weapon_nodes[slot_a] = weapon_nodes[slot_b]
	
	weapons[slot_b] = temp_weapon
	weapon_nodes[slot_b] = temp_node
	
	# Обновляем индексы слотов в нодах оружия
	if weapon_nodes[slot_a]:
		weapon_nodes[slot_a].slot_index = slot_a
	if weapon_nodes[slot_b]:
		weapon_nodes[slot_b].slot_index = slot_b
	
	# Перемещаем ноды оружия в правильные слоты
	if weapon_slots:
		if weapon_nodes[slot_a]:
			var slot_node_a = weapon_slots.get_node_or_null("Slot" + str(slot_a))
			if slot_node_a and weapon_nodes[slot_a].get_parent() != slot_node_a:
				weapon_nodes[slot_a].get_parent().remove_child(weapon_nodes[slot_a])
				slot_node_a.add_child(weapon_nodes[slot_a])
				weapon_nodes[slot_a].position = Vector2.ZERO
		
		if weapon_nodes[slot_b]:
			var slot_node_b = weapon_slots.get_node_or_null("Slot" + str(slot_b))
			if slot_node_b and weapon_nodes[slot_b].get_parent() != slot_node_b:
				weapon_nodes[slot_b].get_parent().remove_child(weapon_nodes[slot_b])
				slot_node_b.add_child(weapon_nodes[slot_b])
				weapon_nodes[slot_b].position = Vector2.ZERO
	
	weapon_swapped.emit(slot_a, slot_b)

# Получить оружие в слоте
func get_weapon(slot_index: int) -> WeaponData:
	if slot_index < 0 or slot_index >= max_slots:
		return null
	return weapons[slot_index]

# Получить ноду оружия в слоте
func get_weapon_node(slot_index: int) -> Node:
	if slot_index < 0 or slot_index >= max_slots:
		return null
	return weapon_nodes[slot_index]

# Получить все экипированные оружия
func get_equipped_weapons() -> Array:
	var equipped = []
	for i in range(max_slots):
		if weapons[i] != null:
			equipped.append(weapons[i])
	return equipped

# Получить все ноды экипированных оружий
func get_equipped_weapon_nodes() -> Array:
	var equipped_nodes = []
	for i in range(max_slots):
		if weapon_nodes[i] != null:
			equipped_nodes.append(weapon_nodes[i])
	return equipped_nodes

# Проверить, есть ли свободные слоты
func has_free_slots() -> bool:
	for i in range(max_slots):
		if weapons[i] == null:
			return true
	return false

# Получить количество свободных слотов
func get_free_slot_count() -> int:
	var count = 0
	for i in range(max_slots):
		if weapons[i] == null:
			count += 1
	return count

# Получить первый свободный слот
func get_first_free_slot() -> int:
	for i in range(max_slots):
		if weapons[i] == null:
			return i
	return -1
