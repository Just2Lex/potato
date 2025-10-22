extends Node2D

func _ready():
	print("Game scene loaded")
	# Инициализируем пулы
	_init_pools()

func _init_pools() -> void:
	# Создаем пулы для часто используемых объектов
	var projectile_scene = load("res://scenes/Weapon/BasicProjectile.tscn")
	ObjectPool.create_pool(projectile_scene, 50)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
