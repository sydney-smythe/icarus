extends Node3D

@onready var player: CharacterBody3D = $".."
@export var walk_sfx: AudioStreamPlayer3D 
@export var essence_blast_sfx : AudioStreamPlayer3D
@export var sliding_sfx : AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	play_movement_audio()
	
func play_movement_audio():
	if not player.is_sliding and sliding_sfx.is_playing():
		sliding_sfx.stop()
	elif player.is_sliding and not sliding_sfx.is_playing():
		sliding_sfx.play()
	
	if not player.is_sliding and player.is_moving and player.is_on_floor() and player.player_enabled:
		if player.is_sprinting:
			walk_sfx.pitch_scale = 1.5
		elif player.is_crouching:
			walk_sfx.pitch_scale = 0.7
		elif player.is_moving:
			walk_sfx.pitch_scale = 1.0
		if not walk_sfx.is_playing():
			walk_sfx.play()
	else:
		if walk_sfx.is_playing():
			walk_sfx.stop()
			
func play_essence_blast():
	essence_blast_sfx.play()
