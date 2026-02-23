extends Node3D

var boon_id = '1'
var boon_timer : float = 30.0
@onready var boon_manager = get_parent()
@onready var host = get_parent().get_parent()
@onready var data_manager = get_node("/root/Game Manager/Sub Managers/Data Manager/")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred('start_boon')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if boon_timer > 0:
		boon_timer -= delta
		boon_manager.active_boons[data_manager.boon_dict[boon_id][1]] = boon_timer
	else:
		end_boon()
		
func update_timer(new_time : float, override : bool = false):
	# if override, will update to the new time even if it's lower than the current remaining time
	# if not override, will only set timer to new time if it's higher than the current remaining time
	if new_time > 0:
		if override:
			boon_timer = new_time
		else:
			if new_time > boon_timer:
				boon_timer = new_time
	else:
		end_boon()
		
func start_boon():  # boon effects go here
	boon_manager.active_boons[data_manager.boon_dict[boon_id][1]] = boon_timer
	host.boon_grav_mult = 0.6
	
func end_boon():  # undoing boon effects goes here
	boon_manager.active_boons.erase(data_manager.boon_dict[boon_id][1])
	host.boon_grav_mult = 1
