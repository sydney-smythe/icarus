extends Control

var ui_visible = true
@export var text_label : Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggle_visibility()

func toggle_visibility():
	if ui_visible:
		self.hide()
		ui_visible = false
	else:
		self.show()
		ui_visible = true
		
func disable_ui():
	self.hide()
	ui_visible = false

func update_and_enable(interaction_name : String):
	update_label(interaction_name)
	if not ui_visible:
		toggle_visibility()
	
func update_label(interaction_name : String):
	text_label.text = '[E] ' + interaction_name
	
