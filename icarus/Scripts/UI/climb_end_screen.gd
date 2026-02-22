extends Control

var is_enabled : bool = true
@export var text : Label
@export var timer : Label
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

func disable_ui():
	self.hide()
	is_enabled = false

func update_and_enable(time : float):
	# Calculate minutes and seconds
	var minutes: int = int(time / 60.0)
	# Use fmod for precise remaining seconds with decimals
	var seconds: float = fmod(time, 60.0) 
	var time_string: String = "%02d:%00.2f" % [minutes, seconds]
	timer.text = time_string
	toggle_visibility()
	
