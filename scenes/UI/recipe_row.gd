class_name RecipeRow
extends MarginContainer

@export var icon_texture: TextureRect
@export var recipe_name_label: Label
@export var open_button: Button

var base_url := "https://l2.dropspoil.com/"

func create_row(recipe_name: String, icon_path: String, recipe_path: String, recipe_parser: RecipeParser):
	recipe_name_label.text = recipe_name
	open_button.pressed.connect(_on_button_pressed.bind(recipe_path, recipe_parser))
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_icon_completed.bind(http))
	http.request(base_url+icon_path)

func _on_request_icon_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest):
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("Error requesting icon url for: " + recipe_name_label.text)
		return
	var image = Image.new()
	var err = image.load_png_from_buffer(body)
	if err != OK:
		printerr("Error loading PNG")
	var texture = ImageTexture.new()
	texture = ImageTexture.create_from_image(image)
	icon_texture.texture = texture
	http.queue_free()

func _on_button_pressed(recipe_path: String, recipe_parser: RecipeParser) -> void:
	recipe_parser.request_recipe(recipe_path)
