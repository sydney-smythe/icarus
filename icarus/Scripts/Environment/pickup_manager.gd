extends Node3D


# Called when the node enters the scene tree for the first time.
func disable_all_pickups():
	for child_index in range(0, get_child_count()):
		get_child(child_index).pickup_unavailable()
	
func enable_all_pickups():
	for child_index in range(0, get_child_count()):
		get_child(child_index).pickup_available()
