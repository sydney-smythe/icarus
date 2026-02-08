extends Node3D

var model
@export_group("Model Positioning")
@export var model_scale : float = 1.0 
@export var model_position_offest : Vector3 = Vector3(0,0,0)
@export var model_rotation_offest : Vector3 = Vector3(0,0,0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	model = get_child(0)
	model.scale = Vector3(model_scale,model_scale,model_scale)
	model.position = model_position_offest
	model.rotation_degrees = model_rotation_offest


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
