extends Node3D

@export var accept_sfx : AudioStreamPlayer
@export var back_sfx : AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func play_accept():
	accept_sfx.play()

func play_back():
	back_sfx.play()
