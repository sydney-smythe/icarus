extends RigidBody3D

var state_manager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_manager = get_child(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hit_by_weapon(damage : int):  # REQUIREMENT OF WEAPON TARGETS GROUP
	state_manager.change_current_health(damage)
