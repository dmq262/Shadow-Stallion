extends CharacterBody2D

signal boss_death

@export var bullet_scene: PackedScene
@export var health_scene: PackedScene
@export var ammo_scene: PackedScene
@export var expirience_scene: PackedScene
@export var blood_splatter_scene: PackedScene
@export var sound_enemy_damage_scene: PackedScene

var speed = 210
@export var active = false
var player
var cooldown = .5
var cooldown_progress = .5
var health = 300
@export var damage = 45

#Pathfinding Variables, assigned by 'astar_generator'
var astar
var path = []
var old_destination
var room_size
var grid_size
var cell_size
var target

func scale_enemy(level):
	health *= 1.5 ** (level - 1)
	speed *= 1.2 ** (level - 1)
	cooldown -= .1 * (level-1)
	damage *= 1.5 ** (level - 1)
	

func _ready():
	cooldown_progress = randf_range(0, cooldown)
	player = get_tree().current_scene.get_node('player')
	if player == null:
		print('player not found')

func _physics_process(delta):
	#Die when health reaches 0
	if health <= 0:
		die()
		
	#Do nothing if unable to find player, or not active
	if player == null or (not active):
		return
	
	look_at(player.position)
	
	#Process movement
	if astar != null:
		process_movement(delta)
	
	#Shoot at player
	if cooldown_progress <= 0:
		shoot_bullet()
		cooldown_progress = cooldown
	else:
		cooldown_progress -= delta
		

#Helper Function for shooting at player
func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = $gun_tip.global_position
	bullet.rotation = rotation
	bullet.damage = damage
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.add_to_group("enemy_bullet")
	get_tree().current_scene.add_child(bullet)
	
	$sound_gunshot.play()

func hit(damage):
	health -= damage
	
	var blood_splatter = blood_splatter_scene.instantiate()
	blood_splatter.global_position = global_position
	get_tree().current_scene.add_child(blood_splatter)
	get_tree().current_scene.move_child(blood_splatter, 0)
	
	var sound_damage = sound_enemy_damage_scene.instantiate()
	sound_damage.global_position = global_position
	get_tree().current_scene.add_child(sound_damage)

func die():
	for i in range(randi_range(1, 4)):
		drop_loot(health_scene, "health", 20)
		
	for i in range(randi_range(2, 5)):
		drop_loot(ammo_scene, "ammo", 1)
		
	for i in range(randi_range(3, 7)):
		drop_loot(expirience_scene, "expirience", 7)
	
	emit_signal("boss_death")
	queue_free()

func drop_loot(loot_scene, type, value):
	var loot = loot_scene.instantiate()
	loot.type = type
	loot.value = value
	loot.global_position = global_position
	loot.velocity = Vector2(randf_range(-7, 7), randf_range(-7, 7))
	get_tree().current_scene.add_child(loot)

func process_movement(delta):
	#Convert enemy and player coordinates to AstaGrid Coordinates
	var current_point = (global_position + Vector2((room_size * grid_size) / 2, (room_size * grid_size) / 2)) / cell_size
	current_point = Vector2i(current_point)
	var destination_point = (player.global_position + Vector2((room_size * grid_size) / 2, (room_size * grid_size) / 2)) / cell_size
	destination_point = Vector2i(destination_point)
	
	#In case enemy gets activated while player is in unwalkable area
	if target == null:
		target = current_point
	
	#If player's AstarGrid Coordinates changed, then get new path
	if destination_point != old_destination:
		var new_path = Array(astar.get_id_path(current_point, destination_point))
		old_destination = destination_point
		
		#Set path if new path is not empty
		if not new_path.is_empty():
			path = new_path
			path.pop_front() #First cell is current Position, so remove it
	
	#If further than 3 cells away, and current cell has reached target, get new target
	if path.size() > 5 and current_point == Vector2i(target):
		target = path.pop_front()
	
	#Set velocity and move
	velocity = Vector2i(target) - current_point
	velocity.normalized()
	
	var collision = move_and_collide(velocity * delta * speed)
