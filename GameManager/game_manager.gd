class_name GameManager extends Node2D
var db: SQLite
const ITEMS_TABLE: String = "items"
const PROMPT_TABLE: String = "prompts"
const PROMPT_ITEMS_TABLE: String = "prompt_items"

func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data.db" # or res:// if editor-only
	db.open_db()
	db.foreign_keys = true
	var prompt = get_random_prompt()
	print("Prompt chosen randomaly: ", prompt)
	print("Items: ", get_items_from_prompt(prompt))
	
func get_random_prompt() -> int:
	var rows: Array = db.select_rows(PROMPT_TABLE,
		"",["*"]
	)
	if rows.is_empty():
		return -1
	var row: Dictionary = rows.pick_random()
	
	return row.get("id")

func get_items_from_prompt(_prompt_id: int) -> Array[String]:

	db.query_with_bindings(
	"""
	SELECT text
	FROM items
	JOIN prompt_items ON prompt_items.item_id = items.id
	WHERE prompt_items.prompt_id = ?;
	""",
	[_prompt_id]
	)
	var items:Array[Dictionary] = db.query_result
	if items.is_empty():
		return []
	var res: Array[String]
	for item in items:
		res.append(item.get("text"))

	return res

func get_wrong_items_from_prompt(_prompt_id: int) -> Array[String]:
	
	return []
	
func select(_title: String, _min_diff: int, _max_diff: int) -> void:
	db.quer("
	SELECT i.*
	FROM items i
	JOIN prompt_items pi ON pi.item_id 
	")
