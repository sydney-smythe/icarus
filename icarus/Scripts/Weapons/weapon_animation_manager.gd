extends Node3D

var model
@onready var pivot = get_child(0)
var player_controlled: bool = false
var player: CharacterBody3D
@onready var weapon_manager = get_parent().get_parent()

@export_group("Animation Data")
@export var primary_animation: String = "temp-fire"
@onready var animation_player = $Pivot/Model/AnimationPlayer

@export_group("Hand Positioning")
@export var l_hand_pos: Marker3D
@export var r_hand_pos: Marker3D
var track_hands = false

# The anchor on the camera where the weapon grip should snap to
var weapon_anchor: Marker3D
# The grip point on the weapon model itself
@onready var grip_point: Marker3D = $"Pivot/Model/Grip Point"  # adjust path

@export_group("Model Positioning")
@export var model_scale: float = 1.0
@export var model_rotation_offset: Vector3 = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	model = get_child(0).get_child(0)
	model.scale = Vector3(model_scale,model_scale,model_scale)
	model.rotation_degrees = model_rotation_offset
	call_deferred('late_ready')

func late_ready():
	player_controlled = weapon_manager.player_controlled
	if player_controlled:
		player = PlayerManager.get_player()
		if player:
			weapon_anchor = player.camera.get_node('Weapon Anchor')
			track_hands = true

func _process(_delta: float) -> void:
	if player_controlled and weapon_anchor and grip_point:
		# Align the weapon so its grip point matches the camera anchor
		var grip_offset = grip_point.global_position - global_position
		global_position = weapon_anchor.global_position - grip_offset
		global_rotation = weapon_anchor.global_rotation
		
	if track_hands:
		update_player_hand_targets()

func update_player_hand_targets():
	#print('setting hand pos')
	player.model.l_arm_target.global_position = l_hand_pos.global_position
	player.model.r_arm_target.global_position = r_hand_pos.global_position

func play_primary_fire():
	if animation_player.current_animation == primary_animation:
		animation_player.stop(true)
	animation_player.play(primary_animation)
