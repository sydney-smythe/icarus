extends Node3D

@export var requires_interact_pressed : bool = true
@export var single_use : bool = false
@export var recharge_delay : float = 5.0

@onready var player : CharacterBody3D = null
@onready var touch_range: Area3D = $"Touch Range"
@onready var interact_range: Area3D = $"Interact Range"
@onready var model: Node3D = $Model

# essence data
@export var essence_amount = 20

var camera
var touch_body_list : Array = []
var interact_body_list : Array = []
var is_available : bool = true
var available_timer : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred('late_ready')

func late_ready():
	player = PlayerManager.get_player()
	camera = player.get_node('Head').get_node('Camera3D')

func _process(delta: float) -> void:
	if not is_available and available_timer > 0:
		available_timer -= delta
	else:
		is_available = true
		pickup_available()

func _input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("interact"):
		if requires_interact_pressed and player in interact_body_list and is_available:
			#print('interact')
			if fire_ray():  # check if player is looking at the pickup
				print('collected pickup - range')
				use_pickup()
			

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
		queue_free()
	else:
		is_available = false
		available_timer = recharge_delay
		pickup_unavailable()

func _on_touch_range_body_entered(body: Node3D) -> void:
	if body not in touch_body_list:
		touch_body_list.append(body)
	if body == player and requires_interact_pressed == false and is_available:
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
	player.hit_by_weapon(-essence_amount, true)
	
func pickup_unavailable():
	model.get_child(0).hide()
	
func pickup_available():
	model.get_child(0).show()
