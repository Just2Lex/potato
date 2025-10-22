extends Node2D

@export var spawn_interval: float = 3.0
@export var max_enemies: int = 10
@export var enemy_scene: PackedScene

@export var enemy_health_multiplier: float = 1.0
@export var enemy_damage_multiplier: float = 1.0
@export var enemy_speed_multiplier: float = 1.0

var spawn_timer: Timer
var current_enemies: int = 0

func _ready():
	if not enemy_scene:
		enemy_scene = load("res://scenes/Enemy/TestEnemy.tscn")
	
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	# Откладываем начальный спавн врагов
	call_deferred("spawn_initial_enemies")

func spawn_initial_enemies():
	for i in range(2):
		spawn_enemy()

func _on_spawn_timer_timeout():
	if current_enemies < max_enemies:
		spawn_enemy()

func spawn_enemy():
	if not enemy_scene:
		return
	
	var enemy = enemy_scene.instantiate()
	if not enemy:
		return
	
	# Настраиваем характеристики врага - ПРАВИЛЬНЫЙ СПОСОБ
	_setup_enemy_stats(enemy)
	
	# Случайная позиция вокруг спавнера
	var spawn_distance = 200.0
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_distance
	
	# Безопасное добавление врага
	get_tree().current_scene.call_deferred("add_child", enemy)
	enemy.set_deferred("global_position", global_position + offset)
	
	current_enemies += 1
	
	# Подключаем сигнал смерти врага
	if enemy.has_signal("tree_exiting"):
		enemy.tree_exiting.connect(_on_enemy_died)
	else:
		# Альтернатива: подключаемся через метод
		enemy.tree_exiting.connect(func(): _on_enemy_died())

func _setup_enemy_stats(enemy: Node) -> void:
	# Способ 1: Проверяем наличие свойства через get()
	if enemy.get("test_enemy_health") != null:
		enemy.test_enemy_health *= enemy_health_multiplier
	
	if enemy.get("test_enemy_damage") != null:
		enemy.test_enemy_damage *= enemy_damage_multiplier
	
	if enemy.get("test_enemy_speed") != null:
		enemy.test_enemy_speed *= enemy_speed_multiplier
	
	# Способ 2: Используем set() для безопасности
	# Это более безопасный способ, который не вызовет ошибок
	_set_property_safe(enemy, "test_enemy_health", enemy.test_enemy_health * enemy_health_multiplier)
	_set_property_safe(enemy, "test_enemy_damage", enemy.test_enemy_damage * enemy_damage_multiplier)
	_set_property_safe(enemy, "test_enemy_speed", enemy.test_enemy_speed * enemy_speed_multiplier)

# Безопасная установка свойства
func _set_property_safe(object: Object, property: String, value) -> void:
	if object.get(property) != null:
		object.set(property, value)

func _on_enemy_died():
	current_enemies -= 1
	print("Enemy died. Current enemies: ", current_enemies)
