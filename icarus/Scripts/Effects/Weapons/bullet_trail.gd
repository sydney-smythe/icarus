extends MeshInstance3D

var origin_point : Vector3 = Vector3(0,0,0)
var end_point : Vector3 = Vector3(0,0,0)
var duration : float = 0.09  # lower duration = faster speed
var time_travelled : float = 0
@export var trail_scale = 0.04
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector3(trail_scale,trail_scale,trail_scale)
	global_position = origin_point
	look_at(end_point, Vector3.UP)
	rotate_object_local(Vector3.RIGHT, PI / 2)
	
	# 3. Scale Z-axis (or Y) based on distance
	var distance = origin_point.distance_to(end_point)
	# Assumes default mesh length is 1.0 along the look_at axis
	#scale.y = distance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_travelled < duration:
		time_travelled += delta
		var pos = clamp(time_travelled / duration, 0.0, 1.0)  # calculate interpolation value (0.0 to 1.0)
		global_position = origin_point.lerp(end_point, pos)  # interpolate position
	else:
		queue_free()
