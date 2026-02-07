extends Node3D

# used to load and store commonly accessed files

var weapon_dict : Dictionary = {}

func _ready():
	# Call the function to load your JSON file
	weapon_dict = load_json_file("res://Data/weapon_id.json")
	#print(weapon_dict["0"])

func load_json_file(path: String) -> Dictionary:
	var dict: Dictionary = {}
	
	# read data
	var file : FileAccess = FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		print("FILE READ ERROR: " + path)
		return dict
	var data : String = file.get_as_text()
	file.close()
	
	# parse JSON data
	var parsed_data = JSON.parse_string(data)
	if parsed_data == null:
		print("JSON PARSE ERROR: " + path)
		return dict
	
	dict = parsed_data
	return dict
