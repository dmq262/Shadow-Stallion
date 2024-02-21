extends CharacterBody2D

var CELL_SIZE = 32

var path = []
var destination = Vector2(0, 0)
var current = Vector2(0, 0)
var target = Vector2(0, 0)
var astar_grid = AStarGrid2D.new()
var speed = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	astar_grid.region = Rect2i(0, 0, get_viewport().size.x / CELL_SIZE + 1, get_viewport().size.y / CELL_SIZE + 1)
	astar_grid.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	astar_grid.update()
	print(astar_grid.get_id_path(Vector2i(0, 0), Vector2i(3, 4)))
	print(astar_grid.get_point_path(Vector2i(0, 0), Vector2i(3, 4)))
	
	astar_grid.fill_solid_region(Rect2i((get_node('../test_wall').position.x - 16) / CELL_SIZE, (get_node('../test_wall').position.y - 16) / CELL_SIZE, 4, 4))
	astar_grid.fill_solid_region(Rect2i((get_node('../test_wall2').position.x - 16) / CELL_SIZE, (get_node('../test_wall2').position.y - 16) / CELL_SIZE, 4, 4))
	astar_grid.fill_solid_region(Rect2i((get_node('../test_wall3').position.x - 16) / CELL_SIZE, (get_node('../test_wall3').position.y - 16) / CELL_SIZE, 4, 4))
	astar_grid.fill_solid_region(Rect2i((get_node('../test_wall4').position.x - 16) / CELL_SIZE, (get_node('../test_wall4').position.y - 16) / CELL_SIZE, 4, 4))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#Determine the current position of the node, convert it to grid
	current = position / CELL_SIZE
	current.x = roundf(current.x)
	current.y = roundf(current.y)
	
	#Set new path on mouse click
	if Input.is_action_just_pressed("shoot"):
		destination = get_global_mouse_position() / CELL_SIZE
		destination.x = roundf(destination.x)
		destination.y = roundf(destination.y)
		
		path = astar_grid.get_id_path(current, destination)
		if not path.is_empty():
			target = path.pop_front()
	
	#Get next cell in path
	if not path.is_empty() and current == Vector2(target):
		target = path.pop_front()
		
	velocity = (Vector2(target) - current).normalized()
	
	var collision = move_and_collide(velocity * delta * speed)
	
	if collision:
		velocity = velocity.slide(collision.get_normal())
		move_and_collide(velocity * delta * speed)
		
	
	
