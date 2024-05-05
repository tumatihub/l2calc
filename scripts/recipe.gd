class_name Recipe
extends RefCounted

var item_name: String
var info: String
var items: Array[Item]
var unique_components: Array[Item]

func add_item(item: Item):
	items.append(item)

func update_components(inventory: Inventory):
	reset_missing()
	inventory.reset_used_items()
	unique_components.clear()
	for i in items:
		add_component(i, inventory)

func add_component(item: Item, inventory: Inventory):
	var found := false
	for c in unique_components:
		if c.name == item.name:
			var missing := calculate_missing(item, inventory)
			c.missing += missing
			c.qty += item.get_total_required()
			c.price = inventory.get_price(item)
			found = true
	if !found:
		var new_comp = Item.new()
		new_comp.name = item.name
		new_comp.missing = calculate_missing(item, inventory)
		new_comp.qty = item.get_total_required()
		new_comp.icon = item.icon
		new_comp.img_url = item.img_url
		new_comp.price = inventory.get_price(item)
		new_comp.path = item.path
		unique_components.append(new_comp)
	
	for child in item.children:
		add_component(child, inventory)

func print():
	var level := 0
	print(item_name + ": " + info)
	for item in items:
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

func calculate_missing(item: Item, inventory: Inventory) -> int:
	var missing: int
	var in_stock := inventory.get_in_stock(item)
	if item.parent != null:
		missing = item.qty * item.parent.missing - in_stock
		if missing < 0:
			item.missing = 0
			inventory.return_to_stock(item, abs(missing))
			return 0
		else:
			item.missing = missing
			return missing
	missing = item.missing - in_stock
	if missing < 0:
		inventory.return_to_stock(item, abs(missing))
		item.missing = 0
		return 0
	else:
		item.missing = missing
		return missing

func reset_missing():
	for i in items:
		reset_item_missing(i)

func reset_item_missing(item: Item):
	item.missing = item.get_total_required()
	for child in item.children:
		reset_item_missing(child)
