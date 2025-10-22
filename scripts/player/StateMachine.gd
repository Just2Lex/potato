extends Node

enum PlayerState { IDLE, WALK, ATTACK, DASH, HURT, DEAD }
enum Direction { UP, DOWN, LEFT, RIGHT }

@onready var player = get_parent()
@onready var animated_sprite = player.get_node("AnimatedSprite2D")

var current_state: int = PlayerState.IDLE
var current_direction: int = Direction.DOWN

static func get_animation_name(state: int, direction: int) -> String:
	var state_name = ""
	match state:
		PlayerState.IDLE: state_name = "idle"
		PlayerState.WALK: state_name = "walk"
		PlayerState.ATTACK: state_name = "attack"
		PlayerState.DASH: state_name = "dash"
		PlayerState.HURT: state_name = "hurt"
		PlayerState.DEAD: state_name = "dead"
	
	var direction_name = ""
	match direction:
		Direction.UP: direction_name = "up"
		Direction.DOWN: direction_name = "down"
		Direction.LEFT: direction_name = "side"
		Direction.RIGHT: direction_name = "side"
	
	return state_name + "_" + direction_name

static func vector_to_direction(direction: Vector2) -> int:
	var angle = direction.angle()
	
	if abs(angle) <= PI/4:
		return Direction.RIGHT
	elif abs(angle) >= 3*PI/4:
		return Direction.LEFT
	elif angle > PI/4 and angle < 3*PI/4:
		return Direction.DOWN
	else:
		return Direction.UP

func initialize(initial_state: int) -> void:
	current_state = initial_state
	update_animation()

func update_state(input_vector: Vector2, last_direction: Vector2) -> void:
	var new_state = determine_state(input_vector)
	var new_direction = vector_to_direction(last_direction)
	
	if new_state != current_state or new_direction != current_direction:
		current_state = new_state
		current_direction = new_direction
		update_animation()

func determine_state(input_vector: Vector2) -> int:
	# Убираем проверку смерти, так как теперь она обрабатывается в GameManager
	
	# Здесь можно добавить проверку на состояние атаки, получение урона и т.д.
	# if is_attacking:
	#     return PlayerState.ATTACK
	# if is_hurt:
	#     return PlayerState.HURT
	
	if input_vector != Vector2.ZERO:
		return PlayerState.WALK
	else:
		return PlayerState.IDLE

func update_animation() -> void:
	var animation_name = get_animation_name(current_state, current_direction)
	player.play_animation(animation_name)
	player.set_sprite_flip(current_direction)
