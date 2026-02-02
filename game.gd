class_name Game extends Node2D

@onready var level_manager = $LevelManager
@onready var game_manager = $GameManager
@onready var hud = $HUD
@onready var category = $HUD/Category
@onready var spawn_shape = $SpawnArea/SpawnShape
@onready var start_button = $StartButton
@onready var score = $HUD/Score

@export var spawn_time : float = 2.0

var score_value: int = 0
func _ready() -> void:
	level_manager.title.connect(set_hud_title)
	level_manager.send_bubble.connect(spawn_bubble)
	EventBus.correct_bubble_clicked.connect(add_point)
	EventBus.wrong_bubble_clicked.connect(remove_point)
	level_manager.summon_timer.wait_time = spawn_time
	
func _on_start_button_pressed():
	var level_data: LevelData = game_manager.create_level_data()
	if level_data:
		level_manager.level_data = level_data
		level_manager.create_level()
		start_button.disabled = true
		start_button.visible = false
func set_hud_title(_title: String) -> void:
	category.text = _title

func random_point_in_rect_shape() -> Vector2:
	var shape: RectangleShape2D = spawn_shape.shape
	var global_xform: Transform2D = spawn_shape.transform
	var shape_size = shape.size * 0.5
	var local_point := Vector2(
		randf_range(-shape_size.x, shape_size.x),
		randf_range(-shape_size.y, shape_size.y)
	)
	print(local_point)
	return global_xform * local_point

func spawn_bubble(_bubble: Bubble) -> void:
	if _bubble:
		add_child(_bubble)
		_bubble.global_position = random_point_in_rect_shape()

func add_point() -> void:
	score_value += 1
	score.text = str(score_value)

func remove_point() -> void:
	score_value -= 1
	score.text = str(score_value)
