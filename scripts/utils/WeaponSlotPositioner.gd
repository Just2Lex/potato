extends Node
class_name WeaponSlotPositioner

# Утилита для автоматической расстановки Marker2D слотов оружия
static func setup_circular_slots(parent_node: Node2D, radius: float = 40.0) -> void:
	var weapon_slots = parent_node.get_node_or_null("WeaponSlots")
	if not weapon_slots:
		print("WeaponSlots node not found")
		return
	
	var slot_count = weapon_slots.get_child_count()
	var angle_step = TAU / slot_count
	
	for i in range(slot_count):
		var slot = weapon_slots.get_child(i)
		if slot is Marker2D:
			var angle = i * angle_step
			var offset = Vector2(cos(angle), sin(angle)) * radius
			slot.position = offset
