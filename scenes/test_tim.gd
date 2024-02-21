extends Node

var room_grid = []
var available_rooms = []
var room_count = 1
var grid_size = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	#initialize room_grid
	for i in range(grid_size):
		room_grid.append([])
		for j in range(grid_size):
			room_grid[i].append(Room.new())
			room_grid[i][j].coordinates.x = j
			room_grid[i][j].coordinates.y = i
	
	#Edit array
	#Room Generation Algorithm
	var room_count = 1
	var start_room = room_grid[2][2]
	start_room.is_room = true
	available_rooms.append(room_grid[start_room.coordinates.y - 1][start_room.coordinates.x])
	available_rooms.append(room_grid[start_room.coordinates.y + 1][start_room.coordinates.x])
	available_rooms.append(room_grid[start_room.coordinates.y][start_room.coordinates.x + 1])
	available_rooms.append(room_grid[start_room.coordinates.y][start_room.coordinates.x - 1])
	add_room(start_room, available_rooms)
	
	#Add Doors to using children
	add_door(start_room)
	
	#Add Random Doors
	for row in room_grid:
		for room in row:
			#Horizontal Doors
			if (room.is_room) and (room.coordinates.x + 1 < grid_size) and (room_grid[room.coordinates.y][room.coordinates.x + 1].is_room) and (randf() < .3):
				room.right_door = true
				
			#Vertical Doors
			if (room.is_room) and (room.coordinates.y + 1 < grid_size) and (room_grid[room.coordinates.y + 1][room.coordinates.x].is_room) and randf() < .3:
				room.bottom_door = true
	
	#Set Distances
	set_distances(start_room)
	
	#print_rooms()
	

func set_distances(parent):
	#Uses breadth first search to set distance
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
		
	

func add_room(parent, available_rooms):
	#Uses depth first search to create rooms
	parent.is_room = true
	room_count += 1
	if room_count > 18:
		return true
	
	available_rooms.shuffle()
	
	for room in available_rooms:
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
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
