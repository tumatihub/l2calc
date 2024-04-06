class_name InventoryRow
extends Control

@export var icon_texture: TextureRect
@export var name_label: Label
@export var stock_input: LineEdit

var item: Item
var inventory: Inventory
var prev: InventoryRow
var next: InventoryRow

func _on_line_edit_text_submitted(new_text: String) -> void:
	update_stock(new_text)

func _on_line_edit_focus_exited() -> void:
	update_stock(stock_input.text)

func update_stock(new_text: String):
	item.qty = int(new_text)
	inventory.update()

func change_focus():
	if next != null:
		next.stock_input.grab_focus()
