extends CharacterBody2D

#Gamestate Variables
var stats_opened = false
var dead = false
var old_playback = 0  #Used for Footstep Sound

#Player Stats
var health = 200
var max_health = 200
var expirience = 0
var max_expirience = 20


#Movement Variables
var speed = 300
var dash_vector = Vector2(0, 0)
var dash_power = 15
var dash_cooldown = 5
var dash_cooldown_progress = 0

#Gun Variables
@export var bullet_scene: PackedScene
var ammo = 5
var max_ammo = 5
var gun_cooldown = 3
var gun_cooldown_progress = 0

#Sword Variables
var bullets_in_range = []
var enemies_in_range = []
var sword_cooldown = 3
var sword_cooldown_progress = 0

func _ready():
	pass

func _physics_process(delta):
	#Die if health reaches 0
	if health <= 0:
		die()
	
	update_cooldowns(delta)
	process_combat()
	process_movement(delta)


#Update gun, sword, and dash cooldowns
func update_cooldowns(delta):
	if gun_cooldown_progress > 0:
		gun_cooldown_progress -= delta
	if gun_cooldown_progress < 0:
		gun_cooldown_progress = 0
		
	if sword_cooldown_progress > 0:
		sword_cooldown_progress -= delta
	if sword_cooldown_progress < 0:
		sword_cooldown_progress = 0
		
	if dash_cooldown_progress > 0:
		dash_cooldown_progress -= delta
	if dash_cooldown_progress < 0:
		dash_cooldown_progress = 0


func process_combat():
	look_at(get_global_mouse_position())
	
	#Shoot Bullet
	if Input.is_action_just_pressed("shoot") and ammo > 0 and gun_cooldown_progress <= 0 and not stats_opened:
		gun_cooldown_progress = gun_cooldown
		ammo -= 1
		
		var bullet = bullet_scene.instantiate()
		bullet.global_position = $gun_tip.global_position
		bullet.direction = (get_global_mouse_position() - global_position).normalized()
		bullet.add_to_group("player_bullet")
		get_tree().current_scene.add_child(bullet)
		
	#Block/Parry/Swing Sword
	if Input.is_action_just_pressed('block') and sword_cooldown_progress <= 0:
		sword_cooldown_progress = sword_cooldown
		
		for enemy_bullet in bullets_in_range:
			bullets_in_range.erase(enemy_bullet)
			enemy_bullet.queue_free()
			
		for enemy in enemies_in_range:
			enemy.health -= 100


func process_movement(delta):
	#Movement
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x +=1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -=1
	
	#Implement Dash Mechanic
	if Input.is_action_just_pressed("dash") and dash_cooldown_progress <= 0:
		dash_cooldown_progress = dash_cooldown
		dash_vector = velocity.normalized() * dash_power
	
	var old_dash_vector = dash_vector
	if dash_vector.length() > 0:
		dash_vector -= delta * dash_vector.normalized() * 50
	if (old_dash_vector.length() < dash_vector.length()):
		dash_vector = Vector2.ZERO
	
	var collision = move_and_collide(velocity.normalized() * delta * speed + dash_vector)
	
	if collision and (collision.get_collider().is_in_group('wall') or collision.get_collider().is_in_group('enemy')):
		velocity = velocity.slide(collision.get_normal())
		dash_vector = dash_vector.slide(collision.get_normal())
		move_and_collide(velocity * delta * speed + dash_vector)
	
	#PROCESS PLAYER SOUNDS
	if velocity.length() > 0 and not $sound_footsteps.playing:
		$sound_footsteps.play()
	elif velocity.length() == 0 and $sound_footsteps.playing:
		$sound_footsteps.stop()
	
	if $sound_footsteps.get_playback_position() < old_playback:
		$sound_footsteps.pitch_scale = randf_range(.85, 1.15)
	old_playback = $sound_footsteps.get_playback_position()


func die():
	hide()


#SWORD AREA ON ENTER AND EXIT
func _on_sword_hitbox_area_entered(area):
	if area.is_in_group('enemy_bullet'):
		bullets_in_range.append(area)

func _on_sword_hitbox_area_exited(area):
	if area.is_in_group('enemy_bullet') and bullets_in_range.has(area):
		bullets_in_range.erase(area)

func _on_sword_hitbox_body_entered(body):
	if body.is_in_group('enemy'):
		enemies_in_range.append(body)

func _on_sword_hitbox_body_exited(body):
	if body.is_in_group('enemy') and enemies_in_range.has(body):
		enemies_in_range.erase(body)


func upgrade_stat(stat):
	print(stat)
	if stat == "health":
		max_health += 20
	elif stat == "speed":
		speed += 20
	elif stat == "ammo":
		max_ammo += 1
	elif stat == "gun_cooldown":
		max_ammo += 1
	elif stat == "bullet_speed":
		max_ammo += 20
	elif stat == "bullet_damage":
		max_ammo += 20
	elif stat == "bullet_size":
		max_ammo += 20
