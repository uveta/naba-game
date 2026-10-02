extends Area3D
## Player bullet. Flies toward -Z and destroys the first enemy it touches.

@export var speed: float = 25.0
@export var despawn_z: float = -32.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position.z -= speed * delta
	if position.z < despawn_z:
		queue_free()


func _on_area_entered(area: Area3D) -> void:
	if is_queued_for_deletion() or area.is_queued_for_deletion():
		return
	var enemy := area as Enemy
	if enemy:
		GameState.add_score(enemy.points)
		enemy.die()
		queue_free()
