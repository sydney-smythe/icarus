extends CharacterBody3D

var state_manager
@onready var model: Node3D = $Model
@onready var model_animation_player = model.get_child(0).get_node('AnimationPlayer')
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var equipment_manager: Node3D = $"Model/Pivot/Equipment Manager"
@onready var vertical_pivot : Node3D = $"Model/Pivot"
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
var is_moving : bool = false
var is_crouching : bool = false
var is_sprinting : bool = false
var move_speed : float = 0.0
@export var walk_speed : float = 1.0
@export var sprint_speed : float = 9.0
@export var crouch_speed : float = 4.0
@export var has_gravity : bool = true
@export var gravity_modifier : float = 1.0
var input_dir : Vector3 = Vector3(0,0,0)  # used for enemy AI controller
var can_move : bool = true

var invincible = false
var target_mode : bool = true

## Movement physics parameters
@export_group("Movement Physics")
@export var acceleration : float = 50.0  # how quickly we accelerate toward target speed
@export var friction : float = 40.0  # how quickly we slow down when not moving
@export var air_friction : float = 2.0  # friction while airborne

@export var look_speed : float = 0.002

var forcer_vector = Vector3(0,0,0)
var in_range = false
@export var attack_range : float = 10.0
var target 
var attack_interval_timer : float = 0.1  # used to regulate attack attempt speed (so it isnt tied to fps)
var current_attack_timer : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_manager = get_child(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if target_mode:
		if current_attack_timer > 0:
			current_attack_timer -= delta
		
		var next_location
		if target:
			update_target_location()
			var distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)
			#print(str(distance_to_target))
			next_location = nav_agent.get_next_path_position()
			in_range = distance_to_target <= attack_range
		
			if not test_visibility():
				in_range = false
			#print(str(test_visibility()))
			if not in_range:
				if is_on_floor():
					var current_location = global_transform.origin
					input_dir = (next_location - current_location).normalized()
			else:
				input_dir = Vector3(0,0,0)
				
				# try attack and/or rotate if timer is 0
				rotate_look((target.global_transform.origin - global_transform.origin).normalized())
				if current_attack_timer <= 0:
					var chance = randf()
					#if chance < 0.3:  # 30% to look towards player
					
						
					#chance = randf()
					if chance < 0.15:  # 15% to try firing
						equipment_manager.attack()
					current_attack_timer = attack_interval_timer
			
		#print(str(input_dir))
		#input_dir = Vector3(0,0,0)
		#rotate_look()
		#handle animations
	if not is_moving:
		move_speed = 0
		model_animation_player.play("idle")
	elif is_sprinting:
		move_speed = sprint_speed
		model_animation_player.play("run")
		#audio_manager.play_movement_audio()
	elif is_moving and not is_sprinting:
		move_speed = walk_speed
		model_animation_player.play("walk")
		#audio_manager.play_movement_audio()
		
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * gravity_modifier * delta
	
	#var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var move_dir = input_dir 
	
	if can_move:
		# PHYSICS-BASED MOVEMENT: Add acceleration instead of setting velocity
		if move_dir:
			is_moving = true
				
			# Calculate target velocity
			var target_velocity = move_dir * move_speed
				
			# Add acceleration toward target velocity (only affects horizontal movement)
			var velocity_horizontal = Vector3(velocity.x, 0, velocity.z)
			var acceleration_force = (target_velocity - velocity_horizontal) * acceleration * delta
				
			velocity.x += acceleration_force.x
			velocity.z += acceleration_force.z
		else:
			is_moving = false
				
			# Apply friction when not actively moving
			var current_friction = friction
				
			# Adjust friction based on state
			if not is_on_floor():
				current_friction = air_friction
				
			# Apply friction to horizontal velocity only
			var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
			var friction_amount = current_friction * delta
				
			# Only apply friction if there's horizontal movement
			if horizontal_velocity.length() > 0.01:
				var friction_vector = horizontal_velocity.normalized() * friction_amount
					
				# Don't overshoot and reverse direction
				if friction_vector.length() > horizontal_velocity.length():
					velocity.x = 0
					velocity.z = 0
				else:
					velocity.x -= friction_vector.x
					velocity.z -= friction_vector.z
	else:
		var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
		if horizontal_velocity.length() > 0.01:
			var friction_vector = horizontal_velocity.normalized() * friction * 2.0 * delta
			if friction_vector.length() > horizontal_velocity.length():
				velocity.x = 0
				velocity.z = 0
			else:
				velocity.x -= friction_vector.x
				velocity.z -= friction_vector.z
	
	# TEMP NAV MOVEMENT INFO
	if target_mode:
		if not in_range:
			rotate_look(input_dir)
		velocity += forcer_vector
		move_and_slide()
		forcer_vector = Vector3(0,0,0)
		in_range = false

func rotate_look(dir):
	if not (dir * Vector3(1,0,1)).is_equal_approx(Vector3(0,0,0)):
		var target_pos_horiz = global_transform.origin - (dir * Vector3(1,0,1))
		var target_pos_vert = global_transform.origin - (dir * Vector3(1,1,1)) 
		#var old = transform.basis
		look_at(target_pos_horiz, Vector3.UP)
		vertical_pivot.look_at(target_pos_vert, Vector3.UP)
		#var new = transform.basis
		#transform.basis = lerp(old,new, .4)
	#head.transform.basis = Basis()
	#head.rotate_x(look_rotation.x)

func hit_by_weapon(damage : int):  # REQUIREMENT OF WEAPON TARGETS GROUP
	state_manager.change_current_health(damage)

func apply_force(strength : float, direction : Vector3, sustained : bool = false, duration : float = 0.0):
	if sustained:
		var force_object = preload("res://Scenes/Physics/forcer.tscn").instantiate()
		force_object.force_strength = strength
		force_object.force_direction = direction
		force_object.is_sustained = sustained
		force_object.duration = duration
		get_tree().current_scene.add_child(force_object)
	else:
		forcer_vector += direction * strength

func set_target(new_target):
	target = new_target

func update_target_location():
	nav_agent.target_position = target.global_transform.origin
	
func test_visibility() -> bool:
	# test if the first thing a ray hits is the target
	if target and equipment_manager.active_equipment != -1:
		var space_state = get_world_3d().direct_space_state
		var origin_point = collision_shape_3d.global_transform.origin
		var dir = (target.global_transform.origin - origin_point).normalized()
		var end_point = origin_point + dir * equipment_manager.get_max_range()
		var query = PhysicsRayQueryParameters3D.create(origin_point, end_point)
		query.exclude = [self]
		var collision = space_state.intersect_ray(query)

		if collision:
			#print('collision at position: ' + str(collision.position))
			#print('collision object: ' + str(collision.collider.name))
			if collision.collider == target:
				return true
			
	return false

func round_reset(weapon : String):
	reset_essence()
	invincible = false
	if not weapon == null:
		equipment_manager.clear_inventory()
		equipment_manager.add_equipment(0, weapon, true, true)

func reset_essence():
	state_manager.current_health = state_manager.max_health
	
func set_attack_range():
	attack_range = randf_range(equipment_manager.get_max_range()*0.3, equipment_manager.get_max_range())
