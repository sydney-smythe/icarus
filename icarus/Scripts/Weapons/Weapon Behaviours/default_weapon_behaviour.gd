extends Node3D

# the weapon behaviours scripts are specific scripts for each weapon. some may be generic, while others may be specialized.

var equipment_manager
var host
var head
var camera
@export var fire_range : float = 50.0
@export var recoil_strength : float = 4.0
@export var damage : int = 1
enum Attack_types {HITSCAN, PROJECTILE}
@export var attack_type : Attack_types = Attack_types.HITSCAN
@export_group("Projectile Information")
@export var projectile : PackedScene
@export var projectile_speed : float = 0.5
@onready var animation_manager = $"Animation Manager"
@onready var audio_manager: Node3D = $"Audio Manager"
var mode : String = 'Player' 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred('late_ready')
	

func late_ready():
	equipment_manager = get_parent().get_parent().get_parent()
	host = equipment_manager.host
	if not host.is_in_group('Enemies'):
		head = equipment_manager.head
		camera = head.get_child(0)
	else:
		mode = 'Enemy'
		camera = host.get_node('CollisionShape3D')
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func primary_fire():
	#print('fire - primary')
	animation_manager.play_primary_fire()
	audio_manager.play_primary_audio()
	if mode != 'Enemy':
		host.apply_force(recoil_strength, camera.global_transform.basis.z.normalized())
	if attack_type == Attack_types.HITSCAN:
		fire_ray()
	elif attack_type == Attack_types.PROJECTILE:
		fire_projectile()

func secondary_fire():
	#print('fire - secondary')
	pass
	
func fire_ray():
	var space_state = get_world_3d().direct_space_state
	var origin_point = camera.global_transform.origin
	var end_point = origin_point + -camera.global_transform.basis.z * fire_range
	var query = PhysicsRayQueryParameters3D.create(origin_point, end_point)
	query.exclude = [self]
	var collision = space_state.intersect_ray(query)
	if collision:
		#print('collision at position: ' + str(collision.position))
		#print('collision object: ' + str(collision.collider.name))
		if collision.collider.is_in_group("Weapon Targets"):
			collision.collider.hit_by_weapon(damage)
	#else:
		#print('no collision occured')
	# draw a line for debug
	#var ray_object = preload("res://Scenes/Game Management/Debug/debug_ray.tscn").instantiate()
	#add_child(ray_object)
	#ray_object.DrawLine(origin_point, end_point, Color(1,0,0), 15)

func fire_projectile():
	var new_projectile = projectile.instantiate()
	new_projectile.direction = -camera.global_transform.basis.z
	new_projectile.speed = projectile_speed
	get_tree().current_scene.add_child(new_projectile)
	new_projectile.global_position = camera.global_position + (-camera.global_transform.basis.z * 1)
