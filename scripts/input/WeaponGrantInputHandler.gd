extends Node

@export var grant_on_start: bool = false
@export var grant_interval: float = 5.0  # Интервал между автовыдачей

var grant_timer: Timer

func _ready():
	# Создаем таймер для автоматической выдачи оружия (опционально)
	grant_timer = Timer.new()
	add_child(grant_timer)
	grant_timer.wait_time = grant_interval
	grant_timer.timeout.connect(_on_grant_timer_timeout)
	
	if grant_on_start:
		grant_timer.start()

func _input(event):
	# Обработка ручной выдачи оружия по клавишам
	if event.is_action_pressed("grant_weapon_random"):
		grant_random_weapon()
	
	elif event.is_action_pressed("grant_weapon_pistol"):
		grant_weapon_by_type("pistol")
	
	elif event.is_action_pressed("grant_weapon_shotgun"):
		grant_weapon_by_type("shotgun")
	
	elif event.is_action_pressed("grant_weapon_rifle"):
		grant_weapon_by_type("rifle")
	
	elif event.is_action_pressed("grant_weapon_all"):
		grant_all_weapons()

func grant_random_weapon() -> void:
	GameManager.grant_random_weapon_to_player()

func grant_weapon_by_type(weapon_type: String) -> void:
	GameManager.grant_weapon_by_type_to_player(weapon_type)

func grant_all_weapons() -> void:
	var weapon_types = ["pistol", "shotgun", "rifle"]
	for weapon_type in weapon_types:
		GameManager.grant_weapon_by_type_to_player(weapon_type)

func _on_grant_timer_timeout():
	if grant_on_start:
		grant_random_weapon()
