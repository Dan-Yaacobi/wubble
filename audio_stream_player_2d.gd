extends AudioStreamPlayer2D

func _ready() -> void:
	EventBus.play_sound.connect(add_and_play)
func add_and_play(_stream) -> void:
	stream = _stream
	playing = true
