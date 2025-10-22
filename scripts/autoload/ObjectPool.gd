extends Node

var pools: Dictionary = {}

func _ready():
	print("ObjectPool initialized")

# Создает пул объектов для указанной сцены
func create_pool(scene: PackedScene, initial_size: int) -> void:
	if not pools.has(scene):
		pools[scene] = []
		for i in range(initial_size):
			var instance = scene.instantiate()
			pools[scene].append(instance)
			# Не добавляем как дочерний узел, так как будем добавлять в сцену при использовании
			instance.hide()

# Получает экземпляр из пула или создает новый
func get_instance(scene: PackedScene) -> Node:
	if pools.has(scene) and pools[scene].size() > 0:
		var instance = pools[scene].pop_front()
		instance.show()
		return instance
	else:
		# Fallback - создаем новый инстанс если пул пуст
		var instance = scene.instantiate()
		print("Warning: Pool for ", scene.resource_path, " is empty, creating new instance")
		return instance

# Возвращает экземпляр в пул
func return_instance(scene: PackedScene, instance: Node) -> void:
	if pools.has(scene):
		instance.hide()
		# Отсоединяем от родителя
		if instance.get_parent():
			instance.get_parent().remove_child(instance)
		pools[scene].append(instance)
	else:
		instance.queue_free()

# Очищает все пулы
func clear_pools() -> void:
	for scene in pools:
		for instance in pools[scene]:
			instance.queue_free()
	pools.clear()
