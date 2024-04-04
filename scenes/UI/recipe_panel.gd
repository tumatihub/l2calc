class_name RecipePanel
extends Control

@export var tree: Tree

var icon: Texture2D = preload("res://icon.svg")

func update_recipe_tree(recipe: Recipe) -> void:
	tree.set_column_expand(0, false)
	tree.set_column_expand(1, false)
	tree.set_column_expand(2, false)
	tree.set_column_title(0, "Icon")
	tree.set_column_title(1, "Name")
	tree.set_column_title(2, "Total Required")
	var root = tree.create_item()
	tree.hide_root = true
	
	for item in recipe.itens:
		add_item(item, root)
		

func add_item(item: Item, tree_parent: TreeItem):
	var tree_item = tree.create_item(tree_parent)
	tree_item.set_text(1, item.name + " (" + str(item.qty) + ")")
	tree_item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	tree_item.set_text(2, str(item.get_total_required()))
	tree_item.set_text_alignment(2, HORIZONTAL_ALIGNMENT_RIGHT)
	tree_item.set_icon(0, icon)
	tree_item.set_icon_max_width(0, 40)
	
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_icon_completed.bind(tree_item))
	http.request(item.img_url)
	
	for child in item.children:
		add_item(child, tree_item)

func _on_request_icon_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, tree_item: TreeItem):
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("Error requesting url for item: " + tree_item.get_text(1))
		return
	var image = Image.new()
	var err = image.load_png_from_buffer(body)
	if err != OK:
		printerr("Error loading PNG")
	var texture = ImageTexture.new()
	texture = ImageTexture.create_from_image(image)
	tree_item.set_icon(0, texture)

