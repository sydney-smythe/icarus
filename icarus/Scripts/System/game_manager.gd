extends Node3D

@onready var player = %Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disable_player()
	
func disable_player():
	player.player_enabled = false
	player.equipment_manager.disable_equipment()
	
func enable_player():
	player.player_enabled = true
	player.equipment_manager.enable_equipment()
