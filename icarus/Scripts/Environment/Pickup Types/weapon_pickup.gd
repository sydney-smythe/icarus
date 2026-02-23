extends Node3D

@export var requires_interact_pressed : bool = true
@export var single_use : bool = false
@export var recharge_delay : float = 5.0

@onready var player : CharacterBody3D = null
@onready var touch_range: Area3D = $"Touch Range"
@onready var interact_range: Area3D = $"Interact Range"
@onready var model: Node3D = $Model

# weapon data
@export var weapon_id : String = '0'
@onready var data_manager = get_node("/root/Game Manager/Sub Managers/Data Manager/")
@onready var ui_manager = get_node('/root/Game Manager/UI Manager/')
@export var model_scale : float = 0.4
var equipment_manager

var camera
var touch_body_list : Array = []
var interact_body_list : Array = []
var is_available : bool = true
var available_timer : float = 0
var weapon_name : String
var player_is_looking : bool = false
var is_popup_enabled : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred('late_ready')

func late_ready():
	player = PlayerManager.get_player()
	camera = player.get_node('Head').get_node('Camera3D')
	equipment_manager = player.get_node('Head').get_node('Camera3D').get_node('Equipment Manager')
	var gun_model = load(data_manager.weapon_dict[weapon_id][3]).instantiate()
	weapon_name = data_manager.weapon_dict[weapon_id][1]
	gun_model.scale = Vector3(model_scale,model_scale,model_scale)
	if model.get_child_count() > 0:
		model.get_child(0).queue_free()  # remove default model
	model.add_child(gun_model)

func _process(delta: float) -> void:
	if not single_use:
		if not is_available and available_timer > 0:
			available_timer -= delta
		else:
			pickup_available()
			
	player_is_looking = false
	if player in interact_body_list:
		var space_state = get_world_3d().direct_space_state
		var origin_point = player.camera.global_transform.origin
		var end_point = origin_point + -player.camera.global_transform.basis.z * 100
		var query = PhysicsRayQueryParameters3D.create(origin_point, end_point)
		query.collide_with_areas = true
		query.exclude = [player]
		var collision = space_state.intersect_ray(query)
		if collision:
			#print('collision at position: ' + str(collision.position))
			#print('collision object: ' + str(collision.collider.name))
			if collision.collider == touch_range:
				player_is_looking = true
	if player_is_looking:
		if is_available:
			enable_interaction_popup()
			is_popup_enabled = true
	elif is_popup_enabled:
		disable_interaction_popup()
		is_popup_enabled = false

func _input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("interact"):
		if requires_interact_pressed and player in interact_body_list and is_available:
			#print('interact')
			if fire_ray():  # check if player is looking at the pickup
				print('collected pickup - range')
				use_pickup()
				if is_popup_enabled:
					disable_interaction_popup()
					is_popup_enabled = false
			

func fire_ray() -> bool:
	var space_state = get_world_3d().direct_space_state
	var origin_point = camera.global_transform.origin
	var end_point = origin_point + -camera.global_transform.basis.z * 100
	var query = PhysicsRayQueryParameters3D.create(origin_point, end_point)
	query.collide_with_areas = true
	query.exclude = [player]
	var collision = space_state.intersect_ray(query)
	if collision:
		#print('collision at position: ' + str(collision.position))
		#print('collision object: ' + str(collision.collider.name))
		if collision.collider == touch_range:
			return true
	return false
	
func use_pickup():
	pickup()
	if single_use:
		model.get_child(0).hide()
		is_available = false
	else:
		is_available = false
		available_timer = recharge_delay
		pickup_unavailable()

func pickup_unavailable():
	model.get_child(0).hide()
	is_available = false
	
func pickup_available():
	model.get_child(0).show()
	is_available = true
	available_timer = 0

func _on_touch_range_body_entered(body: Node3D) -> void:
	if body not in touch_body_list:
		touch_body_list.append(body)
	if body == player and requires_interact_pressed == false and is_available  and player.player_enabled and player.can_move:
		print('collected pickup - touch')
		use_pickup()


func _on_touch_range_body_exited(body: Node3D) -> void:
	if body in touch_body_list:
		touch_body_list.erase(body)


func _on_interact_range_body_entered(body: Node3D) -> void:
	if body not in interact_body_list:
		interact_body_list.append(body)


func _on_interact_range_body_exited(body: Node3D) -> void:
	if body in interact_body_list:
		interact_body_list.erase(body)
	
func pickup():
	equipment_manager.add_equipment(equipment_manager.active_equipment, weapon_id, true, true, true)

func enable_interaction_popup():
	ui_manager.get_node('Interact UI').update_and_enable(weapon_name)

func disable_interaction_popup():
	ui_manager.get_node('Interact UI').disable_ui()
