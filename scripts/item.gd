class_name Item
extends RefCounted

var name: String
var qty: int
var parent: Item
var img_url: String
var icon: Texture2D
var children: Array[Item]
var missing: int
var used: int
var can_use: bool:
	get:
		return qty > used
var price: int

func get_total_required() -> int:
	if parent == null:
		return qty
	return qty * parent.get_total_required()

func _on_start_updating_components():
	missing = get_total_required()
