extends Node2D
class_name WeaponBase

@export var weapon_data: WeaponData
var fire_timer: Timer
var can_fire: bool = true
var is_firing: bool = false
var current_target: Node2D = null
var slot_index: int = -1

var sprite: Sprite2D
var muzzle: Marker2D

# Характеристики оружия (могут отличаться от базовых)
var weapon_crit_chance: float = 0.0
var weapon_crit_damage: float = 1.5

func _ready():
	# Получаем ссылки на узлы
	sprite = get_node_or_null("Sprite2D")
	muzzle = get_node_or_null("Muzzle")
	
	# Если данные оружия установлены через инспектор, настраиваем из них
	if weapon_data:
		setup_from_data(weapon_data)
	else:
		# Инициализация по умолчанию
		initialize_defaults()

func setup_from_data(data: WeaponData) -> void:
	weapon_data = data
	
	# Устанавливаем характеристики оружия
	if data.has("crit_chance"):
		weapon_crit_chance = data.crit_chance
	if data.has("crit_damage"):
		weapon_crit_damage = data.crit_damage
	
	# Инициализируем таймер если еще не инициализирован
	if not fire_timer:
		fire_timer = Timer.new()
		add_child(fire_timer)
		fire_timer.one_shot = true
		fire_timer.timeout.connect(_on_fire_timeout)
	
	# Получаем игрока для расчета скорости атаки
	var player = get_tree().get_first_node_in_group("player")
	if player and player.player_stats:
		fire_timer.wait_time = 1.0 / (data.fire_rate * player.player_stats.attack_speed)
	else:
		fire_timer.wait_time = 1.0 / data.fire_rate
	
	# Создаем пул для пуль
	if data.projectile_scene:
		ObjectPool.create_pool(data.projectile_scene, 20)

func initialize_defaults() -> void:
	# Создаем таймер для скорострельности
	fire_timer = Timer.new()
	add_child(fire_timer)
	fire_timer.wait_time = 1.0 / 3.0
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_timeout)
	
	print("WeaponBase initialized with default values")

func start_firing() -> void:
	is_firing = true
	_try_fire()

func stop_firing() -> void:
	is_firing = false

func _try_fire() -> void:
	if can_fire and is_firing and weapon_data:
		fire()
		can_fire = false
		fire_timer.start()

func auto_aim() -> void:
	if not weapon_data or not weapon_data.auto_aim_range > 0:
		return
	
	# Ищем ближайшего врага
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy: Node2D = null
	var closest_distance: float = weapon_data.auto_aim_range
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	if closest_enemy:
		current_target = closest_enemy
		# Поворачиваем оружие к цели
		look_at(closest_enemy.global_position)
		
		# Обновляем флип спрайта на основе направления
		update_sprite_flip()
		
		# Автоматически стреляем если есть цель
		if not is_firing:
			start_firing()
	else:
		# Нет целей - прекращаем стрельбу
		current_target = null
		if is_firing:
			stop_firing()

func update_sprite_flip() -> void:
	if not sprite:
		return
	
	# Определяем направление к цели
	var target_direction = (current_target.global_position - global_position).normalized()
	
	# Флипаем спрайт если цель слева
	sprite.flip_v = target_direction.x < 0
	
	# Если нужно также корректировать позицию muzzle при флипе
	if muzzle:
		if target_direction.x < 0:
			# Цель слева - корректируем позицию muzzle если нужно
			muzzle.position.x = abs(muzzle.position.x) * -1
		else:
			# Цель справа - нормальная позиция muzzle
			muzzle.position.x = abs(muzzle.position.x)

func fire() -> void:
	if not current_target or not weapon_data:
		return
	
	# Получаем игрока для доступа к его характеристикам
	var player = get_tree().get_first_node_in_group("player")
	if not player or not player.player_stats:
		return
	
	print("Firing weapon: ", weapon_data.weapon_name)
	
	for i in range(weapon_data.projectiles_per_shot):
		var projectile = ObjectPool.get_instance(weapon_data.projectile_scene)
		
		# Получаем сцену игры для добавления пули
		var game_scene = get_tree().current_scene
		game_scene.add_child(projectile)
		
		# Позиционируем пулю в точке выстрела
		if muzzle:
			projectile.global_position = muzzle.global_position
		else:
			projectile.global_position = global_position
		
		# Расчет направления с учетом спрея
		var base_direction = (current_target.global_position - global_position).normalized()
		var angle_variation = randf_range(-weapon_data.spread_angle, weapon_data.spread_angle)
		var final_direction = base_direction.rotated(angle_variation)
		
		# Рассчитываем урон с учетом характеристик игрока
		var base_damage = weapon_data.damage
		var final_damage = base_damage * player.player_stats.attack_power
		
		# Проверяем крит (объединяем шанс крита игрока и оружия)
		var is_crit = false
		var total_crit_chance = weapon_crit_chance + player.player_stats.crit_chance
		if randf() < total_crit_chance:
			is_crit = true
			final_damage *= player.player_stats.crit_damage * weapon_crit_damage
			print("Critical hit! Damage: ", final_damage)
		
		# Настраиваем пулю
		projectile.setup(final_damage, final_direction, weapon_data.projectile_speed, is_crit)
		
		# Применяем вампиризм (единый для всех оружий)
		if player.player_stats.vampirism > 0:
			var heal_amount = final_damage * player.player_stats.vampirism
			player.player_stats.heal(heal_amount)
			print("Vampirism healed: ", heal_amount)

func _on_fire_timeout():
	can_fire = true
	if is_firing:
		_try_fire()

func equip() -> void:
	set_process(true)
	set_physics_process(true)
	visible = true
	print("Weapon equipped: ", weapon_data.weapon_name if weapon_data else "Unknown")

func unequip() -> void:
	set_process(false)
	set_physics_process(false)
	stop_firing()
	visible = false
