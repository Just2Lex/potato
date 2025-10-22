extends Resource
class_name ItemData

@export var item_name: String
@export var texture: Texture2D
@export_multiline var description: String
@export var rarity: String = "common"
@export var modifiers: Dictionary = {
	# Movement
	"max_speed": 0,
	"acceleration": 0,
	"friction": 0,
	
	# Attack
	"attack_power": 0,
	"attack_speed": 0,
	"crit_chance": 0,
	"crit_damage": 0,
	"vampirism": 0,
	
	# Defense
	"max_health": 0,
	"health_regeneration": 0,
	"armor": 0,
	"shield_efficiency": 0,
	"dodge_chance": 0,
	"counter_chance": 0,
	"counter_damage": 0,
	
	# Utility
	"move_speed_multiplier": 0,
	"pickup_multiplier": 0,
	"luck": 0
}
