extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	game_start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func game_start():
	$music.play()
	$room_generator.generate_rooms(5, 64)
