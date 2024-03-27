extends Node

var tutorial = false
var boss_killed = false
var level = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	game_start()
	tutorial = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#HUD Control
	update_hud()
	if Input.is_action_just_pressed('stats') and not $player.dead:
		$player.stats_opened = $hud.toggle_stats()
	
	#Next Level Mechanic
	if Input.is_action_just_pressed('next_level') and not $player.stats_opened:
		next_level()
	
	#Temp Restart mechanic
	if Input.is_action_just_pressed("restart") and $player.dead:
		for wall in get_tree().get_nodes_in_group('wall'):
			wall.queue_free()
		for room in get_tree().get_nodes_in_group('room'):
			room.queue_free()
		
		$player.reset_player() #I would put this in game_start(), but it causes a bug where a new room detects the old player position
		await get_tree().process_frame
		game_start()

func game_start():
	$music.play()
	$room_generator.generate_rooms(5, 19 , 1000, tutorial)
	$room_boss/boss.boss_death.connect(level_complete)
	$astar_generator.generate_astar()
	
	
func update_hud():
	#HUD ELEMENTS
	$hud.set_health($player.health, $player.max_health)
	$hud.set_ammo($player.ammo)
	$hud.set_expirience($player.expirience, $player.max_expirience)
	$hud.set_gun_cooldown($player.gun_cooldown_progress, $player.gun_cooldown)
	$hud.set_sword_cooldown($player.sword_cooldown_progress, $player.sword_cooldown)
	$hud.set_dash_cooldown($player.dash_cooldown_progress, $player.dash_cooldown)
	$hud.show_current_level(level, boss_killed)
	
	$hud.game_over($player.dead)
	
	#STAT ELEMENTS
	$hud.set_stats($player.health, $player.speed, $player.max_ammo, $player.gun_cooldown, $player.bullet_speed, $player.bullet_size, $player.bullet_damage, $player.sword_cooldown, $player.sword_damage, $player.sword_size, $player.dash_cooldown, $player.dash_power, $player.level_points, $player.expirience, $player.max_expirience)
	$hud.show_upgrades($player.level_points, $player.upgrade_increments)

func level_complete():
	print("Boss Killed")
	boss_killed = true
	
func next_level():
	level += 1
	boss_killed = false
	
	for wall in get_tree().get_nodes_in_group('wall'):
		wall.queue_free()
	for room in get_tree().get_nodes_in_group('room'):
		room.queue_free()
	
	$player.global_position = Vector2(0, 0)
	$player.show()
	await get_tree().process_frame
	game_start()

func close_stats():
	if $hud.toggle_stats():
		$hud.toggle_stats()

func _on_hud_upgrade_stat(stat):
	$player.upgrade_stat(stat)
