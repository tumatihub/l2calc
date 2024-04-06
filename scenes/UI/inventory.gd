class_name Inventory
extends Control

signal updated
signal icons_loaded

@export var inventory_row_scene: PackedScene
@export var vbox: VBoxContainer

var items: Array[Item]
var save_file_path := "user://inventory.save"
var pending_icon := 0
var base_url := "https://l2.dropspoil.com/"

func _ready() -> void:
	load_inventory()

func add_item(item: Item):
	for i in items:
		if i.name == item.name:
			return
	var new_item := Item.new()
	new_item.name = item.name
	new_item.qty = 0
	new_item.icon = item.icon
	new_item.img_url = item.img_url
	items.append(new_item)
	sort()
	update()

func remove_item(item: Item):
	for i in items:
		if i.name == item.name:
			items.erase(i)
			update()

func sort():
	items.sort_custom(func(a:Item,b:Item): return a.name < b.name)

func update():
	for child in vbox.get_children():
		child.queue_free()
	for i in items:
		var row := inventory_row_scene.instantiate() as InventoryRow
		vbox.add_child.call_deferred(row)
		row.icon_texture.texture = i.icon
		row.name_label.text = i.name
		row.stock_input.text = str(i.qty)
		row.inventory = self
		row.item = i
	updated.emit()
	save_inventory()

func reset_used_items():
	for i in items:
		i.used = 0

func get_in_stock(item: Item) -> int:
	for i in items:
		if i.name == item.name:
			if !i.can_use:
				return 0
			var remain := i.qty - i.used
			i.used = i.qty
			return remain
	return 0

func return_to_stock(item: Item, qty: int):
	for i in items:
		if i.name == item.name:
			i.used -= qty

func save_inventory():
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	for i in items:
		var dict = create_dict_from_item(i)
		var json_string = JSON.stringify(dict)
		save_file.store_line(json_string)

func load_inventory():
	if not FileAccess.file_exists(save_file_path):
		return
	var save_file = FileAccess.open(save_file_path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var dict = json.get_data()
		var item = Item.new()
		item.name = dict["name"]
		item.qty = dict["qty"]
		item.img_url = dict["img_url"]
		items.append(item)
		
		var http := HTTPRequest.new()
		add_child(http)
		http.request_completed.connect(_on_request_icon_completed.bind(item, http))
		pending_icon += 1
		http.request(base_url+item.img_url)
	await icons_loaded
	update()
		
func _on_request_icon_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, item: Item, http: HTTPRequest):
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("Error requesting url: " + item.img_url)
		return
	var image = Image.new()
	var err = image.load_png_from_buffer(body)
	if err != OK:
		printerr("Error loading PNG")
	var texture = ImageTexture.new()
	texture = ImageTexture.create_from_image(image)
	item.icon = texture
	pending_icon -= 1
	if pending_icon == 0:
		icons_loaded.emit()
	http.queue_free()

func create_dict_from_item(item: Item):
	var dict := {}
	dict["name"] = item.name
	dict["qty"] = item.qty
	dict["img_url"] = item.img_url
	return dict

func _on_tab_container_tab_changed(tab: int) -> void:
	update()
