extends Node3D
## Root of the game scene: spawns enemies and handles restart.

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemy.tscn")

@export var spawn_x_range: float = 6.0
@export var spawn_z: float = -30.0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemies: Node3D = $Enemies


func _ready() -> void:
	GameState.reset()
	GameState.game_over.connect(_on_game_over)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func _unhandled_input(event: InputEvent) -> void:
	if not GameState.is_game_over:
		return
	var tapped: bool = event is InputEventScreenTouch and event.pressed
	if tapped or event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_spawn_timer_timeout() -> void:
	var enemy := ENEMY_SCENE.instantiate() as Node3D
	enemy.position = Vector3(randf_range(-spawn_x_range, spawn_x_range), 0.0, spawn_z)
	enemies.add_child(enemy)


func _on_game_over() -> void:
	spawn_timer.stop()
