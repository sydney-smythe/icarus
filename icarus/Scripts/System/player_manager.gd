extends Node

var player: CharacterBody3D = null

func register_player(p: CharacterBody3D) -> void:
	player = p

func get_player() -> CharacterBody3D:
	return player
