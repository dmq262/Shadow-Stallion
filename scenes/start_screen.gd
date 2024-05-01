extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("next_level"):
		get_tree().change_scene_to_file("res://scenes/start_cutscene.tscn")
