# soldier.gd
extends CharacterBody2D

class_name Soldier

@export var unit_name = "Soldier"
@export var health = 300
var max_health = health
@export var health_bar = TextureProgressBar

@export var speed = 40.0
@export var wanderRange: int = 400

@export var attack_damage = 15
@export var attack_range = 120.0 # Range within which the soldier can attack
@export var attack_cooldown = 0.5 # Time in seconds between attacks
var time_since_last_attack = 0.0

@export var detection_radius = 300.0 # Range to detect enemies

var current_target_enemy = null

enum unitState {idle, roam, chase, attack} 

func _ready():
	pass

func _physics_process(delta):
	time_since_last_attack += delta
	#if wander: #have various states: idle, following instruction, circle, roam, 
	wander_around_queen(delta)
	
	if current_target_enemy and is_instance_valid(current_target_enemy):
		#print("Soldier moving towards:", current_target_enemy.name, "at", current_target_enemy.global_position) # Check this
		var direction = (current_target_enemy.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		self.velocity = velocity
	
		# Check if within attack range
		if global_position.distance_to(current_target_enemy.global_position) <= attack_range:
			attack_enemy(current_target_enemy)
	else:
		# If no target, look for nearby enemies
		find_nearby_enemy()
		velocity = Vector2.ZERO
		move_and_slide()
		self.velocity = velocity


func wander_around_queen(delta):
	var queen = get_node("/root/World/AntSpawner/QueenAnt")  # Make sure this path is correct!
	if queen:
		var direction_to_queen = (queen.position - position).normalized()
		velocity = Vector2.RIGHT.rotated(direction_to_queen.angle() + PI/2) * speed #makes them go in a circle
		move_and_collide(velocity * delta)
		if position.distance_to(queen.position) > wanderRange: #if they get too far
			position = position.move_toward(queen.position, 1) #move back
	else:
		print("Queen Ant not found!")
		#have a timer...
		queue_free() #remove self if no queen



func find_nearby_enemy(): #Finds the closest enemy within the detection radius.
	var closest_enemy = null
	var min_distance_sq = INF

	var enemies = get_tree().get_nodes_in_group("Enemies")
	#print(enemies)

	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"): # Ensure it's a valid enemy
			#print (enemy)
			var distance_vector = enemy.global_position - global_position
			var distance_sq = distance_vector.length_squared()
			if distance_sq <= detection_radius * detection_radius:
				if distance_sq < min_distance_sq:
					min_distance_sq = distance_sq
					closest_enemy = enemy
					print(closest_enemy)
	current_target_enemy = closest_enemy
	#print(current_target_enemy)

func attack_enemy(enemy):
	if is_instance_valid(enemy) and enemy.has_method("take_damage") and time_since_last_attack >= attack_cooldown:
		enemy.take_damage(attack_damage)
		#print("%s attacks %s for %s damage!" % [soldier_name, enemy.enemy_name if enemy.has_property("enemy_name") else enemy.name])
		time_since_last_attack = 0.0
	elif not is_instance_valid(enemy):
		current_target_enemy = null

func take_damage(damage):
	health -= damage
	#print("%s took %s damage. Health: %s" % [unit_name, damage, health])
	health_bar.value = health * 100 / max_health
	if health <= 0:
		queue_free()
