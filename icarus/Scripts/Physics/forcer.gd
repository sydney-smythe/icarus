extends Node3D

@export var force_strength : float = 1.0
@export var force_direction : Vector3 = Vector3(0,0,0)
@export var is_sustained : bool = false
@export var duration : float = 0.0
var timer : float = 0.0
var player : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# find the player
	player = $"../Player"
	timer = duration


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_sustained:
		player.forcer_vector += force_direction * force_strength
		queue_free()
	else:
		if timer > 0:
			player.forcer_vector += force_direction * force_strength
			timer -= delta
		else:
			queue_free()
