extends Node

@export var wall_scene_solid: PackedScene
@export var wall_scene_door: PackedScene
@export var room_scenes: Array
@export var start_room_scene: PackedScene
@export var boss_room_scene: PackedScene

var room_grid = []
var available_rooms = []
var room_count = 1
var max_rooms = 19
var grid_size = 5
var room_size = 1000

#Generate Rooms
func generate_rooms(grid_size_input = 5, max_rooms_input = 19, room_size_input = 1000, tutorial = false):
	#Set/Reset Variables
	max_rooms = max_rooms_input
	grid_size = grid_size_input
	room_size = room_size_input
	room_grid = []
	available_rooms = []
	
	#initialize room_grid
	for i in range(grid_size):
		room_grid.append([])
		for j in range(grid_size):
			room_grid[i].append(Room.new())
			room_grid[i][j].coordinates.x = j
			room_grid[i][j].coordinates.y = i
	
	#Generate Rooms
	room_count = 1
	var start_room = room_grid[roundf(grid_size / 2)][roundf(grid_size / 2)]
	available_rooms.append(room_grid[start_room.coordinates.y - 1][start_room.coordinates.x])
	available_rooms.append(room_grid[start_room.coordinates.y + 1][start_room.coordinates.x])
	available_rooms.append(room_grid[start_room.coordinates.y][start_room.coordinates.x + 1])
	available_rooms.append(room_grid[start_room.coordinates.y][start_room.coordinates.x - 1])
	add_room(start_room, available_rooms)
	
	#Add Doors
	add_door(start_room)
	
	print_rooms()
	
	#Add Random Doors
	for row in room_grid:
		for room in row:
			#Horizontal Doors
			if (room.is_room) and (room.coordinates.x + 1 < grid_size) and (room_grid[room.coordinates.y][room.coordinates.x + 1].is_room) and (randf() < .35):
				room.right_door = true
				
			#Vertical Doors
			if (room.is_room) and (room.coordinates.y + 1 < grid_size) and (room_grid[room.coordinates.y + 1][room.coordinates.x].is_room) and randf() < .35:
				room.bottom_door = true
	
	#Set Distances
	set_distances(start_room)
	
	print_rooms()
	
	#Build Rooms
	build_walls(start_room.coordinates)
	build_rooms(start_room.coordinates, tutorial)

#Uses depth first search to create rooms
func add_room(parent, available_rooms):
	parent.is_room = true
	room_count += 1
	
	#End SRomm Generation after 19 rooms
	if room_count > max_rooms:
		return true
	
	#Pick Random Room, build up avaliable rooms and set parent.
	available_rooms.shuffle()
	for room in available_rooms:
		#Skip if room is already discovered. May happen when branching from a previous Room.
		if room.is_room:
			continue
		
		var new_available_rooms = []
		if (room.coordinates.y + 1 < grid_size) and (not room_grid[room.coordinates.y + 1][room.coordinates.x].is_room):
			new_available_rooms.append(room_grid[room.coordinates.y + 1][room.coordinates.x])
		if (room.coordinates.y - 1 >= 0) and (not room_grid[room.coordinates.y - 1][room.coordinates.x].is_room):
			new_available_rooms.append(room_grid[room.coordinates.y - 1][room.coordinates.x])
		if (room.coordinates.x + 1 < grid_size) and (not room_grid[room.coordinates.y][room.coordinates.x + 1].is_room):
			new_available_rooms.append(room_grid[room.coordinates.y][room.coordinates.x + 1])
		if (room.coordinates.x - 1 >= 0) and (not room_grid[room.coordinates.y][room.coordinates.x - 1].is_room):
			new_available_rooms.append(room_grid[room.coordinates.y][room.coordinates.x - 1])
			
		parent.children.append(room)
		
		#Run Function on Room. End Room generation if True.
		if add_room(room, new_available_rooms):
			return true


func add_door(parent):
	#Uses depth first search to create doors
	for room in parent.children:
		#Horizontal Doors
		if room.coordinates.x > parent.coordinates.x:
			parent.right_door = true
		elif room.coordinates.x < parent.coordinates.x:
			room.right_door = true
			
		#Vertical Doors
		if room.coordinates.y > parent.coordinates.y:
			parent.bottom_door = true
		elif room.coordinates.y < parent.coordinates.y:
			room.bottom_door = true
		
		add_door(room)


#Uses breadth first search to set distance
func set_distances(parent):
	var queue = []
	parent.distance = 0
	
	while parent != null:
		#left room
		if (parent.coordinates.x - 1 >= 0) and (room_grid[parent.coordinates.y][parent.coordinates.x - 1].right_door) and (room_grid[parent.coordinates.y][parent.coordinates.x - 1].distance == INF):
			room_grid[parent.coordinates.y][parent.coordinates.x - 1].distance = parent.distance + 1
			queue.append(room_grid[parent.coordinates.y][parent.coordinates.x - 1])
		#right room
		if (parent.coordinates.x + 1 < grid_size) and (parent.right_door) and (room_grid[parent.coordinates.y][parent.coordinates.x + 1].distance == INF):
			room_grid[parent.coordinates.y][parent.coordinates.x + 1].distance = parent.distance + 1
			queue.append(room_grid[parent.coordinates.y][parent.coordinates.x + 1])
		#top room
		if (parent.coordinates.y - 1 >= 0) and (room_grid[parent.coordinates.y - 1][parent.coordinates.x].bottom_door) and (room_grid[parent.coordinates.y - 1][parent.coordinates.x].distance == INF):
			room_grid[parent.coordinates.y - 1][parent.coordinates.x].distance = parent.distance + 1
			queue.append(room_grid[parent.coordinates.y - 1][parent.coordinates.x])
		#bottom room
		if (parent.coordinates.y + 1 < grid_size) and (parent.bottom_door) and (room_grid[parent.coordinates.y + 1][parent.coordinates.x].distance == INF):
			room_grid[parent.coordinates.y + 1][parent.coordinates.x].distance = parent.distance + 1
			queue.append(room_grid[parent.coordinates.y + 1][parent.coordinates.x])
			
		parent = queue.pop_front()


func build_walls(center_coordinates):
	for row in room_grid:
		for room in row:
			#Skip if current room is not used
			if not room.is_room:
				continue
				
			#Build Solid Top Wall if there is no room above
			if room.coordinates.y == 0 or (not room_grid[room.coordinates.y -1][room.coordinates.x].is_room):
				build_wall((room.coordinates - center_coordinates - Vector2(0, .5)) * room_size, PI/2, wall_scene_solid)
				
			#Build Solid Left Wall if there is no room to the left
			if room.coordinates.x == 0 or (not room_grid[room.coordinates.y][room.coordinates.x - 1].is_room):
				build_wall((room.coordinates - center_coordinates - Vector2(.5, 0)) * room_size, 0, wall_scene_solid)
			
			#Build Right Wall
			if room.right_door:
				build_wall((room.coordinates - center_coordinates + Vector2(.5, 0)) * room_size, 0, wall_scene_door)
			else:
				build_wall((room.coordinates - center_coordinates + Vector2(.5, 0)) * room_size, 0, wall_scene_solid)
				
			#Build Bottom Wall
			if room.bottom_door:
				build_wall((room.coordinates - center_coordinates + Vector2(0, .5)) * room_size, PI/2, wall_scene_door)
			else:
				build_wall((room.coordinates - center_coordinates + Vector2(0, .5)) * room_size, PI/2, wall_scene_solid)

#Helper Function for build_rooms
func build_wall(wall_position, wall_rotation, wall_scene):
	var wall = wall_scene.instantiate()
	wall.position = wall_position
	wall.rotation = wall_rotation
	get_tree().current_scene.add_child(wall)

#Instantiate premade rooms in walls
func build_rooms(center_coordinates, tutorial):
	var boss_coordinates = get_boss_coordinates(center_coordinates)
	print("Boss is at: ", boss_coordinates)
	
	for row in room_grid:
		for room in row:
		#Skip if current room is not used
			if not room.is_room:
				continue
				
			#Put Room Scene in Walls
			var new_room
			#Start Room
			if room.distance == 0:
				new_room = start_room_scene.instantiate()
				if not tutorial:
					new_room.phase = 6
			#Boss Room
			elif room.coordinates == boss_coordinates:
				new_room = boss_room_scene.instantiate()
			#Other Rooms
			else:
				room_scenes.shuffle()
				new_room = room_scenes[0].instantiate()
			
			#update position, add room to tree, move to bottom
			new_room.global_position = (room.coordinates - center_coordinates) * room_size
			get_tree().current_scene.add_child(new_room)
			get_tree().current_scene.move_child(new_room, 0)

func get_boss_coordinates(center_coordinates):
	var possible_rooms = []
	var furthest_room = room_grid[center_coordinates.y][center_coordinates.x]
	
	#APPEND ALL ROOMS WITH DISTANCE > 5, FIND FURTHEST ROOM
	for row in room_grid:
		for room in row:
			#Skip non-rooms
			if not room.is_room:
				continue
			
			if room.distance >= 5:
				possible_rooms.append(room)
			if room.distance > furthest_room.distance:
				furthest_room = room
	
	#IF MULTIPLE ROOMS WITH DISTANCE > 5, RETURN RANDOM
	#ELSE, RETURN FURTHEST
	if possible_rooms.size() > 0:
		possible_rooms.shuffle()
		return possible_rooms[0].coordinates
	else:
		return furthest_room.coordinates
	

#Print room_grid
func print_rooms():
	for row in room_grid:
		var text = " "
		#Print Room and Horizontal Door
		for room in row:
			#Rooms
			if room.is_room and room.distance != INF:
				text += "%03d" % room.distance
			elif room.is_room:
				text += " ■ "
			else:
				text += " □ "
			
			#Horizontal Doors
			if room.right_door:
				text += "-"
			else:
				text += " "
		print(text)
		
		text = " "
		#Print Vertical Door
		for room in row:
			if room.bottom_door:
				text += ' | '
			else:
				text += '   '
				
			text += ' '
		print(text)
