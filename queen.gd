#queen.gd
extends Node2D

@export var worker_scene: PackedScene
@export var food_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var spawn_radius: float = 100.0
@export var food_spawn_area_radius = 300
signal ant_spawned(ant) #add the signal

@export var health: float = 800
var max_health = health
@export var health_bar = TextureProgressBar

@export var speed: float = 10

var unit_name: String = "Queen"


var drifting = false
var drift_speed = 10.0
var drift_direction = Vector2.ZERO

var num_food_items

@export var victory_screen: ColorRect
@onready var gameTimeLabel = get_node("/root/World/UI/GameTimeLabel")

func _ready():
	num_food_items = randf_range(5,10)
#	if world.queen_spawned:
	spawn_food_items()

func spawn_food_items():
		for _i in range(num_food_items):
			var food = food_scene.instantiate()
			var random_offset = Vector2(randf_range(-food_spawn_area_radius, food_spawn_area_radius), randf_range(-food_spawn_area_radius, food_spawn_area_radius))
			var spawn_position = position + random_offset
			food.position = spawn_position
			add_child(food)
	# rather have the queen spawn random eggs.. 
	# all ants start as eggs that take a certain amount of time to grow

func _physics_process(delta):
	if drifting:
		position += drift_direction * drift_speed * delta
		# Optionally, add some randomness to the drift direction over time
		if randf() < 0.01:  # Adjust probability as needed
#			drift_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			drift_direction = Vector2((drift_direction.x + randf_range(-1, 1)) /2, (drift_direction.y + randf_range(-1, 1)) /2 ).normalized()
func start_drifting():
	if not drifting:
		drifting = true
		drift_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func stop_drifting():
	drifting = false


func spawn_worker():
	var worker = worker_scene.instantiate()
	var random_offset = Vector2(randf_range(-spawn_radius-100, spawn_radius+100),randf_range(-spawn_radius-100, spawn_radius+100))
	var spawn_position = position + random_offset
	worker.position = spawn_position
	get_parent().add_child(worker)
	ant_spawned.emit(worker) #emit
	print("Worker spawned at:", spawn_position)

func take_damage(damage):
	health -= damage
	health_bar.value = health * 100 / max_health
	#print("%s took %s damage. Health: %s" % [unit_name, damage, health])
	if health <= 0:
	
		gameTimeLabel.text = "Queen Defeated!"
		Engine.time_scale = 0  # Pause
		victory_screen.visible = true  # Show victory screen
		
		queue_free()
		#get_tree().change_scene_to_file("res://menu/mainMenu.tscn")
