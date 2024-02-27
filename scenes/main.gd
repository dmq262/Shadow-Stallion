extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	game_start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_hud()
	
	#Temp Restart mechanic
	if Input.is_action_just_pressed("restart"):
		for wall in get_tree().get_nodes_in_group('wall'):
			wall.queue_free()
		for room in get_tree().get_nodes_in_group('room'):
			room.queue_free()
			
		
		$player.health = 100
		$player.show()
		$player.global_position = Vector2(0, 0)
		await get_tree().process_frame
		game_start()

func game_start():
	$music.play()
	$room_generator.generate_rooms()
	$astar_generator.generate_astar()
	
func update_hud():
	$hud.set_health($player.health, $player.max_health)
	$hud.set_ammo($player.ammo)
	$hud.set_expirience($player.expirience, $player.max_expirience)
	$hud.set_gun_cooldown($player.gun_cooldown_progress, $player.gun_cooldown)
	$hud.set_sword_cooldown($player.sword_cooldown_progress, $player.sword_cooldown)
	$hud.set_dash_cooldown($player.dash_cooldown_progress, $player.dash_cooldown)
