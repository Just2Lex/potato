extends Node

signal weapon_granted(weapon_data: WeaponData)
signal weapon_grant_failed(reason: String)
signal player_stats_updated(stats: Dictionary)
signal player_died(wave: int, enemies_killed: int)

var weapon_grant_manager: WeaponGrantManager
var player_stats: PlayerStats
var current_player: Node
var current_wave: int = 0
var enemies_killed: int = 0
var total_enemies_killed: int = 0
var is_game_over: bool = false

func _ready():
	weapon_grant_manager = WeaponGrantManager.new()
	add_child(weapon_grant_manager)
	
	weapon_grant_manager.weapon_granted.connect(_on_weapon_granted)
	weapon_grant_manager.weapon_grant_failed.connect(_on_weapon_grant_failed)
	
	initialize_player_stats()

func initialize_player_stats() -> void:
	if not player_stats:
		player_stats = load("res://resources/player/DefaultPlayerStats.tres")
		if not player_stats:
			player_stats = PlayerStats.new()
			print("Created new PlayerStats instance")
		else:
			print("Loaded default PlayerStats resource")
	
	player_stats.initialize_current_health()

# Выдать случайное оружие текущему игроку
func grant_random_weapon_to_player() -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("pickup_weapon"):
		return player.pickup_weapon(weapon_grant_manager.get_random_weapon())
	else:
		print("GameManager: Player not found or missing pickup_weapon method")
		return false

# Выдать конкретное оружие текущему игроку
func grant_weapon_to_player(weapon_data: WeaponData) -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("pickup_weapon"):
		return player.pickup_weapon(weapon_data)
	else:
		print("GameManager: Player not found or missing pickup_weapon method")
		return false

# Выдать оружие по типу текущему игроку
func grant_weapon_by_type_to_player(weapon_type: String) -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("pickup_weapon"):
		var weapon_data = weapon_grant_manager.get_weapon_by_type(weapon_type)
		if weapon_data:
			return player.pickup_weapon(weapon_data)
		else:
			print("GameManager: Weapon type not found: ", weapon_type)
			return false
	else:
		print("GameManager: Player not found or missing pickup_weapon method")
		return false

func _on_weapon_granted(weapon_data: WeaponData):
	weapon_granted.emit(weapon_data)
	print("GameManager: Weapon granted - ", weapon_data.weapon_name)

func _on_weapon_grant_failed(reason: String):
	weapon_grant_failed.emit(reason)
	print("GameManager: Weapon grant failed - ", reason)

# Сохраняем ссылку на игрока
func register_player(player: Node) -> void:
	current_player = player
	if player.has_method("set_player_stats"):
		player.set_player_stats(player_stats)
	
	print("Player registered in GameManager")


# Обновляем метод on_player_died
func on_player_died():
	if is_game_over:
		return
	
	is_game_over = true
	player_died.emit(current_wave, total_enemies_killed)
	
	# Показываем экран смерти
	show_death_screen(current_wave, total_enemies_killed)

func show_death_screen(wave: int, enemies_killed: int):
	var death_screen_scene = load("res://scenes/ui/DeathScreen.tscn")
	var death_screen = death_screen_scene.instantiate()
	
	# Добавляем экран смерти к корневой сцене
	get_tree().root.add_child(death_screen)
	death_screen.show_death_screen(wave, enemies_killed)
	death_screen.restart_pressed.connect(_on_restart_pressed)

func _on_restart_pressed():
	# Перезагружаем игру
	is_game_over = false
	current_wave = 0
	enemies_killed = 0
	
	# Перезагружаем сцену
	get_tree().paused = false
	get_tree().reload_current_scene()

# Для отслеживания волн и убийств
func set_current_wave(wave: int):
	current_wave = wave

func increment_enemies_killed():
	total_enemies_killed += 1
	print("Total enemies killed: ", total_enemies_killed)

# Получить текущие характеристики
func get_player_stats() -> PlayerStats:
	return player_stats

# Обновить характеристики и оповестить всех
func update_player_stats() -> void:
	if player_stats:
		player_stats_updated.emit(player_stats.get_stats_dict())

# Сохранение прогресса (для будущего использования)
func save_game() -> void:
	# Здесь будет логика сохранения характеристик
	pass

# Загрузка прогресса (для будущего использования)
func load_game() -> void:
	# Здесь будет логика загрузки характеристик
	pass
