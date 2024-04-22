extends AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pitch_scale = randf_range(.8, 1.2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not playing:
		queue_free()
