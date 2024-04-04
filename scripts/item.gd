class_name Item
extends RefCounted

var name: String
var qty: int
var parent: Item
var children: Array[Item]

func get_total_required() -> int:
	if parent == null:
		return qty
	return qty * parent.get_total_required()
