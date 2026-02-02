class_name LevelManager extends Node2D

@onready var summon_timer = $SummonTimer
signal title(_title: String)
signal send_bubble(_bubble: Bubble)
const BUBBLE = preload("res://Bubble/Bubble.tscn")
var level_data: LevelData

func _ready() -> void:
	summon_timer.timeout.connect(summon_bubble)
	
func create_level() -> void:
	if level_data:
		set_title(level_data.category)
		summon_timer.start()
		level_data.correct_chance = 0.33
		
func set_title(_title: String) -> void:
	title.emit(_title)

func summon_bubble() -> void:
	var bubble: Bubble = BUBBLE.instantiate()
	var spawn_correct: float = randf()
	var correct: bool = false
	var word: String
	if spawn_correct <= level_data.correct_chance:
		correct = true
	if correct:
		word = level_data.correct_words.pick_random()
	else:
		word = level_data.wrong_words.pick_random()
	bubble.set_values(correct,word)
	send_bubble.emit(bubble)
	
