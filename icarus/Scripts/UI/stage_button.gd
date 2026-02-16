extends Button

@export var stage_id : String = "0"
@export var main_menu_ui : Control 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not main_menu_ui:
		print("ERROR: Unassigned Main Menu UI")


func _on_button_up() -> void:
	main_menu_ui.load_stage(stage_id)
