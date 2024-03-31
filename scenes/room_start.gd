extends Node2D

#PHASE CONTROL
var phase = 0
var timer = 0
var next = false

#PHASE SPECIFIC VARIABLES
var player
var loot_tutorial
var gun_tutorial
var sword_tutorial

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node('player')
	if player == null:
		print('start room could not find player')
		
	#REMOVE FROM TREE SO IT DOES NO INTERFERE
	loot_tutorial = $loot_tutorial
	remove_child(loot_tutorial)
	gun_tutorial = $gun_tutorial
	remove_child(gun_tutorial)
	sword_tutorial = $sword_tutorial
	remove_child(sword_tutorial)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if next:
		timer += delta
	
	#MOVEMENT PHASEr
	if phase == 0:
		player.level_points = 0
		$move_tutorial.show()
		if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_left"):
			next = true
		
		if timer > 4:
			phase += 1
			timer = 0
			next = false
			$move_tutorial.hide()
			player.dash_cooldown_progress = 0
	#DASH PHASE
	elif phase == 1:
		$dash_tutorial.show()
		if Input.is_action_just_pressed("dash"):
			next = true
			
		if timer > 2:
			phase += 1
			timer = 0
			next = false
			$dash_tutorial.hide()
			add_child(loot_tutorial)
	#LOOT PHASE
	elif phase == 2:
		var health = get_node_or_null('loot_tutorial/health')
		var expirience = get_node_or_null('loot_tutorial/expirience')
		var ammo = get_node_or_null('loot_tutorial/ammo')
		
		if (ammo == null) and (expirience == null) and (health == null):
			next = true
			
		if timer > 2:
			phase += 1
			timer = 0
			next = false
			$loot_tutorial.hide()
			add_child(gun_tutorial)
	#GUN PHASE
	elif phase == 3:
		player.gun_cooldown = 1
		player.ammo = 5
		player.level_points = 0
		var dummy_1 = get_node_or_null('gun_tutorial/gun_dummy_1')
		var dummy_2 = get_node_or_null('gun_tutorial/gun_dummy_2')
		
		if (dummy_1 == null) and (dummy_2 == null):
			next = true
			
		if timer > 2:
			phase += 1
			timer = 0
			next = false
			player.gun_cooldown = 5              #PUT IN STARTING COOLDOWN HERE
			add_child(sword_tutorial)
			$gun_tutorial.hide()
	#SWORD PHASE
	elif phase == 4:
		player.sword_cooldown = 1
		player.level_points = 0
		var dummy_1 = get_node_or_null('sword_tutorial/sword_dummy_1')
		var dummy_2 = get_node_or_null('sword_tutorial/sword_dummy_2')
		var dummy_3 = get_node_or_null('sword_tutorial/sword_dummy_3')
		
		if (dummy_1) == null and (dummy_2 == null) and (dummy_3 == null):
			next = true
			
		if timer > 2:
			phase += 1
			timer = 0
			next = false
			player.sword_cooldown = 5              #PUT IN STARTING COOLDOWN HERE
			$sword_tutorial.hide()
			$level_tutorial.show()
			player.level_points = 5
	elif phase == 5:
		#Upgrade Tutorial
		if player.level_points < 5:
			next = true
		
		if timer > 2:
			next = false
			$level_tutorial.hide()
			phase += 1
	else:
		$objective_tutorial.show()
		var doors = get_node_or_null('doors')
		if doors != null:
			doors.queue_free()
