extends Area2D

@export var speed: float = 500.0
@export var damage: float = 10.0
@export var lifetime: float = 3.0

var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT
var is_critical: bool = false

func _ready():
	# Подключаем сигнал столкновения
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Визуальное выделение критического попадания
	if is_critical:
		modulate = Color(1.5, 0.5, 0.5)  # Красноватый оттенок
	
	# Автоматическое удаление через время жизни
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_end)
	timer.start()

func setup(dmg: float, dir: Vector2, spd: float = 500.0, critical: bool = false) -> void:
	damage = dmg
	direction = dir.normalized()
	speed = spd
	velocity = direction * speed
	rotation = direction.angle()
	is_critical = critical

func _physics_process(delta):
	position += velocity * delta

func _on_lifetime_end():
	destroy()

func destroy() -> void:
	# Возвращаем в пул вместо удаления
	var projectile_scene = load("res://scenes/Weapon/BasicProjectile.tscn")
	ObjectPool.return_instance(projectile_scene, self)

# При столкновении с врагом (Area2D)
func _on_area_entered(area):
	if area.is_in_group("enemies"):
		apply_damage(area.get_parent())

# При столкновении с врагом (CharacterBody2D)
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		apply_damage(body)

func apply_damage(target: Node) -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage, is_critical)
		print("Projectile hit enemy for ", damage, " damage", " (CRITICAL)" if is_critical else "")
		destroy()
