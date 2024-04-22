extends Node2D

var decoration_images = [
	"res://art/archway.png"
   
	# Add as many paths as you have images
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var random_index = randi() % decoration_images.size()
	var texture = load(decoration_images[random_index])
	$Sprite.texture = texture



