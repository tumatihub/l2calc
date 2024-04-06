class_name ComponentsTable
extends Control

@export var component_row_scene: PackedScene
@export var vbox: VBoxContainer
@export var inventory: Inventory

func update_table(recipe: Recipe):
	clear()
	for c in recipe.unique_components:
		var row := component_row_scene.instantiate() as ComponentRow
		vbox.add_child(row)
		row.update_row(c)
		row.components_table = self
		row.add_button.pressed.connect(_on_add_button_pressed.bind(c))

func clear():
	for child in vbox.get_children():
		child.queue_free()

func _on_add_button_pressed(item: Item):
	inventory.add_item(item)

