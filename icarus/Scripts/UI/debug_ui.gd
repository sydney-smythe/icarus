extends Control

@onready var player: CharacterBody3D = get_node("/root/Game Manager/Player")
# ENGINE INFO
@onready var fps_count: Label = $"MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Engine Info/FPS Count"
# PLAYER INFO
@onready var actions_label: Label = $"MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Player Info/Actions Label"
@onready var move_speed: Label = $"MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Player Info/Move Speed"
@onready var velocity_vector: Label = $"MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Player Info/Velocity Vector"
@onready var camera_rotation: Label = $"MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Player Info/Camera Rotation"
@onready var current_level: Label = $"MarginContainer/PanelContainer/MarginContainer/VBoxContainer/State Info/Current Level"
# ESSENCE INFO
@onready var essence: Label = $"MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Essence Info/Essence"
@onready var grav_mult: Label = $"MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Essence Info/Grav Mult"
@onready var force_mult: Label = $"MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Essence Info/Force Mult"
@onready var speed_mult: Label = $"MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Essence Info/Speed Mult"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("late_ready")

func late_ready():
	current_level.text = 'Current Stage: ' + str(get_node('/root/Game Manager/Stage Manager').get_child(0).name)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed('toggle_debug_ui'):
		if self.visible:
			self.hide()
		else:
			self.show()

func _process(_delta: float) -> void:
	
	#ENGINE INFO
	current_level.text = 'Current Stage: ' + str(get_node('/root/Game Manager/Stage Manager').get_child(0).name)
	fps_count.text = 'FPS: ' + str(Engine.get_frames_per_second())
	
	# PLAYER INFO 
	var text_item : String = 'Active Actions:'
	for item in player.active_actions:
		text_item = 'Active Actions:' + "\n" + str(item)
	actions_label.text = text_item
	
	move_speed.text = 'Move Speed: ' + str(snapped((player.move_speed * player.essence_speed_curve.sample(float(player.essence)/100)), 0.01))
	
	velocity_vector.text = 'Vel. Vec: ' + str(player.velocity)
	
	camera_rotation.text = 'Cam: ' + str(player.get_node('Head').get_node('Camera3D').global_transform.basis.z)
	
	# ESSENCE INFO
	if player.overessence <= 0:
		essence.text = 'Essence: ' + str(player.essence)
	else:
		essence.text = 'Essence: ' + str(player.essence) + " + " + str(player.overessence)
	grav_mult.text = 'Essence Grav Mult: x' + str(snapped((player.essence_grav_curve.sample(float(player.essence)/100)), 0.01))
	force_mult.text = 'Essence Force Mult: x' + str(snapped((player.essence_force_curve.sample(float(player.essence)/100)), 0.01))
	speed_mult.text = 'Essence Speed Mult: x' + str(snapped((player.essence_speed_curve.sample(float(player.essence)/100)), 0.01))
