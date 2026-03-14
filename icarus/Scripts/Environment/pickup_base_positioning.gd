extends Node3D

@onready var pickup = get_parent()
var base
@export var floor_offset : float = 0.7
enum Base_model {
	WEAPON,
	BOON
}
@export var base_model : Base_model = Base_model.WEAPON
var boon_base_model = 'uid://dck6w3kjaa6ba'
var weapon_base_model = 'uid://d2yfi3wri6has'
@export var base_model_scale : float = 0.7
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#call_deferred('set_base_model')

func set_base_model():
	var new_base_model 
	if base_model == Base_model.WEAPON:
		new_base_model = load(weapon_base_model).instantiate()
	else:
		new_base_model = load(boon_base_model).instantiate()
	new_base_model.scale = Vector3(base_model_scale, base_model_scale, base_model_scale)
	add_child(new_base_model)
	base = new_base_model

func snap_pickup_to_floor():
	set_base_model()
	var floor_pos = fire_ray()
	if floor_pos != null:
		pickup.global_position = Vector3(floor_pos.x, floor_pos.y + floor_offset, floor_pos.z)
		base.global_position = floor_pos
		
func fire_ray():
	var space_state = get_world_3d().direct_space_state
	var origin_point = pickup.global_transform.origin
	var end_point = origin_point + -pickup.global_transform.basis.y * 100
	var query = PhysicsRayQueryParameters3D.create(origin_point, end_point)
	query.exclude = [self]
	var collision = space_state.intersect_ray(query)
	if collision:
		#print(str(collision.collider))
		if collision.collider is CSGCombiner3D:
			return collision.position
	return null
