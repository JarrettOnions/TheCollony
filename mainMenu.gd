#mainMenu.gd
extends Control

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://World.tscn")


func _on_options_button_pressed() -> void:
	print("Options pressed")


func _on_quit_button_pressed() -> void:
	print("Quit pressed")
	get_tree().quit()
