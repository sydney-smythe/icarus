extends CharacterBody3D

var state_manager
@onready var model: Node3D = $Model
@onready var model_animation_player = model.get_child(0).get_node('AnimationPlayer')
var is_moving : bool = false
var is_crouching : bool = false
var is_sprinting : bool = false
var move_speed : float = 0.0
@export var walk_speed : float = 7.0
@export var sprint_speed : float = 9.0
@export var crouch_speed : float = 4.0
@export var has_gravity : bool = true
@export var gravity_modifier : float = 1.0
var input_dir : Vector3 = Vector3(0,0,0)  # used for enemy AI controller
var can_move : bool = true

## Movement physics parameters
@export_group("Movement Physics")
@export var acceleration : float = 50.0  # how quickly we accelerate toward target speed
@export var friction : float = 40.0  # how quickly we slow down when not moving
@export var air_friction : float = 2.0  # friction while airborne

@export var look_speed : float = 0.002

var forcer_vector = Vector3(0,0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_manager = get_child(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	# for now: temp move
	input_dir = Vector3(0,0,0)
	rotate_look()
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
	
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
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
	
	velocity += forcer_vector
	move_and_slide()
	forcer_vector = Vector3(0,0,0)

func rotate_look():
	model.look_at(-(global_position + input_dir), Vector3.UP)
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
