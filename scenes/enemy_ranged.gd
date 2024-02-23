extends CharacterBody2D

@export var bullet_scene: PackedScene

const SPEED = 300.0
var player
var cooldown = 3
var cooldown_progress = 3

func _ready():
	player = get_tree().current_scene.get_node('player')
	if player == null:
		print('player not found')

func _physics_process(delta):
	if player == null:
		return
		
	look_at(player.position)
	
	if cooldown_progress <= 0:
		shoot_bullet()
		cooldown_progress = cooldown
	else:
		cooldown_progress -= delta
		

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = $gun_tip.global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.add_to_group("enemy_bullet")
	get_tree().current_scene.add_child(bullet)