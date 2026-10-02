class_name Player
extends Area3D
## Player ship. Moves on the XZ plane, banks while strafing, shoots toward -Z.

const BULLET_SCENE: PackedScene = preload("res://scenes/bullet.tscn")
const BOUNDS_MIN: Vector2 = Vector2(-4.5, -12.0) # (x, z)
const BOUNDS_MAX: Vector2 = Vector2(4.5, 3.0)

@export var speed: float = 9.0
@export var fire_cooldown: float = 0.15
@export var max_roll_degrees: float = 25.0
@export var roll_smoothing: float = 10.0
@export var invulnerable_time: float = 1.5

var _cooldown: float = 0.0
var _invulnerable: float = 0.0

@onready var visual: Node3D = $Visual
@onready var muzzle: Marker3D = $Muzzle


func _ready() -> void:
	GameState.game_over.connect(_on_game_over)


func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position.x = clampf(position.x + input.x * speed * delta, BOUNDS_MIN.x, BOUNDS_MAX.x)
	position.z = clampf(position.z + input.y * speed * delta, BOUNDS_MIN.y, BOUNDS_MAX.y)

	var target_roll := -input.x * deg_to_rad(max_roll_degrees)
	visual.rotation.z = lerp_angle(visual.rotation.z, target_roll, roll_smoothing * delta)

	_cooldown -= delta
	if Input.is_action_pressed("shoot") and _cooldown <= 0.0:
		_shoot()

	if _invulnerable > 0.0:
		_invulnerable -= delta
		visual.visible = fmod(_invulnerable, 0.2) > 0.1 or _invulnerable <= 0.0


## Called by enemies on contact.
func hit() -> void:
	if _invulnerable > 0.0 or GameState.is_game_over:
		return
	GameState.lose_life()
	_invulnerable = invulnerable_time


func _shoot() -> void:
	_cooldown = fire_cooldown
	var bullet := BULLET_SCENE.instantiate() as Node3D
	get_parent().add_child(bullet)
	bullet.global_position = muzzle.global_position


func _on_game_over() -> void:
	set_physics_process(false)
	visible = false
	set_deferred("monitorable", false)
