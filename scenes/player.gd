extends CharacterBody2D

const SPEED = 300
var dash_vector = Vector2(0, 0)
var dash_power = 20
var old_playback = 0

func _ready():
	pass

func _physics_process(delta):
	look_at(get_global_mouse_position())
	
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x +=1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -=1
	
	#Implement Dash Mechanic
	if Input.is_action_just_pressed("dash"):
		dash_vector = velocity.normalized() * dash_power
	if dash_vector.length() > .01:
		dash_vector -= delta * dash_vector.normalized() * 50
	
	var collision = move_and_collide(velocity.normalized() * delta * SPEED + dash_vector)
	
	#PROCESS PLAYER SOUNDS
	if velocity.length() > 0 and not $sound_footsteps.playing:
		$sound_footsteps.play()
	elif velocity.length() == 0 and $sound_footsteps.playing:
		$sound_footsteps.stop()
	
	if $sound_footsteps.get_playback_position() < old_playback:
		$sound_footsteps.pitch_scale = randf_range(.85, 1.15)
	old_playback = $sound_footsteps.get_playback_position()

