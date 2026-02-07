extends Node3D

# the weapon behaviours scripts are specific scripts for each weapon. some may be generic, while others may be specialized.

var equipment_manager
var player
var head
var camera
@export var recoil_strength : float = 4.0

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
	#print(str(camera.global_transform.basis.z.normalized()))
	
	# strength : float, direction : Vector3, sustained : bool = false, duration : float = 0.0

func secondary_fire():
	print('fire - secondary')
