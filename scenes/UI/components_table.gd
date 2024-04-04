class_name ComponentsTable
extends Control

@export var component_row_scene: PackedScene
@export var vbox: VBoxContainer

func update_table(recipe: Recipe):
	for child in vbox.get_children():
		child.queue_free()
	for c in recipe.unique_components:
		var row = component_row_scene.instantiate() as ComponentRow
		vbox.add_child(row)
		row.update_row(c)
