extends CharacterBody2D

signal player_death()

#Gamestate Variables
var stats_opened = false
var dead = false
var old_playback = 0  #Used for Footstep Sound

#Player Stats
var health = 80
var max_health = 100
var expirience = 5
var max_expirience = 100
var level_points = 5

#Movement Variables
var speed = 300
var dash_vector = Vector2(0, 0)
var dash_power = 10
var dash_cooldown = 10
var dash_cooldown_progress = 0

#Gun Variables
@export var bullet_scene: PackedScene
var ammo = 3
var max_ammo = 5
var gun_cooldown = 5
var gun_cooldown_progress = 0
var bullet_speed = 400
var bullet_size = 1
var bullet_damage = 50

#Sword Variables
var bullets_in_range = []
var enemies_in_range = []
var sword_cooldown = 5
var sword_cooldown_progress = 0
var sword_damage = 50
var sword_size = 1

#Upgrade Variables
var upgrade_increments = {
	"health": [25],
	"speed": [50, 50, 25, 25, 10],
	"ammo": [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
	"gun_cooldown": [-1, -.5, -.5, -.5, -.5, -.25, -.25, -.25, -.25, -.1, -.1, -.1, -.1, -.1, 0],
	"bullet_speed": [100, 50, 50, 25, 25, 10],
	"bullet_size": [.5, .25, .25, .1, .1, .1, .1, .1, 0],
	"bullet_damage": [25],
	"sword_cooldown": [-1, -.5, -.5, -.5, -.5, -.25, -.25, -.25, -.25, -.1, -.1, -.1, -.1, -.1, 0],
	"sword_damage": [25],
	"sword_size": [.25, .1, .1, .1, .1, .1, 0],
	"dash_cooldown": [-2, -2, -1, -1, -.5, -.5, -.5, -.5, -.25, -.25, -.25, -.25, -.1, -.1, -.1, -.1, -.1, 0],
	"dash_power": [2.5, 2.5, 1, 1, 1, .5, .5, .5, .5, 0],
}

func _ready():
	pass

func _physics_process(delta):
	if dead:
		return
	
	#Die if health reaches 0
	if health <= 0:
		die()
	
	cap_variables()
	update_cooldowns(delta)
	process_combat()
	process_movement(delta)


func cap_variables():
	if ammo > max_ammo:
		ammo = max_ammo
	if health > max_health:
		health = max_health
	if expirience > max_expirience:
		level_points += 1
		expirience -= max_expirience


#Update gun, sword, and dash cooldowns
func update_cooldowns(delta):
	if gun_cooldown_progress > 0:
		gun_cooldown_progress -= delta
	if gun_cooldown_progress > gun_cooldown:
		gun_cooldown_progress = gun_cooldown
	if gun_cooldown_progress < 0:
		gun_cooldown_progress = 0
		
	if sword_cooldown_progress > 0:
		sword_cooldown_progress -= delta
	if sword_cooldown_progress > sword_cooldown:
		sword_cooldown_progress = sword_cooldown
	if sword_cooldown_progress < 0:
		sword_cooldown_progress = 0
		
	if dash_cooldown_progress > 0:
		dash_cooldown_progress -= delta
	if dash_cooldown_progress > dash_cooldown:
		dash_cooldown_progress = dash_cooldown
	if dash_cooldown_progress < 0:
		dash_cooldown_progress = 0


func process_combat():
	look_at(get_global_mouse_position())
	$sword_hitbox.scale = Vector2(sword_size, sword_size)
	
	#Shoot Bullet
	if Input.is_action_just_pressed("shoot") and ammo > 0 and gun_cooldown_progress <= 0 and not stats_opened:
		gun_cooldown_progress = gun_cooldown
		ammo -= 1
		
		var bullet = bullet_scene.instantiate()
		
		#Set Bullet Variables
		bullet.global_position = $gun_tip.global_position
		bullet.direction = (get_global_mouse_position() - global_position).normalized()
		bullet.speed = bullet_speed
		bullet.scale = Vector2(bullet_size, bullet_size)
		bullet.damage = bullet_damage
		
		bullet.add_to_group("player_bullet")
		get_tree().current_scene.add_child(bullet)
		
	#Block/Parry/Swing Sword
	if Input.is_action_just_pressed('block') and sword_cooldown_progress <= 0:
		sword_cooldown_progress = sword_cooldown
		
		for enemy_bullet in bullets_in_range:
			bullets_in_range.erase(enemy_bullet)
			enemy_bullet.queue_free()
			
		for enemy in enemies_in_range:
			enemy.health -= sword_damage
			
		$sword_hitbox/sword_animation.sprite_frames.set_animation_loop('slash', false)
		$sword_hitbox/sword_animation.play('slash')


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
	if (Input.is_action_just_pressed("dash")) and (dash_cooldown_progress) <= 0 and (velocity != Vector2.ZERO):
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


func hit(damage):
	health -= damage

func die():
	emit_signal("player_death")
	dead = true
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


#PROCESS STAT UPGRADES
func upgrade_stat(stat):
	level_points -= 1
	#BASE
	if stat == "health":
		max_health += upgrade_increments[stat][0]
		health += upgrade_increments[stat][0]
		upgrade_increments[stat][0] += 5
	elif stat == "speed":
		speed += upgrade_increments[stat][0]
	#GUN
	elif stat == "ammo":
		max_ammo += upgrade_increments[stat][0]
		ammo += upgrade_increments[stat][0]
	elif stat == "gun_cooldown":
		gun_cooldown += upgrade_increments[stat][0]
	elif stat == "bullet_speed":
		bullet_speed += upgrade_increments[stat][0]
	elif stat == "bullet_damage":
		bullet_damage += upgrade_increments[stat][0]
		upgrade_increments[stat][0] += 5
	elif stat == "bullet_size":
		bullet_size += upgrade_increments[stat][0]
	#SWORD
	elif stat == "sword_cooldown":
		sword_cooldown += upgrade_increments[stat][0]
	elif stat == "sword_damage":
		sword_damage += upgrade_increments[stat][0]
		upgrade_increments[stat][0] += 5
	elif stat == "sword_size":
		sword_size += upgrade_increments[stat][0]
	#DASH
	elif stat == "dash_cooldown":
		dash_cooldown += upgrade_increments[stat][0]
	elif stat == "dash_power":
		dash_power += upgrade_increments[stat][0]
	else:
		print(stat, "not found")
		
	if (stat in upgrade_increments) and upgrade_increments[stat].size() > 1:
		upgrade_increments[stat].pop_front()


#RESETS ALL VARIABLES, COPY OF VARIABLE DECLARATION AT TOP OF SCRIPT, CALLED WHEN RESTARTING GAME
func reset_player():
	global_position = Vector2(0, 0)
	show()
	stats_opened = false
	dead = false
	health = 80
	max_health = 100
	expirience = 5
	max_expirience = 100
	level_points = 5
	speed = 300
	dash_vector = Vector2(0, 0)
	dash_power = 10
	dash_cooldown = 10
	dash_cooldown_progress = 0
	ammo = 3
	max_ammo = 5
	gun_cooldown = 5
	gun_cooldown_progress = 0
	bullet_speed = 400
	bullet_size = 1
	bullet_damage = 50
	bullets_in_range = []
	enemies_in_range = []
	sword_cooldown = 5
	sword_cooldown_progress = 0
	sword_damage = 50
	sword_size = 1
	upgrade_increments = {
		"health": [25],
		"speed": [50, 50, 25, 25, 10],
		"ammo": [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
		"gun_cooldown": [-1, -.5, -.5, -.5, -.5, -.25, -.25, -.25, -.25, -.1, -.1, -.1, -.1, -.1, 0],
		"bullet_speed": [100, 50, 50, 25, 25, 10],
		"bullet_size": [.5, .25, .25, .1, .1, .1, .1, .1, 0],
		"bullet_damage": [25],
		"sword_cooldown": [-1, -.5, -.5, -.5, -.5, -.25, -.25, -.25, -.25, -.1, -.1, -.1, -.1, -.1, 0],
		"sword_damage": [25],
		"sword_size": [.25, .1, .1, .1, .1, .1, 0],
		"dash_cooldown": [-2, -2, -1, -1, -.5, -.5, -.5, -.5, -.25, -.25, -.25, -.25, -.1, -.1, -.1, -.1, -.1, 0],
		"dash_power": [2.5, 2.5, 1, 1, 1, .5, .5, .5, .5, 0],
	}
