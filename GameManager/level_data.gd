class_name LevelData extends Resource

@export var category: String
@export var correct_words: Array[String]
@export var wrong_words: Array[String]
@export_range(0.0,1.0,0.01) var correct_chance: float
