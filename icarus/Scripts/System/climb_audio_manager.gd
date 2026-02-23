extends Node3D

@export var climb_win_sfx : AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func play_climb_win_sfx():
	climb_win_sfx.play()
