class_name Enemy
extends Area3D
## Basic enemy. Drifts toward +Z with a sine sway and tumbles for depth.

@export var speed: float = 5.0
@export var sway_amplitude: float = 1.5
@export var sway_frequency: float = 2.0
@export var spin_speed: float = 2.0
@export var points: int = 100
@export var despawn_z: float = 9.0

var _time: float = 0.0
var _base_x: float = 0.0

@onready var mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	_base_x = position.x
	_time = randf() * TAU
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	_time += delta
	position.z += speed * delta
	position.x = _base_x + sin(_time * sway_frequency) * sway_amplitude
	mesh.rotate_y(spin_speed * delta)
	mesh.rotate_x(spin_speed * 0.5 * delta)
	if position.z > despawn_z:
		queue_free()


func die() -> void:
	queue_free()


func _on_area_entered(area: Area3D) -> void:
	var player := area as Player
	if player:
		player.hit()
		die()
