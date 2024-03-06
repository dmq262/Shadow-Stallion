extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var health_scene: PackedScene
@export var ammo_scene: PackedScene
@export var expirience_scene: PackedScene
@export var blood_splatter_scene: PackedScene

const SPEED = 300.0
var active = false
var player
var cooldown = 2
var cooldown_progress = 2
var health = 100
var damage = 25

func _ready():
	cooldown_progress = randf_range(0, cooldown)
	active = false
	player = get_tree().current_scene.get_node('player')
	if player == null:
		print('player not found')

func _physics_process(delta):
	#Die when health reaches 0
	if health <= 0:
		die()
		
	#Do nothing if unable to find player, or not active
	if player == null or (not active):
		return
	
	look_at(player.position)
	
	#Shoot at player
	if cooldown_progress <= 0:
		shoot_bullet()
		cooldown_progress = cooldown
	else:
		cooldown_progress -= delta
		

#Helper Function for shooting at player
func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = $gun_tip.global_position
	bullet.damage = damage
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.add_to_group("enemy_bullet")
	get_tree().current_scene.add_child(bullet)

func hit(damage):
	health -= damage
	
	var blood_splatter = blood_splatter_scene.instantiate()
	blood_splatter.global_position = global_position
	get_tree().current_scene.add_child(blood_splatter)
	get_tree().current_scene.move_child(blood_splatter, 0)

func die():
	for i in range(randi_range(1, 4)):
		drop_loot(health_scene, "health", 20)
		
	for i in range(randi_range(2, 5)):
		drop_loot(ammo_scene, "ammo", 1)
		
	for i in range(randi_range(3, 7)):
		drop_loot(expirience_scene, "expirience", 7)
	
	queue_free()

func drop_loot(loot_scene, type, value):
	var loot = loot_scene.instantiate()
	loot.type = type
	loot.value = value
	loot.global_position = global_position
	loot.velocity = Vector2(randf_range(-7, 7), randf_range(-7, 7))
	get_tree().current_scene.add_child(loot)
