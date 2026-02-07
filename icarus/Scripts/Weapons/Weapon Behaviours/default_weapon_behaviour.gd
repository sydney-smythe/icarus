extends Node3D

# the weapon behaviours scripts are specific scripts for each weapon. some may be generic, while others may be specialized.

var equipment_manager
var player
var head
var camera
@export var recoil_strength : float = 4.0
@export var damage : int = 1
enum Attack_types {HITSCAN, PROJECTILE}
@export var attack_type : Attack_types = Attack_types.HITSCAN
@export_group("Projectile Information")
@export var projectile : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred('late_ready')
	

func late_ready():
	equipment_manager = get_parent().get_parent().get_parent()
	player = equipment_manager.player
	head = equipment_manager.head
	camera = head.get_child(0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func primary_fire():
	print('fire - primary')
	player.apply_force(recoil_strength, camera.global_transform.basis.z.normalized())
	if attack_type == Attack_types.HITSCAN:
		fire_ray()

func secondary_fire():
	print('fire - secondary')
	
func fire_ray(range : float = 50.0):
	var space_state = get_world_3d().direct_space_state
	var origin_point = camera.global_transform.origin
	var end_point = origin_point + -camera.global_transform.basis.z * range
	var query = PhysicsRayQueryParameters3D.create(origin_point, end_point)
	query.exclude = [self]
	var collision = space_state.intersect_ray(query)
	if collision:
		print('collision at position: ' + str(collision.position))
		print('collision object: ' + str(collision.collider.name))
		
	else:
		print('no collision occured')
	DrawLine3d.DrawLine(origin_point, end_point, Color(1,0,0), 15)
