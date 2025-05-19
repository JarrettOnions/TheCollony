extends Node2D    # FoodSpawner

@export var food_scene: PackedScene
@export var spawn_radius: float = 200.0

@onready var food_timer = $FoodTimer

func _ready():
	food_timer.timeout.connect(_on_food_timer_timeout)

func _on_food_timer_timeout():
	spawn_food()

func spawn_food():
	if food_scene:
		var food = food_scene.instantiate()
		var random_offset = Vector2(randf_range(-spawn_radius, spawn_radius), randf_range(-spawn_radius, spawn_radius))
		var spawn_position = position + random_offset #use the spawner's position
		food.position = spawn_position
		get_parent().add_child(food)
	else:
		print("Food scene not set in FoodSpawner!")
