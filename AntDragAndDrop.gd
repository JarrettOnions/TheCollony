extends Node2D
class_name AntDragAndDrop

var selected_ant: CharacterBody2D = null
var dragging_ant: CharacterBody2D = null
var drag_offset: Vector2 = Vector2.ZERO
var move_target: Vector2 = Vector2.INF
var is_moving_to_target: bool = false
var ant_speed: float = 50.0
var stop_distance: float = 5.0

# Signals
@onready var antSpawner = get_node("/root/World/AntSpawner")
@onready var mainCamera = get_node("/root/World/Camera2D")

# Built-in Functions
func _ready():
	if is_instance_valid(antSpawner):
		antSpawner.ant_spawned.connect(_on_ant_spawned)
	else:
		printerr("AntSpawner node not found!")
	set_process_input(true)
	set_process(true)

func _process(delta):
	if is_moving_to_target and selected_ant:
		move_ant_to_target(delta)

func _input(event):
	var camera = get_viewport().get_camera_2d()
	if event is InputEventMouseButton:
		var global_position = camera.get_global_mouse_position() if camera else event.position
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				handle_mouse_left_click(global_position)
			else:
				handle_mouse_left_release()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			handle_mouse_right_click(global_position)

	elif event is InputEventScreenTouch:
		var global_position = camera.get_screen_transform().affine_inverse() * event.position if camera else event.position
		if event.pressed:
			handle_screen_touch(global_position)
		else:
			handle_screen_touch_release()

	elif (event is InputEventMouseMotion or event is InputEventScreenDrag) and dragging_ant:
		var global_position = camera.get_global_mouse_position() if camera else event.position
		dragging_ant.position = global_position - drag_offset


# Input Handling Functions
func handle_mouse_left_click(position: Vector2):
	var clicked_ant = get_ant_at_position(position)
	if clicked_ant:
		select_ant(clicked_ant)
		dragging_ant = clicked_ant
		drag_offset = position - clicked_ant.position
		is_moving_to_target = false
		move_target = Vector2.INF
	else:
		deselect_ant()
		dragging_ant = null
		is_moving_to_target = false
		move_target = Vector2.INF

func handle_mouse_left_release():
	dragging_ant = null

func handle_mouse_right_click(position: Vector2):
	if selected_ant:
		move_target = position
		is_moving_to_target = true
		dragging_ant = null

func handle_screen_touch(position: Vector2):
	var touched_ant = get_ant_at_position(position)
	if touched_ant:
		select_ant(touched_ant)
		dragging_ant = touched_ant
		drag_offset = position - touched_ant.position
		is_moving_to_target = false
		move_target = Vector2.INF
	else:
		deselect_ant()
		dragging_ant = null
		is_moving_to_target = false
		move_target = Vector2.INF
		

func handle_screen_touch_release():
	dragging_ant = null


# Helper Functions
func get_ant_at_position(position: Vector2) -> CharacterBody2D:
	var space_state = get_world_2d().direct_space_state
	if not space_state:
		printerr("Error: Direct space state is null!")
		return null
	var query_params = PhysicsPointQueryParameters2D.new()
	query_params.position = position
	query_params.collision_mask = 1
	var result = space_state.intersect_point(query_params)
	if result:
		var collider = result[0].collider
		if collider is CharacterBody2D:
			return collider
	return null

func move_ant_to_target(delta):
	if not selected_ant:
		return
	if selected_ant.position.distance_to(move_target) > stop_distance:
		var direction = (move_target - selected_ant.position).normalized()
		selected_ant.position += direction * ant_speed * delta
	else:
		is_moving_to_target = false
		move_target = Vector2.INF

func select_ant(ant: CharacterBody2D):
	selected_ant = ant

func deselect_ant():
	selected_ant = null

# Signal Handlers
func _on_ant_spawned(ant: Node2D):
	if ant is CharacterBody2D:
		print("Ant Spawned: ", ant, " at position: ", ant.global_position)
	else:
		printerr("Spawned ant is NOT a CharacterBody2D")
