extends Control

@onready var ui_manager : CanvasLayer = get_parent().get_parent()
@onready var stage_manager : Node3D = get_node('/root/Game Manager/SubViewportContainer/SubViewport/Stage Manager')
@onready var game_manager : Node3D = get_node('/root/Game Manager/')
@export var quit_button : Button 
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	self.hide()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed('pause') and game_manager.can_pause:
		if not self.visible:
			self.show()
			game_manager.toggle_pause()
			if self not in ui_manager.active_node_list:
				ui_manager.add_active_node(self)
		elif ui_manager.get_active_node() == self:
			self.hide()
			game_manager.toggle_pause()
			ui_manager.pop_active_node()

func _on_quit_button_button_up() -> void:
	ui_manager.play_ui_back_sfx()
	game_manager.quit_to_main_menu()
	

func _on_settings_button_button_up() -> void:
	ui_manager.play_ui_accept_sfx()
	ui_manager.toggle_settings()
