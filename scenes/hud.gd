extends CanvasLayer

signal upgrade_stat()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("shoot"): # For testing purposes
		pass

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


#UPGRADE BUTTONS
func upgrade_health():
	emit_signal('upgrade_stat', 'health')
	
func upgrade_speed():
	emit_signal('upgrade_stat', 'speed')
	
func upgrade_ammo():
	emit_signal('upgrade_stat', 'ammo')
	
func upgrade_gun_cooldown():
	emit_signal('upgrade_stat', 'gun_cooldown')
	
func upgrade_bullet_speed():
	emit_signal('upgrade_stat', 'bullet_speed')
	
func upgrade_bullet_damage():
	emit_signal('upgrade_stat', 'bullet_damage')
	
func upgrade_bullet_size():
	emit_signal('upgrade_stat', 'bullet_size')

