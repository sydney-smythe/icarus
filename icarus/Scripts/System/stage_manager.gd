extends Node3D

@onready var player = %Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred('late_ready')

func late_ready():
	update_enemy_targets()

func update_enemy_targets():
	get_tree().call_group('Enemies', 'set_target', player)
