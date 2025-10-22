extends CharacterBody2D
class_name EnemyBase

# Базовые свойства врага
@export var max_health: float = 50.0
@export var move_speed: float = 80.0
@export var acceleration: float = 400.0
@export var damage: float = 10.0
@export var attack_cooldown: float = 1.0

var health: float
var player: Node2D
var can_attack: bool = true
var attack_timer: Timer

func _ready():
	health = max_health
	player = get_tree().get_first_node_in_group("player")
	
	# Создаем таймер для перезарядки атаки
	attack_timer = Timer.new()
	add_child(attack_timer)
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_cooldown_end)
	
	add_to_group("enemies")
	initialize_enemy()

# Виртуальная функция для инициализации конкретных врагов
func initialize_enemy() -> void:
	pass

func _physics_process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	handle_movement(delta)
	handle_attack()

func handle_movement(delta: float) -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = velocity.move_toward(direction * move_speed, acceleration * delta)
	move_and_slide()

func handle_attack() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("player") and can_attack:
			attack_player(collider)

func attack_player(player_node: Node) -> void:
	if player_node.has_method("take_damage"):
		# Передаем себя как атакующего для возможности контратаки
		player_node.take_damage(damage, self)
		can_attack = false
		attack_timer.start()

func _on_attack_cooldown_end() -> void:
	can_attack = true

func take_damage(amount: float, is_critical: bool = false) -> void:
	health -= amount
	print("Enemy took ", amount, " damage", " (CRITICAL)" if is_critical else "")
	
	if health <= 0:
		die()

func die() -> void:
	queue_free()

# Виртуальная функция для обработки смерти (можно переопределить)
func on_death() -> void:
	pass
