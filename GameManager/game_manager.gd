class_name GameManager extends Node2D

const ITEMS_TABLE: String = "items"
const PROMPT_TABLE: String = "prompts"
const PROMPT_ITEMS_TABLE: String = "prompt_items"

var db: SQLite
var last_picked_prompt: int = -1

func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data.db"
	db.foreign_keys = true


func create_level_data() -> LevelData:
	db.open_db()
	
	var level_data: LevelData = LevelData.new()
	var prompt = get_random_prompt()
	level_data.category = prompt.get("text")
	level_data.correct_words = get_items_from_prompt(prompt.get("id"))
	level_data.wrong_words = get_wrong_items_from_prompt(prompt.get("id"))
	
	db.close_db()
	return level_data
	
func get_random_prompt() -> Dictionary:
		
	var rows: Array = db.select_rows(PROMPT_TABLE,
		"",["*"]
	)
	if rows.is_empty():
		return {}
		
	var chosen_prompt_id: int = -1
	var row: Dictionary
	while chosen_prompt_id == last_picked_prompt:
		row = rows.pick_random()
		chosen_prompt_id = row.get("id")
		
	last_picked_prompt = chosen_prompt_id
	
	return row

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
	db.query_with_bindings(
		"""
		SELECT items.text AS text
		FROM items
		LEFT JOIN prompt_items
			ON items.id = prompt_items.item_id
			AND prompt_items.prompt_id = ?
		WHERE prompt_items.item_id IS NULL;
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

	
func select(_title: String, _min_diff: int, _max_diff: int) -> void:
	db.quer("
	SELECT i.*
	FROM items i
	JOIN prompt_items pi ON pi.item_id 
	")
