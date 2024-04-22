extends Node

var room_size
var grid_size
var cell_size
var astar = AStarGrid2D.new()

func generate_astar(room_size_input = 1000, grid_size_input = 5, cell_size_input = 15):
	#Set variables
	astar = AStarGrid2D.new()
	room_size = room_size_input
	grid_size = grid_size_input
	cell_size = cell_size_input
	
	#Set up AstarGrid
	astar.region = Rect2i(0, 0, (room_size * grid_size) / cell_size, (room_size * grid_size) / cell_size)
	astar.cell_size = Vector2i(cell_size, cell_size)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	astar.update()
	
	#Generate Unwalkable areas
	for node in get_tree().get_nodes_in_group("unwalkable"):
		#Get location of area
		var point1 = Vector2i((node.get_node('top_left').global_position + Vector2((room_size * grid_size) / 2, (room_size * grid_size) / 2))/ cell_size)
		var point2 = Vector2i((node.get_node('bottom_right').global_position + Vector2((room_size * grid_size) / 2, (room_size * grid_size) / 2))/ cell_size)
		var rect_position = Vector2i()
		if point1.x > point2.x:
			rect_position.x = point2.x - 1
		else:
			rect_position.x = point1.x - 1
		if point1.y > point2.y:
			rect_position.y = point2.y - 1
		else:
			rect_position.y = point1.y - 1
		
		#Get Size of area
		var rect_width = abs(point1.x - point2.x) + 3
		var rect_height = abs(point1.y - point2.y) + 3
		
		astar.fill_solid_region(Rect2i(rect_position, Vector2i(rect_width, rect_height)))
		
	#Assign Astar to enemies
	for node in get_tree().get_nodes_in_group('enemy'):
		if 'astar' in node:
			node.astar = astar
			node.room_size = room_size
			node.grid_size = grid_size
			node.cell_size = cell_size

