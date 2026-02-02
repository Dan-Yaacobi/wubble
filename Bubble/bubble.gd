class_name Bubble extends CharacterBody2D

@onready var title = $Control/Title
@onready var visible_on_screen_notifier = $VisibleOnScreenNotifier2D

var correct: bool
var title_holder: String

func _ready() -> void:
	title.text = title_holder
	visible_on_screen_notifier.screen_exited.connect(pop)
	
func set_values(_correct: bool, _title: String) -> void:
	title_holder = _title
	correct = _correct

func _physics_process(_delta):
	velocity.y -= randf_range(1,5)* _delta
	move_and_slide()
	
func pop() -> void:
	var mat: ShaderMaterial = material
	print(mat.get_shader_parameter("ring_radius"))
	var shader_tween: Tween = create_tween()
	shader_tween.tween_property(mat,"shader_parameter/ring_radius",1.0,0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await shader_tween.finished
	queue_free()
	
func _on_button_pressed():
	if correct:
		EventBus.correct_bubble_clicked.emit()
	else:
		EventBus.wrong_bubble_clicked.emit()
	pop()
