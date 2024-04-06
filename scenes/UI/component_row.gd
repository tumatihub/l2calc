class_name ComponentRow
extends MarginContainer

@export var icon_texture: TextureRect
@export var name_label: Label
@export var cost_label: Label
@export var qty_label: Label
@export var add_button: Button
@export var fade_color: Color
@export var hbox: HBoxContainer

var components_table: ComponentsTable

func update_row(item: Item):
	icon_texture.texture = item.icon
	name_label.text = item.name
	qty_label.text = str(item.missing) + "/" + str(item.qty)
	var cost := item.price * item.missing
	if cost == 0:
		cost_label.text = ""
	else:
		cost_label.text = str(cost)+" a"
	if item.missing == 0:
		hbox.modulate = fade_color
	else:
		hbox.modulate = Color.WHITE
