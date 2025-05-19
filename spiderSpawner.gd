extends Node2D    # EnemySpawner

@export var enemy_scene: PackedScene
@export var spawn_radius: float = 200.0

@onready var enemy_timer = $EnemyTimer

func _ready():
	enemy_timer.timeout.connect(_on_enemy_timer_timeout)

func _on_enemy_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		var random_offset = Vector2(randf_range(-spawn_radius, spawn_radius), randf_range(-spawn_radius, spawn_radius))
		var spawn_position = position + random_offset #use the spawner's position
		enemy.position = spawn_position
		get_parent().add_child(enemy)
	else:
		print("Enemy scene not set in spiderSpawner!")
