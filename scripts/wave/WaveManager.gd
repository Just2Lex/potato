extends Node

var current_wave: int = 0

func start_next_wave():
	current_wave += 1
	GameManager.set_current_wave(current_wave)
	print("Starting wave: ", current_wave)
	
	# Здесь будет логика спавна врагов

func on_enemy_died():
	GameManager.increment_enemies_killed()
