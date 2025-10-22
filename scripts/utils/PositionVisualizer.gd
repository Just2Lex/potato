extends Node2D

@export var visualize_weapon_slots: bool = true
@export var slot_color: Color = Color.CYAN

func _ready():
	if not Engine.is_editor_hint():
		queue_free()
		return

func _draw():
	if visualize_weapon_slots:
		var weapon_slots = get_parent().get_node_or_null("WeaponSlots")
		if weapon_slots:
			for slot in weapon_slots.get_children():
				if slot is Marker2D:
					# Рисуем круг для каждого слота
					draw_circle(slot.position, 10, slot_color)
					draw_string(ThemeDB.get_fallback_font(), slot.position + Vector2(15, 0), slot.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
