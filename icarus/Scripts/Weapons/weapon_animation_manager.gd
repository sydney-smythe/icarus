extends Node3D

var model
@export_group("Model Positioning")
@export var model_scale : float = 1.0 
@export var model_position_offest : Vector3 = Vector3(0,0,0)
@export var model_rotation_offest : Vector3 = Vector3(0,0,0)
@export_group("Animation Data")
@export var primary_animation : String = "temp-fire"
@onready var animation_player = $Model/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	model = get_child(0)
	model.scale = Vector3(model_scale,model_scale,model_scale)
	model.position = model_position_offest
	model.rotation_degrees = model_rotation_offest
	


func play_primary_fire():
	if animation_player.current_animation == primary_animation:
		animation_player.stop(true)
	animation_player.play(primary_animation)
