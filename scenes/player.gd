extends CharacterBody2D

@export var bullet_scene: PackedScene

#Player Stats
var health = 200
var max_health = 200
var expirience = 0
var max_expirience = 20

var old_playback = 0

#Movement Variables
var speed = 300
var dash_vector = Vector2(0, 0)
var dash_power = 15

#Gun Variables
var ammo = 5
var max_ammo = 5

#Sword Variables
var bullets_in_range = []
var enemies_in_range = []

func _ready():
	pass

func _physics_process(delta):
	#Die if health reaches 0
	if health <= 0:
		die()
	
	#Combat
	look_at(get_global_mouse_position())
	
	#Shoot Bullet
	if Input.is_action_just_pressed("shoot") and ammo > 0:
		ammo -= 1
		
		var bullet = bullet_scene.instantiate()
		bullet.global_position = $gun_tip.global_position
		bullet.direction = (get_global_mouse_position() - global_position).normalized()
		bullet.add_to_group("player_bullet")
		get_tree().current_scene.add_child(bullet)
		
	#Block/Parry/Swing Sword
	if Input.is_action_just_pressed('block'):
		for enemy_bullet in bullets_in_range:
			bullets_in_range.erase(enemy_bullet)
			enemy_bullet.queue_free()
			
		for enemy in enemies_in_range:
			enemy.health -= 100
			
	
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
	if Input.is_action_just_pressed("dash"):
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
