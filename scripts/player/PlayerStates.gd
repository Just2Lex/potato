class_name PlayerStates

# Состояния игрока
enum PlayerState {
	IDLE,
	WALK,
	ATTACK,
	DASH,
	HURT,
	DEAD
}

# Направления для анимаций
enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

# Получить имя анимации на основе состояния и направления
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

# Конвертировать вектор направления в enum Direction
static func vector_to_direction(direction: Vector2) -> int:
	var angle = direction.angle()
	
	if abs(angle) <= PI/4:
		return Direction.RIGHT
	elif abs(angle) >= 3*PI/4:
		return Direction.LEFT
	elif angle > PI/4 and angle < 3*PI/4:
		return Direction.DOWN
	else: # angle < -PI/4 and angle > -3*PI/4
		return Direction.UP
