# AntSpawner.gd   # colony handler
extends Node2D
class_name AntSpawner

@export var queen_scene: PackedScene
@export var minim_scene: PackedScene
@export var medea_scene: PackedScene
@export var major_scene: PackedScene
@export var mega_scene: PackedScene
@export var ultra_scene: PackedScene

var colony_food: int = 800

var minim_spawn_cost: int = 10
var medea_spawn_cost: int = 20
var major_spawn_cost: int = 40
var mega_spawn_cost: int = 200
var ultra_spawn_cost: int = 400

var queen_spawned: bool = false

@onready var food_score_label = get_node("/root/World/UI/FoodScoreLabel")

@onready var spawn_queen_timer = get_node("/root/World/SpawnQueenTimer")

@onready var spawn_queen_button = get_node("/root/World/UI/Buttons/SpawnQueenButton")
@onready var spawn_minim_button = get_node("/root/World/UI/Buttons/SpawnMinimButton")
@onready var spawn_medea_button = get_node("/root/World/UI/Buttons/SpawnMedeaButton")
@onready var spawn_major_button = get_node("/root/World/UI/Buttons/SpawnMajorButton")
@onready var spawn_mega_button = get_node("/root/World/UI/Buttons/SpawnMegaButton")
@onready var spawn_ultra_button = get_node("/root/World/UI/Buttons/SpawnUltraButton")

signal ant_spawned(ant: Node2D)
signal food_changed(new_food: int) # Add a signal for food changes

func _ready():
	# Connect signals for spawning
	spawn_minim_button.pressed.connect(_on_spawn_minim_button_pressed)
	spawn_medea_button.pressed.connect(_on_spawn_medea_button_pressed)
	spawn_major_button.pressed.connect(_on_spawn_major_button_pressed)
	spawn_mega_button.pressed.connect(_on_spawn_mega_button_pressed)
	spawn_ultra_button.pressed.connect(_on_spawn_ultra_button_pressed)
	spawn_queen_button.pressed.connect(_on_spawn_queen_button_pressed)
	
	spawn_queen_timer.timeout.connect(_on_spawn_queen_timer_timeout)

	update_food_score_label()

func add_food(amount: int):
	colony_food += amount
	update_food_score_label()
	emit_signal("food_changed", colony_food) # Emit the signal

func update_food_score_label():
	if is_instance_valid(food_score_label):
		food_score_label.text = "Food: " + str(colony_food)
	else:
		printerr("Food Score Label is not valid!")

### Spawning Functions ###
func spawn_queen():
	var queen = queen_scene.instantiate()
	queen.position =  Vector2(randf_range(-400, 400), randf_range(-400, 400))
	get_parent().add_child(queen)
	queen_spawned = true
	emit_signal("ant_spawned", queen)
	spawn_queen_button.set_visible(false)

func _on_spawn_queen_button_pressed():
	if not queen_spawned:
		spawn_queen_timer.start()
	#	spawn_queen_button.set_disabled(true)
	else:
		print("Queen already spawned")

func _on_spawn_queen_timer_timeout():
	spawn_queen()


func _on_spawn_minim_button_pressed():
	if colony_food >= minim_spawn_cost:
		colony_food -= minim_spawn_cost
		update_food_score_label()
		spawn_minim()
	else:
		print("Not enough food to spawn minim")

func spawn_minim():
	var queen = get_node("/root/World/AntSpawner/QueenAnt")
	if queen:
		var minim = minim_scene.instantiate()
		var spawn_position = queen.position + Vector2(randf_range(-200, 200), randf_range(-100, 100))
		minim.position = spawn_position
		get_parent().add_child(minim)
		emit_signal("ant_spawned", minim)
	else:
		print("Queen Ant not found, cannot spawn minim")

func _on_spawn_medea_button_pressed():
	if colony_food >= medea_spawn_cost:
		colony_food -= medea_spawn_cost
		update_food_score_label()
		spawn_medea()
	else:
		print("Not enough food to spawn medea")

func spawn_medea():
	var queen = get_node("/root/World/AntSpawner/QueenAnt")
	if queen:
		var medea = medea_scene.instantiate()
		var spawn_position = queen.position + Vector2(randf_range(-200, 200), randf_range(-200, 200))
		medea.position = spawn_position
		get_parent().add_child(medea)
		emit_signal("ant_spawned", medea)
	else:
		print("Queen Ant not found, cannot spawn medea")

func _on_spawn_major_button_pressed():
	if colony_food >= major_spawn_cost:
		colony_food -= major_spawn_cost
		update_food_score_label()
		spawn_major()
	else:
		print("Not enough food to spawn major")

func spawn_major():
	var queen = get_node("/root/World/AntSpawner/QueenAnt")
	if queen:
		var major = major_scene.instantiate()
		var spawn_position = queen.position + Vector2(randf_range(-400, 400), randf_range(-400, 400))
		major.position = spawn_position
		get_parent().add_child(major)
		emit_signal("ant_spawned", major)
	else:
		print("Queen Ant not found, cannot spawn major")

func _on_spawn_mega_button_pressed():
	if colony_food >= mega_spawn_cost:
		colony_food -= mega_spawn_cost
		update_food_score_label()
		spawn_mega()
	else:
		print("Not enough food to spawn mega")

func spawn_mega():
	var queen = get_node("/root/World/AntSpawner/QueenAnt")
	if queen:
		var mega = mega_scene.instantiate()
		var spawn_position = queen.position + Vector2(randf_range(-300, 300), randf_range(-300, 300))
		mega.position = spawn_position
		get_parent().add_child(mega)
		emit_signal("ant_spawned", mega)
	else:
		print("Queen Ant not found, cannot spawn mega")

func _on_spawn_ultra_button_pressed():
	if colony_food >= ultra_spawn_cost:
		colony_food -= ultra_spawn_cost
		update_food_score_label()
		spawn_ultra()
	else:
		print("Not enough food to spawn ultra")

func spawn_ultra():
	var queen = get_node("/root/World/AntSpawner/QueenAnt")
	if queen:
		var ultra = ultra_scene.instantiate()
		var spawn_position = queen.position + Vector2(randf_range(-300, 300), randf_range(-300, 300))
		ultra.position = spawn_position
		get_parent().add_child(ultra)
		emit_signal("ant_spawned", ultra)
	else:
		print("Queen Ant not found, cannot spawn ultra")
