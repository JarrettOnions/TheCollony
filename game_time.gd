		#game_time.gd		#GameTimeLabel
extends Label

@export var survival_time = 1000
var time_left
var play_time = 0
@export var high_score = 150


@export var victory_screen: ColorRect
@onready var gameTimeLabel = get_node("/root/World/UI/GameTimeLabel")
@onready var label = get_node("root/World/UI/TimerLabel")


func _ready() -> void:
	victory_screen.visible = false

func _process(delta: float) -> void:

	play_time += delta
	gameTimeLabel.text = str(round(play_time))

	if (play_time > survival_time):
		end_game()


func end_game():
	gameTimeLabel.text = "Survival Complete!"
	Engine.time_scale = 0  # Pause
	victory_screen.visible = true  # Show victory screen

func _restart_game():
	Engine.time_scale = 1  # Unpause
	get_tree().reload_current_scene()  # Restart the level

func _on_restart_button_pressed() -> void:
	_restart_game()
