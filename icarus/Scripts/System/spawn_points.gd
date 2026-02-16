extends Node3D

var rng = RandomNumberGenerator.new()

@export var spawn_points : Array[Vector3]
var spawn_points_availability : Array[bool]

func _ready() -> void:
	for point in range(0,spawn_points.size()):
		spawn_points_availability.append(true)

func check_spawn_points(player_count : int = 0) -> bool:
	if spawn_points.size() > 0:
		if spawn_points.size() > player_count:
			if player_count == 0:
				print('WARNING: passed spawn point check, but passed-in player count = 0')
			return true
		else:
			print('ERROR: not enough spawn points')
	else:
		print('ERROR: no spawn points')
	return false

func assign_random_point(player_count : int = 0) -> Vector3:
	if check_spawn_points(player_count):
		for point in range(0,spawn_points.size()):
			var num = rng.randi_range(0,spawn_points.size()-1)
			if spawn_points_availability[num]:
				spawn_points_availability[num] = false
				return spawn_points[num]
	return Vector3(0,0,0)

func assign_point_at_index(index : int) -> Vector3:
	spawn_points_availability[index] = false
	return spawn_points[index]

func reset_points():
	for point in range(0,spawn_points.size()):
		spawn_points_availability[point] = true
