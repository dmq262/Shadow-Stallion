extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var health_scene: PackedScene
@export var ammo_scene: PackedScene
@export var expirience_scene: PackedScene
@export var blood_splatter_scene: PackedScene
@export var sound_enemy_damage_scene: PackedScene

@export var active = false
var player
var cooldown = 2
var cooldown_progress = 2
var health = 100
var bullet_speed = 350
@export var damage = 25

func scale_enemy(level):
	health *= 1.5 ** (level - 1)
	cooldown -= .1 * (level-1)
	bullet_speed *= 1.3 ** (level -1)
	damage *= 1.5 ** (level - 1)

func _ready():
	cooldown_progress = randf_range(0, cooldown)
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
	bullet.speed = bullet_speed
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.add_to_group("enemy_bullet")
	get_tree().current_scene.add_child(bullet)
	
	$sound_gunshot.play()

func hit(damage):
	health -= damage
	
	var blood_splatter = blood_splatter_scene.instantiate()
	blood_splatter.global_position = global_position
	get_tree().current_scene.add_child(blood_splatter)
	get_tree().current_scene.move_child(blood_splatter, 0)
	
	var sound_damage = sound_enemy_damage_scene.instantiate()
	get_tree().current_scene.add_child(sound_damage)

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
