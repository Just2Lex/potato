extends CanvasLayer

@onready var weapon_info_label = $WeaponInfoLabel

func _ready():
	# Скрываем в релизной версии
	if not OS.is_debug_build():
		queue_free()
		return

func _process(_delta):
	update_weapon_info()

func update_weapon_info():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_weapon_info"):
		weapon_info_label.text = player.get_weapon_info()
	else:
		weapon_info_label.text = "No player found"

# Показать/скрыть отладочную информацию
func _input(event):
	if event.is_action_pressed("toggle_debug_info"):
		weapon_info_label.visible = !weapon_info_label.visible
