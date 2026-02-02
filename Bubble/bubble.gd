class_name Bubble extends CharacterBody2D

@onready var title = $Control/Title
@onready var visible_on_screen_notifier = $VisibleOnScreenNotifier2D
@onready var pop_particles = $PopParticles
@onready var sprite = $Sprite2D
@onready var button = $Button

var correct: bool
var title_holder: String
var clicked: bool = false
var t: float


func _ready() -> void:
	pop_particles.emitting = false
	title.text = title_holder
	visible_on_screen_notifier.screen_exited.connect(pop)
	velocity.y = randf_range(-10,-50)
	
func set_values(_correct: bool, _title: String) -> void:
	title_holder = _title
	correct = _correct

func _physics_process(_delta):
	velocity.y -= randf_range(1,5)* _delta
	t += _delta
	var wobble := sin(t * 3.0) * 0.02
	scale += Vector2(wobble, -wobble * 0.6)
	scale = scale.lerp(Vector2(1.5,1.5), 0.04)
	move_and_slide()
	
func pop() -> void:
	if correct:
		if clicked:
			EventBus.correct_bubble_clicked.emit()
		else:
			EventBus.wrong_bubble_clicked.emit()
	else:
		if clicked:
			EventBus.wrong_bubble_clicked.emit()

	sprite.visible = false
	button.visible = false
	title.visible = false
	pop_particles.emitting = true
	pop_particles.one_shot = true
	
	await pop_particles.finished
	
	queue_free()

func _on_button_pressed():
	clicked = true
	pop()
