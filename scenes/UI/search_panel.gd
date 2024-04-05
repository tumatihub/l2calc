class_name SearchPanel
extends PanelContainer

@export var recipe_parser: RecipeParser
@export var input: LineEdit
@export var recipe_row_scene: PackedScene
@export var vbox: VBoxContainer

var base_url := "https://l2.dropspoil.com/"

func _on_button_pressed() -> void:
	if input.text.is_empty():
		return
	search(input.text)

func search(recipe_name: String):
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_search_request_completed.bind(http))
	var no_space_name = recipe_name.replace(" ", "+")
	var search_url = base_url+"?s="+no_space_name
	print("Requesting: " + search_url)
	http.request(search_url)

func _on_search_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest):
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("Error requesting search: " + input.text)
		return
	for child in vbox.get_children():
		child.queue_free()
	var document := XML.parse_buffer(body)
	var table: XMLNode
	for node in document.root.children:
		if node.name == "body":
			for n in node.children:
				if n.children.size() > 0 && n.children[0].name == "table":
					table = n.children[0]
	if table == null:
		return
	for tr in table.children:
		var td := tr.children[0]
		if td.children.size() < 3:
			continue
		var icon_path = td.children[0].attributes["src"]
		var recipe_name = td.children[1].attributes["title"]
		var recipe_path = td.children[2].attributes["href"]
		create_recipe_row(recipe_name, icon_path, recipe_path)
	http.queue_free()

func create_recipe_row(recipe_name: String, icon_path: String, recipe_path: String):
	var row := recipe_row_scene.instantiate() as RecipeRow
	vbox.add_child(row)
	row.create_row(recipe_name, icon_path, recipe_path, recipe_parser)
