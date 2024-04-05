class_name Inventory
extends Control

signal updated

@export var inventory_row_scene: PackedScene
@export var vbox: VBoxContainer

var items: Array[Item]

func add_item(item: Item):
	for i in items:
		if i.name == item.name:
			return
	var new_item := Item.new()
	new_item.name = item.name
	new_item.qty = 0
	new_item.icon = item.icon
	items.append(new_item)
	update()

func update():
	for child in vbox.get_children():
		child.queue_free()
	for i in items:
		var row := inventory_row_scene.instantiate() as InventoryRow
		vbox.add_child.call_deferred(row)
		row.icon_texture.texture = i.icon
		row.name_label.text = i.name
		row.stock_input.text = str(i.qty)
		row.inventory = self
		row.item = i
	updated.emit()

func reset_used_items():
	for i in items:
		i.used = 0

func get_in_stock(item: Item) -> int:
	for i in items:
		if i.name == item.name:
			if !i.can_use:
				return 0
			var remain := i.qty - i.used
			i.used = i.qty
			return remain
	return 0

func return_to_stock(item: Item, qty: int):
	for i in items:
		if i.name == item.name:
			i.used -= qty
