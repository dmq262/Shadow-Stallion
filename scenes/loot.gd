extends Area2D

var player
var velocity = Vector2.ZERO
var acceleration = 10
var speed = 200
var type = "ammo"
var value = 20

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += velocity
	
	#Pick up if close enough
	if player and (player.global_position - global_position).length() < 30:
		player_pickup()
	#If in range, move towards player(scales with proximity)
	elif player:
		#velocity += ((player.global_position - global_position).normalized() * acceleration * delta * 2) / ((player.global_position - global_position).length() / 25)
		global_position += ((player.global_position - global_position).normalized() * delta * speed) / ((player.global_position - global_position).length() / 50)
	
	#Remove Initial velocity
	if velocity.length() != 0:
		var old_vel = velocity
		velocity -= velocity.normalized() * delta * acceleration
		
		if old_vel.length() < velocity.length():
			velocity = Vector2.ZERO


func player_pickup():
	if type == "health":
		player.health += value
	elif type == "ammo":
		player.ammo += value
	else:
		player.expirience += value
	
	queue_free()


func _on_body_entered(body):
	if body.is_in_group('player'):
		player = body


func _on_body_exited(body):
	if body.is_in_group('player'):
		player = null
