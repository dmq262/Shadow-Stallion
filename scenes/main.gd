extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	game_start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#HUD Control
	update_hud()
	if Input.is_action_just_pressed('stats'):
		$player.stats_opened = $hud.toggle_stats()
	
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
	
	$hud.set_stats($player.health, $player.speed, $player.max_ammo, $player.gun_cooldown, $player.bullet_speed, $player.bullet_size, $player.bullet_damage, $player.sword_cooldown, $player.sword_damage, $player.sword_size, $player.dash_cooldown, $player.dash_power, $player.level_points, $player.expirience, $player.max_expirience)


func _on_hud_upgrade_stat(stat):
	$player.upgrade_stat(stat)
