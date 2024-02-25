extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	game_start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("restart"):
		for wall in get_tree().get_nodes_in_group('wall'):
			wall.queue_free()
		for room in get_tree().get_nodes_in_group('room'):
			room.queue_free()
		$player.health = 100
		$player.show()
		$player.global_position = Vector2(0, 0)
		game_start()

func game_start():
	$music.play()
	$room_generator.generate_rooms()
	$astar_generator.generate_astar()
