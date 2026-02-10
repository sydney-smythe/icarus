extends Node3D

@export var force_strength : float = 1.0
@export var force_direction : Vector3 = Vector3(0,0,0)
@export var is_sustained : bool = false
@export var duration : float = 0.0
var timer : float = 0.0
var entity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# find the player
	entity = get_parent()
	timer = duration


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_sustained or duration == 0.0:
		entity.apply_force(force_strength, force_direction, false)
		queue_free()
	else:
		if timer > 0:
			entity.apply_force(force_strength, force_direction, false)
			timer -= delta
		else:
			queue_free()
