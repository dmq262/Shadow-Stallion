extends Area2D

var direction = Vector2(1, 1)
var speed = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += speed * direction * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("enemy") and is_in_group("player_bullet"):
		body.queue_free()
		queue_free()
	elif body.is_in_group("player") and is_in_group("enemy_bullet"):
		queue_free()
	elif body.is_in_group("wall"):
		queue_free()
