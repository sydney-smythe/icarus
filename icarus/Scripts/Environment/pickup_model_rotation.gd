extends Node3D

var model
@export var horiz_rot_speed = 60 # deg / sec
var rad_horiz_rot_speed
var model_set : bool = false
	
var time = 0.0
var frequency = 2.0
var vertical_amplitude = 0.2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rad_horiz_rot_speed = deg_to_rad(horiz_rot_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if model_set:
		rotate_object_local(Vector3(0, 1, 0), rad_horiz_rot_speed * delta)
	
	time += delta  # this scares me tbh
	# Moves up and down over the original position
	model.position.y = (sin(time * frequency) * vertical_amplitude) + vertical_amplitude

func disable_model():
	model_set = false

func set_model():
	call_deferred_thread_group('deferred_set_model')  # wait to call the update til next frame cus queue_free

func deferred_set_model():
	model = get_child(0)
	model_set = true
	
