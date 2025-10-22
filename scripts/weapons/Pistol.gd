extends WeaponBase
class_name Pistol

# Можно добавить специфические свойства пистолета
@export var visual_scale: Vector2 = Vector2(1.0, 1.0)

func _ready():
	super._ready()
	# Пистолетная специфическая инициализация
	scale = visual_scale
	print("Pistol scene loaded")

func fire():
	print("Pistol firing with special behavior")
	super.fire()  # Вызываем базовую реализацию
