extends Node2D

var db: SQLite
const ITEMS_TABLE: String = "items"
const PROMPT_TABLE: String = "prompts"
const PROMPT_ITEMS_TABLE: String = "prompt_items"
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data.db"
	db.open_db()
	db.foreign_keys = true
	db.create_table(ITEMS_TABLE,create_items_table())
	db.create_table(PROMPT_TABLE,create_prompts_table())
	db.create_table(PROMPT_ITEMS_TABLE,create_prompt_items_table())
	build_database_from_json("res://data.json")
	db.close_db()

func load_json(path: String) -> Dictionary:

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open JSON file: " + path)
		return {}

	var content: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON structure")
		return {}
	return parsed as Dictionary

	
func insert_items_from_json(data: Dictionary) -> void:
	var items: Array = data.get("items", [])
	for item in items:
		var text: String = item["text"]
		var difficulty: int = item.get("difficulty", 1)
		insert_item(text,difficulty)
		#db.insert_row(ITEMS_TABLE,{"text": text,"difficulty": difficulty})
		
func insert_prompts_from_json(data: Dictionary) -> void:
	var prompts: Array = data.get("prompts", [])

	for prompt in prompts:
		var text: String = prompt["text"]
		var min_difficulty: int = prompt["min_difficulty"]
		var max_difficulty: int = prompt["max_difficulty"]
		insert_prompt(text,min_difficulty,max_difficulty)
		#db.insert_row(PROMPT_TABLE,{"text": text,"min_difficulty": min_difficulty,"max_difficulty": max_difficulty})


func get_item_id(item_text: String) -> int:
	var rows: Array = db.select_rows(
		ITEMS_TABLE,
		"text = '%s'" % item_text,
		["*"]
	)
	if rows.is_empty():
		push_error("Item not found: " + item_text)
		return -1

	var row: Dictionary = rows[0]
	return row["id"] as int

	
func get_prompt_id(prompt_text: String) -> int:
	var rows: Array = db.select_rows(
		PROMPT_TABLE,"text = '%s'" % prompt_text,
		["*"]
	)

	if rows.is_empty():
		push_error("Prompt not found: " + prompt_text)
		return -1

	var row: Dictionary = rows[0]
	return row["id"] as int

	
func insert_prompt_item(prompt_text: String, item_text: String) -> void:
	var prompt_id: int = get_prompt_id(prompt_text)
	var item_id: int = get_item_id(item_text)

	if prompt_id == -1 or item_id == -1:
		return

	db.insert_row(
		PROMPT_ITEMS_TABLE,
		{
			"prompt_id": prompt_id,
			"item_id": item_id
		}
	)
func insert_prompt_items(prompt_text: String, item_texts: Array[String]) -> void:
	for item_text in item_texts:
		insert_prompt_item(prompt_text, item_text)
		
func insert_prompt_items_from_json(data: Dictionary) -> void:
	var prompts: Array = data.get("prompts", [])

	for prompt in prompts:
		var prompt_text: String = prompt["text"]
		var item_texts: Array = prompt.get("items", [])

		for item_text in item_texts:
			insert_prompt_item(prompt_text, item_text)

func build_database_from_json(path: String) -> void:
	var data: Dictionary = load_json(path)
	if data.is_empty():
		return

	insert_items_from_json(data)
	insert_prompts_from_json(data)
	insert_prompt_items_from_json(data)

func insert_item(_item_name: String, _difficulty: int) -> void:
	var new_item: Dictionary ={
		"text": _item_name,
		"difficulty": _difficulty
	}
	db.insert_row(ITEMS_TABLE,new_item)

func insert_prompt(_prompt_text: String, _min_diff: int, _max_diff: int) -> void:
	var new_prompt: Dictionary ={
		"text": _prompt_text,
		"min_difficulty": _min_diff,
		"max_difficulty": _max_diff
	}
	db.insert_row(PROMPT_TABLE,new_prompt)


func create_items_table() -> Dictionary:
	var table: Dictionary = {
		"id": 
			{
			"data_type": "int",
			"primary_key": true,
			"not_null": true,
			"auto_increment": true
			},
		"text":
			{
				"data_type": "text",
				"not_null": true
			},
		"difficulty":
			{
				"data_type": "int",
				"not_null": true,
				"default": 1
			}
	}
	return table

func create_prompts_table() -> Dictionary:
	var table: Dictionary = {
		"id": 
			{
			"data_type": "int",
			"primary_key": true,
			"not_null": true,
			"auto_increment": true
			},
		"text":
			{
				"data_type": "text",
				"not_null": true
			},
		"min_difficulty": 
			{
			"data_type": "int",
			"not_null": true
			},
		"max_difficulty": 
			{
			"data_type": "int",
			"not_null": true
			}
	}
	return table

func create_prompt_items_table() -> Dictionary:
	var table: Dictionary = {
	"prompt_id":
		{
		"data_type": "int",
		"primary_key": true,
		"foreign_key": "prompts.id",
		"not_null": true
		},
	"item_id":
		{
		"data_type": "int",
		"primary_key": true,
		"foreign_key": "items.id",
		"not_null": true
		}
	}
	return table
