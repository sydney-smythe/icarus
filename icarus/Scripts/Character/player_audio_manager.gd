extends Node3D

@onready var player: CharacterBody3D = $".."
@onready var footstep_audio: AudioStreamPlayer3D = $Footsteps

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	play_movement_audio()
	
func play_movement_audio():
	if not player.is_sliding and player.is_moving and player.is_on_floor():
		if player.is_sprinting:
			footstep_audio.pitch_scale = 1.5
		elif player.is_crouching:
			footstep_audio.pitch_scale = 0.7
		elif player.is_moving:
			footstep_audio.pitch_scale = 1.0
		if not footstep_audio.is_playing():
			footstep_audio.play()
	else:
		if footstep_audio.is_playing():
			footstep_audio.stop()
