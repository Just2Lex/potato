extends Node

func _ready():
	# Автоматическое создание врагов для тестирования
	call_deferred("setup_test_enemies")

func setup_test_enemies():
	# Создаем несколько врагов с разными характеристиками
	spawn_test_enemy(Vector2(200, 200), 30.0, 5.0, 60.0, "Weak Enemy")
	spawn_test_enemy(Vector2(400, 200), 80.0, 15.0, 100.0, "Strong Enemy")
	spawn_test_enemy(Vector2(300, 400), 50.0, 10.0, 80.0, "Normal Enemy")

func spawn_test_enemy(position: Vector2, health: float, damage: float, speed: float, name: String):
	var enemy_scene = load("res://scenes/Enemy/TestEnemy.tscn")
	var enemy = enemy_scene.instantiate()
	
	# Устанавливаем характеристики
	enemy.test_enemy_health = health
	enemy.test_enemy_damage = damage
	enemy.test_enemy_speed = speed
	
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = position
	enemy.name = name
	
	print("Spawned ", name, " with health: ", health, ", damage: ", damage, ", speed: ", speed)
