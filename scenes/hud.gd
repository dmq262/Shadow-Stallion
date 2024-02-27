extends CanvasLayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("shoot"): # For testing purposes
		pass

func set_expirience(current, max):
	$expirience_bar.ratio = float(current)/max

func set_health(current, max):
	$health_bar.ratio = float(current)/max

func set_ammo(ammo):
	var count = 0
	for ammo_texture in $ammo_container.get_children():
		if ammo > count:
			ammo_texture.show()
		else:
			ammo_texture.hide()
		count += 1

func set_gun_cooldown(current, max):
	$gun_cooldown.ratio = float(current)/max

func set_sword_cooldown(current, max):
	$sword_cooldown.ratio = float(current)/max

func set_dash_cooldown(current, max):
	$dash_cooldown.ratio = float(current)/max
