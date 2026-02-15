extends Control

@onready var game_manager: Node3D = $"../.."
@onready var stage_manager: Node3D = $"../../Stage Manager"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_up() -> void:
	stage_manager.load_stage('0')
	queue_free()


func _on_quit_button_up() -> void:
	pass # Replace with function body.
