extends Node2D #FoodItem.gd

@export var food_value: int = 10  # The amount of food this item provides
@export var pickup_distance: float = 30 #how close an ant has to be.

signal picked_up(food_value)  # Signal emitted when the food is picked up

var is_picked_up = false

func _ready():
	pass

func pickup():
	if is_picked_up:
		return
	is_picked_up = true
	emit_signal("picked_up", food_value)
	queue_free()  # Remove the food item from the scene
	print("Food item picked up! Value:", food_value)
