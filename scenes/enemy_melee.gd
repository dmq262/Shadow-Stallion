extends CharacterBody2D

var speed = 200
var active = false
var player
var cooldown = 0
var cooldown_progress = 3
var health = 100

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
	#Do nothing if unable to find player, or not active
	if player == null or (not active):
		return
		
	if Input.is_action_just_pressed('shoot'):
		#astar_generator.test(get_global_mouse_position())
		pass
		
	#Process movement
	if astar != null:
		process_movement(delta)
	
	#Die when health reaches 0
	if health <= 0:
		die()
		
	look_at(player.position)


func test(destination):
	#Convert current and destination coordinations to Astargrid coordinates
	var current_point = (Vector2.ZERO + Vector2((room_size * grid_size) / 2, (room_size * grid_size) / 2)) / cell_size
	current_point = Vector2i(current_point)
	var destination_point = (destination + Vector2((room_size * grid_size) / 2, (room_size * grid_size) / 2)) / cell_size
	destination_point = Vector2i(destination_point)

	
	#Get Path, returns AstarGrid coordinates(in pixels), need to offset back to world coordinates
	var path = astar.get_id_path(current_point, destination_point)
	print(path)


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
	
	print(target, path)

	
	#If further than 3 cells away, and current cell has reached target, get new target
	if path.size() > 2 and current_point == Vector2i(target):
		print('new target', target, path)
		target = path.pop_front()
	
	#Set velocity and move
	velocity = Vector2i(target) - current_point
	velocity.normalized()

	var collision = move_and_collide(velocity * delta * speed)
	if collision:
		velocity = velocity.slide(collision.get_normal())
		move_and_collide(velocity * delta * speed)

func die():
	queue_free()
