extends Node3D

@onready var primary_fire_audio: AudioStreamPlayer3D = $"Primary Fire Audio"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func play_primary_audio():
	primary_fire_audio.play()
