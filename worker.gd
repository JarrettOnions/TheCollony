extends CharacterBody2D


@export var unit_name = "worker"

@export var health = 200
var max_health = health
@export var health_bar = TextureProgressBar

@export var speed = 40.0


var carrying_food = false
var carried_food_value = 0

var stuck_timer = 0.0  # Timer to detect if the ant is stuck
var last_position = Vector2.ZERO
var unstuck_timer = 0.0
var is_unsticking = false

signal food_collected(food_value)

signal state_changed(state)
enum State {IDLE, WALK, ROAM, FORAGE, ATTACK, FLEE}
var _state = State.IDLE

func _set_state(state):
	_state = state
	emit_signal("state_changed", _state)

"""
func _process (delta): #all state changes go here
	match _state:
		State.IDLE:
			if not is_on_floor():
				_set_state(State.FALL)
			elif _input.x != 0:
				_set_state(State.WALK)
		State.FALL:
			if is_on_floor():
				_set_state(State.WALK)
		#etc..
"""


func _ready():
	last_position = position

func _physics_process(delta):

	if is_unsticking:
		unstuck_timer -= delta
		if unstuck_timer <= 0:
			is_unsticking = false  # Resume normal behavior
		return


	if not carrying_food:
		# Find the nearest food item
		var closest_food = find_closest_food()
		if closest_food:
			# Move towards the food
			var direction_to_food = (closest_food.position - position).normalized()
			velocity = direction_to_food * speed
			move_and_collide(velocity * delta)

			# Check if we're close enough to pick up the food
			if position.distance_to(closest_food.position) < closest_food.pickup_distance:
				pickup_food(closest_food)
		else:
			#wander
			wander(delta)
	else:
		#move back to the queen
		return_to_queen(delta)


func wander(delta):

	if velocity == Vector2.ZERO:
		velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed

	var collision = move_and_collide(velocity * delta)

	if collision:
		#basic collision avoidance, change direction of movement.
		velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	if randf() < 0.0001: #change direction sometimes
		velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	#check if stuck
	check_if_stuck(delta)

func return_to_queen(delta):
	var queen = get_node("/root/World/AntSpawner/QueenAnt") #path to queen, change if needed
	if queen:
		var direction_to_queen = (queen.position - position).normalized()
		velocity = direction_to_queen * speed
		move_and_collide(velocity * delta)
		if position.distance_to(queen.position) < 140: #close enough
			deposit_food()
		else:
			check_if_stuck(delta)
	else:
		print("Queen not found!")

func find_closest_food():
	var closest_food_item = null
	var closest_distance = INF
	for node in get_tree().get_nodes_in_group("Food"): # খাদ্য
		if node is Node and node.has_method("pickup"): # Check the node has pickup()
			var distance = position.distance_to(node.position)
			if distance < closest_distance:
				closest_distance = distance
				closest_food_item = node
	return closest_food_item

func pickup_food(food_item):
	carrying_food = true
	carried_food_value = food_item.food_value
	emit_signal("food_collected", carried_food_value)
	food_item.pickup()  # Call the pickup function in FoodItem.gd
	print("Worker picked up food! Value:", carried_food_value)

func deposit_food():
	carrying_food = false
	#add food to colony.
	var world = get_node("/root/World/AntSpawner") #get world node
	if world:
		world.add_food(carried_food_value) # Add food to the world's food count
	carried_food_value = 0
	print("Worker deposited food")


func check_if_stuck(delta):
	if is_unsticking:
		unstuck_timer -= delta
		if unstuck_timer <= 0:
			is_unsticking = false  # Resume normal behavior
		return

	if position.distance_to(last_position) < 1: #moved less than 1 pixel
		stuck_timer += delta
		if stuck_timer > 1.5: #stuck for more than 1.5 seconds
			unstick_ant()
	else:
		stuck_timer = 0
	last_position = position


func unstick_ant():
	is_unsticking = true
	unstuck_timer = 1.5  # Force movement for 1.5 seconds

	# Try up to 5 times to find a valid, open direction
	for i in range(5):
		var new_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var test_position = position + (new_direction * 10)  # Move slightly further
		if !is_colliding_with_solid(test_position):  # Only change if the path is clear
			velocity = new_direction * speed
			move_and_slide()  # Apply movement immediately
			print("Ant unsticking in new direction:", new_direction)
			return

	# If no good direction found, just pick a random one
	velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	move_and_slide()  # Apply movement immediately
	print("Ant stuck badly, using random direction")


func is_colliding_with_solid(test_position):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = test_position
	query.collision_mask = 1  # Adjust based on your collision layers
	query.collide_with_areas = true  # Ensure it detects all collisions
	var result = space_state.intersect_point(query)
	return result.size() > 0
	
func take_damage(damage):
	health -= damage
	#print("%s took %s damage. Health: %s" % [unit_name, damage, health])
	health_bar.value = health * 100 / max_health
	if health <= 0:
		queue_free()
