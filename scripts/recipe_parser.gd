extends Node

@export var http: HTTPRequest

var url := "https://l2.dropspoil.com/db/recipe/6887/recipe-angel-slayer.html"
var parser: XMLParser
var document: XMLDocument
var recipe: Recipe

func _ready() -> void:
	http.request_completed.connect(_on_request_completed)
	http.request(url)
	parser = XMLParser.new()

func _on_request_completed_old(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	parser.open_buffer(body)
	print(parser)
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT && parser.get_node_name() == "ul":
			print("<ul>")
			var err = parser.read()
			while (parser.get_node_name() != "ul" || parser.get_node_type() != XMLParser.NODE_ELEMENT_END) && err != ERR_FILE_EOF:
				if parser.get_node_type() == XMLParser.NODE_ELEMENT:
					var attributes_dict = {}
					for idx in range(parser.get_attribute_count()):
						attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
					print("<"+parser.get_node_name()+"> "+str(attributes_dict))
				elif parser.get_node_type() == XMLParser.NODE_TEXT:
					print(parser.get_current_line())
				err = parser.read()
			print("</ul>")

func _test(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	parser.open_buffer(body)
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			print(parser.get_node_name())

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	document = XML.parse_buffer(body)
	var table_count := 0
	for node in document.root.children:
		if node.name == "body":
			for n in node.children:
				if n.name == "table":
					table_count += 1
				if table_count == 2:
					recipe = parse_recipe(n)
					recipe.print()
					recipe.print_components()
					return

func parse_recipe(table: XMLNode) -> Recipe:
	var recipe := Recipe.new()
	var td := table.children[0].children[0]
	recipe.item_name = td.children[1].children[0].content
	recipe.info = td.children[1].content
	for node in td.children:
		if node.name == "ul":
			var item: Item
			item = parse_item(node)
			recipe.add_item(item)
	return recipe

func parse_item(item_node: XMLNode, parent: Item = null) -> Item:
	var item := Item.new()
	item.parent = parent
	var li := item_node.children[0]
	var img := item_node.children[0].children[0]
	var a := item_node.children[0].children[1]
	var num: int
	var idx = li.content.find("(")
	if  idx != -1:
		num = int(li.content.substr(0, idx))
	else:
		num = int(li.content)
	item.name = a.content
	item.qty = num
	for node in li.children:
		if node.name == "ul":
			var child: Item
			child = parse_item(node, item)
			item.children.append(child)
	return item
