class_name ComponentRow
extends MarginContainer

const BASE_URL = "https://l2.dropspoil.com"

@export var icon_texture: TextureRect
@export var name_link: LinkButton
@export var cost_label: Label
@export var qty_label: Label
@export var add_button: Button
@export var fade_color: Color
@export var hbox: HBoxContainer

var components_table: ComponentsTable

func update_row(item: Item):
	icon_texture.texture = item.icon
	name_link.text = item.name
	name_link.uri = BASE_URL + item.path
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

func _on_name_pressed() -> void:
	print("Open link: " + name_link.uri)
