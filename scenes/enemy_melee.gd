extends CharacterBody2D

#Loot
@export var health_scene: PackedScene
@export var ammo_scene: PackedScene
@export var expirience_scene: PackedScene
@export var blood_splatter_scene: PackedScene

#Stats
var speed = 180
var active = false
var player
var cooldown = 1.2
var cooldown_progress = 1.2
var health = 100
var player_in_range = false
var damage = 25

#Pathfinding Variables, assigned by 'astar_generator'
var astar
var path = []
var old_destination
var room_size
var grid_size
var cell_size
var target

func _ready():
	active = false
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
	
	#Hit Player
	if cooldown_progress <= 0 and player_in_range:
		cooldown_progress = cooldown
		player.hit(damage)
	elif cooldown_progress > 0:
		cooldown_progress -= delta
	
	#Process movement
	if astar != null:
		process_movement(delta)
	

	look_at(player.position)


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
	if path.size() > 1 and current_point == Vector2i(target):
		target = path.pop_front()
	
	#Set velocity and move
	velocity = Vector2i(target) - current_point
	velocity.normalized()

	var collision = move_and_collide(velocity * delta * speed)


func hit(damage):
	health -= damage
	
	var blood_splatter = blood_splatter_scene.instantiate()
	blood_splatter.global_position = global_position
	get_tree().current_scene.add_child(blood_splatter)
	get_tree().current_scene.move_child(blood_splatter, 0)

func die():
	for i in range(randi_range(1, 4)):
		drop_loot(health_scene, "health", 20)
		
	for i in range(randi_range(2, 5)):
		drop_loot(ammo_scene, "ammo", 1)
		
	for i in range(randi_range(3, 7)):
		drop_loot(expirience_scene, "expirience", 7)
	
	queue_free()


func drop_loot(loot_scene, type, value):
	var loot = loot_scene.instantiate()
	loot.type = type
	loot.value = value
	loot.global_position = global_position
	loot.velocity = Vector2(randf_range(-7, 7), randf_range(-7, 7))
	get_tree().current_scene.add_child(loot)

#DETECT IF PLAYER IN RANGE
func _on_hit_area_body_entered(body):
	if body.is_in_group('player'):
		player_in_range = true


func _on_hit_area_body_exited(body):
	if body.is_in_group('player'):
		player_in_range = false
