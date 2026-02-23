extends Control

var is_enabled = true
var tab : String = 'Settings'  # possible values: Settings, About
@onready var ui_manager = get_parent().get_parent()
@onready var game_manager = get_node('/root/Game Manager')
@export var settings_screen : VBoxContainer
@export var about_screen : VBoxContainer
@export var about_button : Button
@export var back_button : Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggle_visibility()

func toggle_visibility():
	if is_enabled:
		self.hide()
		is_enabled = false
	else:
		self.show()
		is_enabled = true
		game_manager.release_mouse()



func _on_back_button_button_up() -> void:
	ui_manager.play_ui_back_sfx()
	if tab == 'Settings':
		toggle_visibility()
	elif tab == 'About':
		settings_screen.show()
		about_screen.hide()
		about_button.show()
		tab = 'Settings'


func _on_about_button_button_up() -> void:
	ui_manager.play_ui_accept_sfx()
	settings_screen.hide()
	about_screen.show()
	about_button.hide()
	tab = 'About'
