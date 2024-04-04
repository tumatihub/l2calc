class_name ComponentRow
extends MarginContainer

@export var icon_texture: TextureRect
@export var name_label: Label
@export var qty_label: Label

func update_row(item: Item):
	icon_texture.texture = item.icon
	name_label.text = item.name
	qty_label.text = str(item.get_total_required())
