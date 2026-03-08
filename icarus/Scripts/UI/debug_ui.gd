extends Control

@onready var game_manager = get_node('/root/Game Manager/')
var player: CharacterBody3D
# GAME INFO
@export var version_text : Label
# ENGINE INFO
@export var fps_count: Label
# PLAYER INFO
@export var actions_label: Label
@export var move_speed: Label
@export var velocity_vector: Label
@export var camera_rotation: Label
@export var current_level: Label
# ESSENCE INFO
@export var essence: Label
@export var grav_mult: Label
@export var force_mult: Label
@export var speed_mult: Label
# CONTAINERS
@export var debug_panel : MarginContainer
@export var f2_tooltip : MarginContainer

var is_enabled : bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggle_visibility()
	call_deferred("late_ready")
	version_text.text = 'Project ICARUS   Build ' + game_manager.GAME_BUILD + '   \nv.' + game_manager.GAME_VERSION + '   Playtest ' + game_manager.GAME_PLAYTEST_NAME

func toggle_visibility():
	if is_enabled:
		f2_tooltip.show()
		debug_panel.hide()
		is_enabled = false
	else:
		f2_tooltip.hide()
		debug_panel.show()
		is_enabled = true

func late_ready():
	player = PlayerManager.get_player()
	current_level.text = 'Current Stage: ' + str(get_node('/root/Game Manager/SubViewportContainer/SubViewport/Stage Manager').get_child(0).name)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed('toggle_debug_ui'):
		toggle_visibility()

func _process(_delta: float) -> void:
	#ENGINE INFO
	current_level.text = 'Current Stage: ' + str(get_node('/root/Game Manager/SubViewportContainer/SubViewport/Stage Manager').get_child(0).name)
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
