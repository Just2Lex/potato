extends Node
class_name TestItemFactory

static func create_attack_boost() -> ItemData:
	var item = ItemData.new()
	item.item_name = "Power Crystal"
	item.description = "Increases attack power"
	item.rarity = "common"
	item.modifiers = {
		"attack_power": 0.2  # +20% к силе атаки
	}
	return item

static func create_vampirism_item() -> ItemData:
	var item = ItemData.new()
	item.item_name = "Vampire Tooth"
	item.description = "Grants lifesteal"
	item.rarity = "rare"
	item.modifiers = {
		"vampirism": 0.1  # 10% вампиризма
	}
	return item

static func create_armor_item() -> ItemData:
	var item = ItemData.new()
	item.item_name = "Steel Plate"
	item.description = "Increases armor"
	item.rarity = "uncommon"
	item.modifiers = {
		"armor": 5.0  # +5 брони
	}
	return item

static func create_dodge_item() -> ItemData:
	var item = ItemData.new()
	item.item_name = "Agility Boots"
	item.description = "Increases dodge chance"
	item.rarity = "uncommon"
	item.modifiers = {
		"dodge_chance": 0.15  # +15% шанс уклонения
	}
	return item
