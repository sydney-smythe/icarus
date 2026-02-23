extends Node3D

@export var round_start : AudioStreamPlayer
@export var round_win : AudioStreamPlayer
@export var round_lose : AudioStreamPlayer
@export var match_win : AudioStreamPlayer
@export var match_lose : AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_round_end_sfx(victory : bool):
	if victory:
		round_win.play()
	else:
		round_lose.play()

func play_match_end_sfx(victory : bool):
	if victory:
		match_win.play()
	else:
		match_lose.play()
		
func play_round_start_sfx():
	round_start.play()
