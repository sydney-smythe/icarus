extends Node3D

# the weapon behaviours scripts are specific scripts for each weapon. some may be generic, while others may be specialized.

var equipment_manager
var host
var head
var camera
@export var fire_range : float = 50.0
@export var recoil_strength : float = 4.0
@export var damage : int = 1
enum Attack_types {HITSCAN, PROJECTILE}
@export var attack_type : Attack_types = Attack_types.HITSCAN
@export_group("Projectile Information")
@export var projectile : PackedScene
@export var projectile_speed : float = 0.5
@onready var animation_manager = $"Animation Manager"
@onready var audio_manager: Node3D = $"Audio Manager"
var bullet_trail = 'uid://saod68jbabc7'
var mode : String = 'Player' 
@onready var exit_point = get_node('Animation Manager/Pivot/Model/Exit Point')
# bloom / recoil 
@export_group("Bloom")
@export var max_bloom : float = 5.0  # max bloom (gets random f from -max to max for x and y when calculating the ray fire
var bloom_multiplier : float = 1.0  # may be adjusted by boons
@export var shots_to_max_bloom : int = 5  # how large the 'recent shot' count should be to trigger max bloom size
@export var bloom_strength_curve : Curve  # set max x and y axis to 1! / how bloom increases as recent shots increase

@export_group("Recoil")
@export var shots_to_max_recoil : int = 5  # shots to reach max recoil
@export var recoil_strength_curve : Curve # set max x and y axis to 1!

@export_group("Shot Data") # used to manage recoil and bloom
var recent_shots : int = 0  # goes up with each recent shot
@export var max_stored_recent_shots : int = 10  # the max number stored in 'recent shots' (prevents recent from getting too large and keeping bloom high forever)
@export var shot_cooldown_time : float = 0.2  # seconds it takes for a shot to leave the 'recent shot' count
var shot_cooldown_timer : float
@export var full_cooldown_time : float = 1  # if no shots have been fired for this long, resent 'recent shots' to 0
var full_cooldown_timer : float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred('late_ready')
	shot_cooldown_timer = shot_cooldown_time

func late_ready():
	equipment_manager = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	if equipment_manager != null:
		host = equipment_manager.host
	else:
		print('asdasdasdasdasdasdasd')
		equipment_manager = get_parent().get_parent()
		host = equipment_manager.host
	print(str(host))
	if not host.is_in_group('Enemies'):
		head = equipment_manager.head
		camera = head.get_child(0)
	else:
		mode = 'Enemy'
		camera = host.get_node('CollisionShape3D')
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if recent_shots > 0:
		if shot_cooldown_timer > 0:
			shot_cooldown_timer -= delta
			if shot_cooldown_timer <= 0:
				#print('-1 recent shot [remaining: ' + str(recent_shots) + ']')
				shot_cooldown_timer = shot_cooldown_time
				recent_shots -= 1
	if full_cooldown_timer > 0:
		full_cooldown_timer -= delta
		if full_cooldown_timer <= 0:
			#print('reset recent')
			recent_shots = 0
	
func primary_fire():
	#print('fire - primary')
	animation_manager.play_primary_fire()
	audio_manager.play_primary_audio()
	if mode != 'Enemy':
		host.apply_force(recoil_strength, camera.global_transform.basis.z.normalized())
		host.has_attacked_since_last_wall_run = true
	if attack_type == Attack_types.HITSCAN:
		fire_ray()
	elif attack_type == Attack_types.PROJECTILE:
		fire_projectile()
	if recent_shots < max_stored_recent_shots:
		recent_shots += 1
	full_cooldown_timer = full_cooldown_time
	shot_cooldown_timer = shot_cooldown_time
	

func secondary_fire():
	#print('fire - secondary')
	pass
	
func apply_recoil():
	if mode == 'Player':
		var recoil_amount = recoil_strength_curve.sample(float(recent_shots)/shots_to_max_recoil)
		var rotate_vector : Vector2 = Vector2(0,-recoil_amount)
		var look_mult : float = 0.007
		var recoil_speed : float = 0.05
		host.rotate_look(rotate_vector, look_mult, true, recoil_speed)
	
func fire_ray():
	var space_state = get_world_3d().direct_space_state
	var origin_point = camera.global_transform.origin
	var bloom_mult : float = bloom_strength_curve.sample(float(recent_shots)/shots_to_max_bloom)
	var bloom_range = bloom_mult * max_bloom
	var x_bloom = randf_range(-bloom_range, bloom_range)
	var y_bloom = randf_range(-bloom_range, bloom_range)
	var bloom_offset = Vector3(x_bloom, y_bloom, 0)
	var end_point = origin_point + -camera.global_transform.basis.z * fire_range + bloom_offset
	var query = PhysicsRayQueryParameters3D.create(origin_point, end_point)
	query.exclude = [self]
	var collision = space_state.intersect_ray(query)
	if collision:
		#print('collision at position: ' + str(collision.position))
		#print('collision object: ' + str(collision.collider.name))
		if collision.collider.is_in_group("Weapon Targets"):
			collision.collider.hit_by_weapon(damage)
			if mode == 'Player':
				audio_manager.play_enemy_hit_audio()
		var new_trail = load(bullet_trail).instantiate()
		new_trail.origin_point = exit_point.global_position
		new_trail.end_point = collision.position
		get_node('/root/Game Manager').add_child(new_trail)
	else:
		var new_trail = load(bullet_trail).instantiate()
		new_trail.origin_point = exit_point.global_position
		new_trail.end_point = end_point
		get_node('/root/Game Manager').add_child(new_trail)
		#print('no collision occured')
	# draw a line for debug
	#var ray_object = preload("res://Scenes/Game Management/Debug/debug_ray.tscn").instantiate()
	#add_child(ray_object)
	#ray_object.DrawLine(origin_point, end_point, Color(1,0,0), 15)
	apply_recoil()
func fire_projectile():
	var new_projectile = projectile.instantiate()
	new_projectile.direction = -camera.global_transform.basis.z
	new_projectile.speed = projectile_speed
	get_tree().current_scene.add_child(new_projectile)
	new_projectile.global_position = camera.global_position + (-camera.global_transform.basis.z * 1)
	
func play_reload_sfx():
	audio_manager.play_reload_audio()
	
func play_no_ammo_sfx():
	audio_manager.play_no_ammo_audio()
	
func play_equip_sfx():
	audio_manager.play_equip_audio()
