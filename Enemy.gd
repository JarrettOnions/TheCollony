extends CharacterBody2D

class_name Enemy

@export var enemy_name = "Spider"
@export var health = 100
var max_health = health
@export var health_bar = TextureProgressBar

@export var attack_damage = 10
@export var speed = 20.0
@export var ant_detection_radius = 300.0
@export var attack_range = 150
@export var attack_rate = 0.5
var time_since_last_attack = 0

var target_queen = null
var target_ant = null
var ants = []
var delta_time : float


func _ready():
	set_target_queen(get_node("/root/World/AntSpawner/QueenAnt"))
	#ants = getChildren
	#ants = get_node("/root/World/AntSpawner").get_children()
	ants = get_tree().get_nodes_in_group("Ants")
	#get_child_count(get_node("/root/World/AntSpawner"))
	#get_child(get_node("/root/World/AntSpawner"))
	pass

func set_target_queen(queen_node): #Sets queen as the primary target
	target_queen = queen_node
	target_ant = null

func set_ant_list(ant_array): #Sets the array of ant nodes
	ants = ant_array

func find_closest_ant(): #Finds the closest ant within the detection radius
	var closest_ant = null
	var min_distance_sq = INF

	for ant in ants:
		if is_instance_valid(ant):
			var distance_vector = ant.global_position - global_position
			var distance_sq = distance_vector.length_squared()
			if distance_sq <= ant_detection_radius * ant_detection_radius:
				if distance_sq < min_distance_sq:
					min_distance_sq = distance_sq
					closest_ant = ant
		else:
			# Clean up invalid ants from the list
			ants.erase(ant)
			break # Important to break after erasing to avoid index issues
	return closest_ant

func move_towards_target(target_node, delta):
	if is_instance_valid(target_node):
		var direction = (target_node.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		self.velocity = velocity
	else:
		target_ant = null

func attack(target_node):
	
	time_since_last_attack = 0
	
	if is_instance_valid(target_node):
		if target_node.has_method("take_damage"):
			target_node.take_damage(attack_damage)
			#print("%s attacks %s for %s damage. %s's health: %s" % [enemy_name, target_node.name, attack_damage, target_node.name, target_node.health])
#			if target_node.health <= 0:
				#print("%s has been defeated!" % target_node.name)
#				return true # Target defeated
#		elif has_node(target_node.get_path() + "/health"): # Fallback for a Value node
#			target_node.get_node("health").value -= attack_damage
			
			#print("%s attacks %s for %s damage. %s's health: %s" % [enemy_name, target_node.name, attack_damage, target_node.name, target_node.get_node("health").value])
#			if target_node.get_node("health").value <= 0:
				#print("%s has been defeated!" % target_node.name)
#				return true
#		else:
#			printerr("Target does not have a 'take_damage' method or a 'health' node.")
	
	return false

func _physics_process(delta):
	delta_time = delta
	time_since_last_attack += delta
	
	#ants = get_node("/root/World/AntSpawner").get_children()
	ants = get_tree().get_nodes_in_group("Ants")
	
	if is_instance_valid(target_queen):
		#print("target queen found:")
		var closest_ant = find_closest_ant()
		#print("closest ant found")

		if closest_ant:
			target_ant = closest_ant
			move_towards_target(target_ant, delta)
			var distance_to_ant_sq = (target_ant.global_position - global_position).length_squared()
			if distance_to_ant_sq <= attack_range * attack_range:
				if (time_since_last_attack > attack_rate):
					if attack(target_ant):
						# The 'attack' function now handles checking health and returning true if defeated
						ants.erase(target_ant) # Remove from the local list
						if is_instance_valid(target_ant): # Double-check before freeing
							target_ant.queue_free() # Assuming ants are Nodes that can be freed
						target_ant = null # Reset target
		else:
			# No ants nearby, move towards the queen
			move_towards_target(target_queen, delta)
			var distance_to_queen_sq = (target_queen.global_position - global_position).length_squared()
			if distance_to_queen_sq <= attack_range * attack_range:
				attack(target_queen)
	elif is_instance_valid(target_ant):
		print("target ant: " + target_ant)
		move_towards_target(target_ant, delta)
		var distance_to_ant_sq = (target_ant.global_position - global_position).length_squared()
		if distance_to_ant_sq <= attack_range * attack_range:
			if attack(target_ant):
				ants.erase(target_ant)
				if is_instance_valid(target_ant):
					target_ant.queue_free()
				target_ant = null
	else:
		velocity = Vector2.ZERO
		#wander_timer -= delta_time
		#if wander_timer_timeout == true: 
		wander(delta)
		
		move_and_slide()


func take_damage(damage):
	health -= damage
	#print("%s took %s damage. Health: %s" % [enemy_name, damage, health])
	health_bar.value = health * 100 / max_health
	if health <= 0:
		queue_free()


func wander(delta):
	#if velocity == Vector2.ZERO:
	#	velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision: #basic collision avoidance, change direction of movement.
		velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	
	if randf() < 0.0001: #change direction sometimes
		velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	#check if stuck
