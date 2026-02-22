extends CanvasLayer

var black_and_white : String = 'uid://bk846k0apc45g'
var filter_dict : Dictionary
@onready var data_manager = get_node('/root/Game Manager/Sub Managers/Data Manager/')

func _ready() -> void:
	call_deferred('late_ready')
	
func late_ready():
	filter_dict = data_manager.filter_dict
	
func add_filter(filter_id : String):
	if filter_id in filter_dict:
		var node_name = 'ID-' + filter_id + '-' + filter_dict[filter_id][1]
		if not has_node(node_name):
			var new_filter = load(filter_dict[filter_id][0]).instantiate()
			new_filter.name = node_name
			add_child(new_filter)
	else:
		print('[Filter Manager] Error: Filter id = ' + filter_id + ' does not exist.')

func remove_filter(filter_id : String):
	if filter_id in filter_dict:
		var node_name = 'ID-' + filter_id + '-' + filter_dict[filter_id][1]
		if has_node(node_name):
			get_node(node_name).queue_free()
		else:
			print('[Filter Manager] Filter id = ' + filter_id + ' is not currently active, cannot remove.' )
	else:
		print('[Filter Manager] Error: Filter id = ' + filter_id + ' does not exist.')
