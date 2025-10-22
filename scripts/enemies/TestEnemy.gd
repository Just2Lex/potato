extends EnemyBase

@export var test_enemy_health: float = 50.0
@export var test_enemy_damage: float = 10.0
@export var test_enemy_speed: float = 80.0

func initialize_enemy() -> void:
	# Устанавливаем характеристики для тестового врага
	max_health = test_enemy_health
	health = test_enemy_health
	move_speed = test_enemy_speed
	damage = test_enemy_damage
	
	print("Test Enemy spawned with health: ", health, "/", max_health)

func take_damage(amount: float, is_critical: bool = false) -> void:
	health -= amount
	
	var critical_text = " (CRITICAL!)" if is_critical else ""
	print("Test Enemy took ", amount, " damage", critical_text, ". Health: ", health, "/", max_health)
	
	# Визуальный эффект при получении урона
	_start_damage_effect()
	
	if health <= 0:
		die()

func _start_damage_effect() -> void:
	# Простой визуальный эффект при получении урона
	var original_modulate = modulate
	modulate = Color(1.5, 0.5, 0.5)  # Красноватый оттенок
	
	# Создаем таймер для возврата к нормальному цвету
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.timeout.connect(_end_damage_effect.bind(original_modulate))
	timer.start()

func _end_damage_effect(original_color: Color) -> void:
	modulate = original_color
	# Удаляем таймер
	for child in get_children():
		if child is Timer and child.one_shot:
			child.queue_free()

func die() -> void:
	print("Test Enemy died")
	
	# Визуальный эффект смерти
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_callback(_finalize_death)
	
	# Вызываем родительский метод смерти
	super()

func _finalize_death() -> void:
	# Убедимся что враг удаляется
	queue_free()

# Можно добавить специфическое поведение для TestEnemy
func _physics_process(delta):
	super._physics_process(delta)
	
	# Дополнительная логика для тестового врага (если нужна)
	# Например, простая анимация или дополнительные эффекты
	pass
