class_name Recipe
extends RefCounted

var item_name: String
var info: String
var itens: Array[Item]
var unique_components: Array[Item]

func add_item(item: Item):
	itens.append(item)
	add_component(item)

func add_component(item: Item):
	var found := false
	for c in unique_components:
		if c.name == item.name:
			c.qty += item.get_total_required()
			found = true
	if !found:
		var new_comp = Item.new()
		new_comp.name = item.name
		new_comp.qty = item.get_total_required()
		unique_components.append(new_comp)
	
	for child in item.children:
		add_component(child)

func print():
	var level := 0
	print(item_name + ": " + info)
	for item in itens:
		print_item(item, level)

func print_item(item: Item, level: int):
	var spacer = ""
	if level > 0:
		spacer = "|__ "
	print("\t".repeat(level) + spacer + str(item.qty) + " " + item.name + " (total: " + str(item.get_total_required()) + ")")
	if item.children.size() > 0:
		level += 1
		for child in item.children:
			print_item(child, level)

func print_components():
	print("Components: ")
	for c in unique_components:
		print(c.name + " (total: " + str(c.qty) + ")")
