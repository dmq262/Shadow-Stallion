extends Node

var room_grid = []
var available_rooms = []
var room_count = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	#initialize room_grid
	for i in range(11):
		room_grid.append([])
		for j in range(11):
			room_grid[i].append(Room.new())
			room_grid[i][j].coordinates.x = j
			room_grid[i][j].coordinates.y = i
	
	#Edit array
	'''
	#Hard coded test
	room_grid[4][4].is_room = true
	room_grid[4][3].right_door = true
	room_grid[4][3].bottom_door = true
	room_grid[5][3].is_room = true
	room_grid[3][4].bottom_door = true
	print(room_grid[5][3].coordinates)
	'''
	#Room Generation Algorithm
	var room_count = 1
	room_grid[5][5].is_room = true
	available_rooms.append(room_grid[4][5])
	available_rooms.append(room_grid[6][5])
	available_rooms.append(room_grid[5][4])
	available_rooms.append(room_grid[5][6])
	add_room(room_grid[5][5], available_rooms)
	
	#Add Doors to using children
	add_door(room_grid[5][5])
	
	print_rooms()
	

func add_room(parent, available_rooms):
	parent.is_room = true
	room_count += 1
	if room_count > 25:
		return true
	
	available_rooms.shuffle()
	
	for room in available_rooms:
		var new_available_rooms = []
		if (room.coordinates.y + 1 < 11) and (not room_grid[room.coordinates.y + 1][room.coordinates.x].is_room):
			new_available_rooms.append(room_grid[room.coordinates.y + 1][room.coordinates.x])
		if (room.coordinates.y - 1 >= 0) and (not room_grid[room.coordinates.y - 1][room.coordinates.x].is_room):
			new_available_rooms.append(room_grid[room.coordinates.y - 1][room.coordinates.x])
		if (room.coordinates.x + 1 < 11) and (not room_grid[room.coordinates.y][room.coordinates.x + 1].is_room):
			new_available_rooms.append(room_grid[room.coordinates.y][room.coordinates.x + 1])
		if (room.coordinates.x - 1 >= 0) and (not room_grid[room.coordinates.y][room.coordinates.x - 1].is_room):
			new_available_rooms.append(room_grid[room.coordinates.y][room.coordinates.x - 1])
			
		parent.children.append(room)
		if add_room(room, new_available_rooms):
			return true

func add_door(parent):
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
			if room.is_room:
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
