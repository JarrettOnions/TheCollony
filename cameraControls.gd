# camera controlls - pan, zoom
extends Camera2D

@export var max_drag_speed: float = 1.0  # Max speed when far from edges
@export var min_drag_speed: float = 0.2  # Slowest speed near edges
@export var bounds_min: Vector2 = Vector2(-300, -200)  # Top-left boundary
@export var bounds_max: Vector2 = Vector2(300, 500)    # Bottom-right boundary
@export var edge_slowdown_distance: float = 150.0  # Distance to start slowing

@export var zoom_min: float = 0.5  # Minimum zoom level
@export var zoom_max: float = 4.0  # Maximum zoom level
@export var zoom_speed: float = 0.02  # How fast zooming happens



var dragging: bool = false
var last_touch_pos: Vector2
var last_pinch_distance: float = 0.0  # For pinch tracking

func _ready():
	set_process_unhandled_input(true) #was commented
	pass

func _unhandled_input(event):
	#if not touching unit
	if event is InputEventMouseButton:
		if event.pressed:
			dragging = true
			last_touch_pos = event.position
		else:
			dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		handle_drag(event.position)

	elif event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			last_touch_pos = event.position
		else:
			dragging = false

	elif event is InputEventScreenDrag and dragging:
		handle_drag(event.position)

	elif event is InputEventMagnifyGesture:
		handle_pinch_zoom(event.factor)

func handle_drag(current_pos: Vector2):
	var delta = current_pos - last_touch_pos
	last_touch_pos = current_pos

	var speed_x = get_dynamic_drag_speed(position.x, bounds_min.x, bounds_max.x)
	var speed_y = get_dynamic_drag_speed(position.y, bounds_min.y, bounds_max.y)

	var new_position = position - Vector2(delta.x * speed_x, delta.y * speed_y)
	new_position.x = clamp(new_position.x, bounds_min.x, bounds_max.x)
	new_position.y = clamp(new_position.y, bounds_min.y, bounds_max.y)

	position = new_position

func handle_pinch_zoom(factor: float):
	# Adjust zoom based on pinch factor
	var new_zoom = zoom * factor
	new_zoom.x = clamp(new_zoom.x, zoom_min, zoom_max)
	new_zoom.y = clamp(new_zoom.y, zoom_min, zoom_max)
	
	zoom = new_zoom

func get_dynamic_drag_speed(pos: float, min_bound: float, max_bound: float) -> float:
	var dist_min = abs(pos - min_bound)
	var dist_max = abs(pos - max_bound)
	var min_distance = min(dist_min, dist_max)
	var factor = clamp(min_distance / edge_slowdown_distance, 0.0, 1.0)
	return lerp(min_drag_speed, max_drag_speed, factor)
