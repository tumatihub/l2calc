class_name RecipePanel
extends Control

@export var tree: Tree

var icon: Texture2D = preload("res://icon.svg")
var root: TreeItem
func _ready() -> void:
	tree.set_column_expand(0, false)
	tree.set_column_expand(1, true)
	tree.set_column_expand(2, false)
	tree.set_column_title(0, "Icon")
	tree.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	tree.set_column_title(1, "Name")
	tree.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	tree.set_column_title(2, "Total Required")
	tree.set_column_title_alignment(2, HORIZONTAL_ALIGNMENT_RIGHT)
	root = tree.create_item()
	tree.hide_root = true

func update_recipe_tree(recipe: Recipe) -> void:
	clear()
	for item in recipe.items:
		add_item(item, root)

func clear():
	tree.clear()
	root = tree.create_item()

func add_item(item: Item, tree_parent: TreeItem):
	var tree_item = tree.create_item(tree_parent)
	tree_item.set_text(1, item.name + " (" + str(item.qty) + ")")
	tree_item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	tree_item.set_text(2, str(item.get_total_required()))
	tree_item.set_text_alignment(2, HORIZONTAL_ALIGNMENT_RIGHT)
	tree_item.set_icon(0, item.icon)
	tree_item.set_icon_max_width(0, 40)
	
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


