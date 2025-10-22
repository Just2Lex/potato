extends CharacterBody2D

@export var player_stats: PlayerStats

@onready var animated_sprite = $AnimatedSprite2D
@onready var state_machine = $StateMachine
@onready var weapon_inventory = $WeaponInventory

var last_direction: Vector2 = Vector2.DOWN
var input_vector: Vector2 = Vector2.ZERO
var health_regeneration_timer: Timer

func _ready():
	# Регистрируемся в GameManager
	GameManager.register_player(self)
	
	# Если характеристики не установлены, берем из GameManager
	if not player_stats:
		player_stats = GameManager.get_player_stats()
	
	# Создаем таймер для регенерации здоровья (каждые 5 секунд)
	health_regeneration_timer = Timer.new()
	add_child(health_regeneration_timer)
	health_regeneration_timer.wait_time = 5.0  # 5 секунд
	health_regeneration_timer.timeout.connect(_on_health_regeneration)
	health_regeneration_timer.start()
	
	add_to_group("player")
	
	# Инициализируем состояние
	state_machine.initialize(PlayerStates.PlayerState.IDLE)
	
	print("Player initialized with stats:")
	print_stats()

# Установить характеристики (вызывается из GameManager)
func set_player_stats(stats: PlayerStats) -> void:
	player_stats = stats
	print("Player stats set from GameManager")

func _physics_process(delta):
	handle_input()
	handle_movement(delta)
	
	# Автоматическая стрельба для всех экипированных оружий
	for weapon_node in weapon_inventory.get_equipped_weapon_nodes():
		if weapon_node and weapon_node.has_method("auto_aim"):
			weapon_node.auto_aim()
	
	# Обновляем состояние
	state_machine.update_state(input_vector, last_direction)

func handle_input() -> void:
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	input_vector = input_vector.normalized()
	
	# Сохраняем последнее направление для анимаций
	if input_vector != Vector2.ZERO:
		last_direction = input_vector
	
	# Отладочная информация по статам
	if Input.is_action_just_pressed("debug_stats"):
		print_stats()

func handle_movement(delta: float) -> void:
	if not player_stats:
		return
	
	var final_speed = player_stats.max_speed * player_stats.move_speed_multiplier
	var final_acceleration = player_stats.acceleration * player_stats.move_speed_multiplier
	var final_friction = player_stats.friction
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * final_speed, final_acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, final_friction * delta)
	
	move_and_slide()

# Функция для подбора оружия (будет вызываться из GameManager)
func pickup_weapon(weapon_data: WeaponData) -> bool:
	if weapon_inventory.has_free_slots():
		var success = weapon_inventory.add_weapon(weapon_data)
		if success:
			print("Player picked up weapon: ", weapon_data.weapon_name)
			return true
		else:
			print("Failed to add weapon to inventory")
			return false
	else:
		print("Player has no free weapon slots")
		return false

func _on_health_regeneration():
	if player_stats and player_stats.health_regeneration > 0:
		var old_health = player_stats.current_health
		player_stats.heal(player_stats.health_regeneration)
		if player_stats.current_health != old_health:
			print("Health regenerated: ", player_stats.current_health, "/", player_stats.max_health)

func take_damage(amount: float, attacker: Node = null) -> void:
	if not player_stats:
		return
	
	# Проверяем уклонение
	if randf() < player_stats.dodge_chance:
		print("Dodged attack!")
		# Тут можно добавить визуальный эффект уклонения
		return
	
	# Получаем фактический нанесенный урон (учитывает броню и щиты)
	var actual_damage = player_stats.take_damage(amount)
	
	# Если был нанесен урон, проверяем контратаку
	if actual_damage > 0 and attacker and randf() < player_stats.counter_chance:
		var counter_damage = actual_damage * player_stats.counter_damage
		# Наносим контратаку
		if attacker.has_method("take_damage"):
			attacker.take_damage(counter_damage)
		print("Counter attack for ", counter_damage, " damage!")
	
	print("Player took ", actual_damage, " damage (after armor and shields). Health: ", 
		  player_stats.current_health, "/", player_stats.max_health, " Shields: ", player_stats.current_shields)
	
	if player_stats.current_health <= 0:
		die()

func die() -> void:
	print("Player died")
	
	# Отключаем управление и физику
	set_physics_process(false)
	set_process(false)
	velocity = Vector2.ZERO
	
	# Скрываем спрайт или проигрываем простую анимацию
	animated_sprite.hide()
	
	# Уведомляем GameManager о смерти
	GameManager.on_player_died()

func apply_item_modifiers(item_data: ItemData) -> void:
	if not item_data or not item_data.modifiers:
		return
	
	# Применяем модификаторы из предмета
	for stat_name in item_data.modifiers:
		var value = item_data.modifiers[stat_name]
		apply_stat_modifier(stat_name, value)
	
	print("Item modifiers applied from: ", item_data.item_name)
	GameManager.update_player_stats()

func apply_stat_modifier(stat_name: String, value: float, modifier_type: StatModifier.ModifierType = StatModifier.ModifierType.ADDITIVE) -> void:
	if not player_stats:
		return
	
	var modifier = StatModifier.new(value, modifier_type, "item")
	
	match stat_name:
		# Movement
		"max_speed":
			player_stats.add_max_speed_modifier(modifier)
		"acceleration":
			player_stats.add_acceleration_modifier(modifier)
		"friction":
			player_stats.add_friction_modifier(modifier)
		
		# Attack
		"attack_power":
			player_stats.add_attack_power_modifier(modifier)
		"attack_speed":
			player_stats.add_attack_speed_modifier(modifier)
		"crit_chance":
			player_stats.add_crit_chance_modifier(modifier)
		"crit_damage":
			player_stats.add_crit_damage_modifier(modifier)
		"vampirism":
			player_stats.add_vampirism_modifier(modifier)
		
		# Defense
		"max_health":
			player_stats.add_max_health_modifier(modifier)
		"health_regeneration":
			player_stats.add_health_regeneration_modifier(modifier)
		"armor":
			player_stats.add_armor_modifier(modifier)
		"shield_efficiency":
			player_stats.add_shield_efficiency_modifier(modifier)
		"dodge_chance":
			player_stats.add_dodge_chance_modifier(modifier)
		"counter_chance":
			player_stats.add_counter_chance_modifier(modifier)
		"counter_damage":
			player_stats.add_counter_damage_modifier(modifier)
		
		# Utility
		"move_speed_multiplier":
			player_stats.add_move_speed_multiplier_modifier(modifier)
		"pickup_multiplier":
			player_stats.add_pickup_multiplier_modifier(modifier)
		"luck":
			player_stats.add_luck_modifier(modifier)
		_:
			print("Unknown stat: ", stat_name)

func print_stats() -> void:
	if player_stats:
		var stats = player_stats.get_stats_dict()
		print("=== PLAYER STATS ===")
		for stat_name in stats:
			print("  ", stat_name, ": ", stats[stat_name])
	else:
		print("Player stats not available")

# Методы для получения конкретных значений (для UI и других систем)
func get_current_health() -> float:
	return player_stats.current_health if player_stats else 0

func get_max_health() -> float:
	return player_stats.max_health if player_stats else 0

func get_health_percentage() -> float:
	return player_stats.get_health_percentage() if player_stats else 0

# Остальные методы остаются без изменений...
func play_animation(animation_name: String) -> void:
	if animated_sprite.sprite_frames.has_animation(animation_name):
		if animated_sprite.animation != animation_name:
			animated_sprite.play(animation_name)
	else:
		print("Animation not found: ", animation_name)
		if animated_sprite.animation != "idle_down":
			animated_sprite.play("idle_down")

func set_sprite_flip(direction: int) -> void:
	match direction:
		PlayerStates.Direction.LEFT:
			animated_sprite.flip_h = true
		PlayerStates.Direction.RIGHT:
			animated_sprite.flip_h = false
		_:
			animated_sprite.flip_h = false

func _exit_tree():
	# Очищаем оружие при удалении игрока
	for weapon_node in weapon_inventory.get_equipped_weapon_nodes():
		if weapon_node and weapon_node.has_method("unequip"):
			weapon_node.unequip()
