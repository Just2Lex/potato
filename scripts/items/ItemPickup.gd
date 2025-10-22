# res://scripts/items/ItemPickup.gd
extends Area2D

@export var item_data: ItemData

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.apply_item_modifiers(item_data)
		queue_free()
