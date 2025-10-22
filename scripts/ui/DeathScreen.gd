extends CanvasLayer

signal restart_pressed

# Используем более надежный способ получения узлов
@onready var wave_label: Label = $VBoxContainer/WaveLabel
@onready var enemies_label: Label = $VBoxContainer/EnemiesLabel
@onready var restart_button: Button = $VBoxContainer/RestartButton

func _ready():
	# Проверяем что все узлы найдены
	if not wave_label:
		push_error("WaveLabel not found! Check scene structure.")
	if not enemies_label:
		push_error("EnemiesLabel not found! Check scene structure.")
	if not restart_button:
		push_error("RestartButton not found! Check scene structure.")
	
	# Подключаем сигнал кнопки
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)
	
	# Сначала скрываем экран смерти
	hide()

func show_death_screen(wave: int, enemies_killed: int):
	# Безопасно устанавливаем текст
	if wave_label:
		wave_label.text = "Wave: " + str(wave)
	else:
		print("ERROR: WaveLabel is null")
	
	if enemies_label:
		enemies_label.text = "Enemies Killed: " + str(enemies_killed)
	else:
		print("ERROR: EnemiesLabel is null")
	
	show()
	
	# Ставим игру на паузу
	get_tree().paused = true

func _on_restart_button_pressed():
	get_tree().paused = false
	restart_pressed.emit()
	queue_free()
