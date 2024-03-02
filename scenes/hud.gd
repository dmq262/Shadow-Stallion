extends CanvasLayer

signal upgrade_stat()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("shoot"): # For testing purposes
		pass

#SET HEAD UP DISPLAY COMPONENTS
func set_expirience(current, max):
	$gameplay/expirience_bar.ratio = float(current)/max

func set_health(current, max):
	$gameplay/health_bar.ratio = float(current)/max

func set_ammo(ammo):
	var count = 0
	for ammo_texture in $gameplay/ammo_container.get_children():
		if ammo > count:
			ammo_texture.show()
		else:
			ammo_texture.hide()
		count += 1

func set_gun_cooldown(current, max):
	$gameplay/gun_cooldown.ratio = float(current)/max

func set_sword_cooldown(current, max):
	$gameplay/sword_cooldown.ratio = float(current)/max

func set_dash_cooldown(current, max):
	$gameplay/dash_cooldown.ratio = float(current)/max

#TOGGLE STATS
func toggle_stats():
	if $stats.visible:
		$stats.hide()
		return false
	else:
		$stats.show()
		return true

#UPGRADE BUTTONS
func upgrade_button(stat: String):
	emit_signal('upgrade_stat', stat)
	

#UPDATE STATS PAGE
func set_stats(health, speed, max_ammo, gun_cooldown, bullet_speed, bullet_size, bullet_damage, sword_cooldown, sword_damage, sword_size, dash_cooldown, dash_power, level_points, expirience, max_expirience):
	$stats/base/base_stats.text = str(health) + "\n\n" + str(speed)
	$stats/gun/gun_stats.text = str(max_ammo) + "\n\n" + str(gun_cooldown) + "\n\n" + str(bullet_speed) + "\n\n" + str(bullet_size) + "\n\n" + str(bullet_damage)
	$stats/sword/sword_stats.text = str(sword_cooldown) + "\n\n" + str(sword_damage) + "\n\n" + str(sword_size)
	$stats/dash/dash_stats.text = str(dash_cooldown) + "\n\n" + str(dash_power)
	$stats/level_points.text = "Current Expirience: " + str(expirience) + "/" + str(max_expirience) + "\nUnspent Levels: " + str(level_points)

func show_upgrades(level_points, upgrade_increments):
	for upgrade_button in get_tree().get_nodes_in_group('upgrade_button'):
		if level_points <= 0:
			upgrade_button.hide()
			continue
		
		upgrade_button.show()
		
		#Go through upgrade increments, if 0, then hide
		if upgrade_increments['ammo'][0] == 0:
			$stats/gun/upgrade_ammo.hide()
		if upgrade_increments['gun_cooldown'][0] == 0:
			$stats/gun/upgrade_gun_cooldown.hide()
		if upgrade_increments['bullet_size'][0] == 0:
			$stats/gun/upgrade_bullet_size.hide()
		if upgrade_increments['sword_cooldown'][0] == 0:
			$stats/sword/upgrade_sword_cooldown.hide()
		if upgrade_increments['sword_size'][0] == 0:
			$stats/sword/upgrade_sword_size.hide()
		if upgrade_increments['dash_power'][0] == 0:
			$stats/dash/upgrade_dash_power.hide()
		if upgrade_increments['dash_cooldown'][0] == 0:
			$stats/dash/upgrade_dash_cooldown.hide()
