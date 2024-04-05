class_name ComponentRow
extends MarginContainer

@export var icon_texture: TextureRect
@export var name_label: Label
@export var qty_label: Label
@export var add_button: Button

var components_table: ComponentsTable

func update_row(item: Item):
	icon_texture.texture = item.icon
	name_label.text = item.name
	qty_label.text = str(item.missing) + "/" + str(item.qty)
