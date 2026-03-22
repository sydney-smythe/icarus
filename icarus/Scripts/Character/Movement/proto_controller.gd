# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D
@onready var game_manager = get_node('/root/Game Manager/')
@export var player_enabled : bool = true
## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we press to crouch?
@export var can_crouch: bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = true
@export var essence_blast : Area3D

var invincible = false
@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity_default : float = 6.0
@export var jump_velocity_sprinting : float = 7.0
## Wall jump parameters
@export var wall_jump_push_strength : float = 10.0  # initial push away from wall
@export var wall_jump_air_control : float = 0.12  # how much control player has during wall jump (0-1)
@export var wall_jump_momentum_time : float = 0.19  # how long the push effect lasts
@export var air_strafe_mobility : float = 0.09  # how much you can control your movement in the air | in the future, this could increase as you gain a rhythm / momentum?
var wall_jump_timer : float = 0.0
var wall_jump_direction : Vector3 = Vector3.ZERO
var was_just_on_ground = false
var y_velocity_pre_impact : float = 0
# Wall run parameters
@export var wall_run_length : float = 3.0  # seconds you can run on the wall for straight (before gravity regains full control of y)
@export var wall_run_decay : float = 0.2  # higher = the quicker gravity regains control
var wall_run_grav_mod : float = 0.0  # modifies how strong gravity will be this physics process call
var wall_run_timer : float = 0.0  # when > 0, applies wall run protocol
var is_wall_running : bool = false
var current_wall_run_grav_mod : float  # is the agent that acts on gravity, the other one dictates this one's starting value
var can_wall_run : bool = true
var wall_run_normal : Vector3
var wall_run_min_speed : float = 3.8
## How fast do we run?
@export var sprint_speed : float = 9.2
## How fast are we when crouching?
@export var crouch_speed : float = 4.0
@export var sliding_speed : float = 9.9
@export var sliding_speed_loss : float = 2.9  # amount of speed lost per second
## How fast do we freefly?
@export var freefly_speed : float = 25.0
@export var gravity_modifier : float = 2.0

## Movement physics parameters
@export_group("Movement Physics")
@export var acceleration : float = 50.0  # how quickly we accelerate toward target speed
@export var friction : float = 40.0  # how quickly we slow down when not moving
@export var air_friction : float = 2.0  # friction while airborne
@export var slide_friction : float = 3.0  # reduced friction while sliding

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to Crouch.
@export var input_crouch : String = "crouch"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

## used to tell the action label what is currently happening
var active_actions : Array[String] = []

var is_crouching : bool = false
var is_sprinting : bool = false
var is_moving : bool = false
var is_sliding : bool = false
var control_strength : float = 1.0
var has_attacked_since_last_wall_run : bool = false


## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var camera: Node3D = $Head/Camera3D
@onready var tps_camera : Camera3D = $"Head/TPS Pivot/Third Person Camera"
@onready var tps_pivot: Node3D = $"Head/TPS Pivot"
var tps_camera_default_pos
var tps_camera_default_rot
var freelook : bool = false
@onready var equipment_manager = get_node('Head/Camera3D/Equipment Manager')
@onready var standing_collider: CollisionShape3D = $"Standing Collider"
@onready var crouching_collider: CollisionShape3D = $"Crouching Collider"
@onready var ray_cast_3d: RayCast3D = $RayCast3D
var collider  # active collider
@onready var model = $Model
@onready var model_animation_player = $"Model/AnimationPlayer"
@onready var audio_manager: Node3D = $"Audio Manager"

@export_group("Camera Adjustments")
# head position (used to move the camera while crouched / uncrouched)
@export var reg_head_position : float
var crouch_head_position : float = 1.1  # IF THIS IS CHANGED, ALSO MUST CHANGE THE CROUCHING COLLIDER HEIGHT TO MATCH!
var head_node_position : float
var camera_height_adjustment_duration : float = 0.12  # seconds
var camera_mode = true # true = fps, false = tps
# FOV adjustments
@export var sprinting_fov_adjustment : float = 6.0  # degrees | sliding will use this FOV as well
@export var crouching_fov_adjustment : float = -0.0  # degrees
var default_fov : float
var sprinting_fov : float
var crouching_fov : float
# FOV adjustment speed
var fov_adjustment_duration : float = 0.05  # seconds
# collider heights (for crouching)
var default_collider_height
var crouch_height

var can_wall_jump = true
var prev_wall_jump_side : Vector2  # for wall jumping
var prev_wall_run_jump_side : Vector2

var forcer_vector : Vector3 = Vector3(0,0,0)

@export_group('Essence')
@export var max_essence : int = 100
@export var essence : int = 100
@export var overessence : int = 0
# curves: X axis is how much health you have (%, 0.0-1.0), Y axis is multiplier for something
@export var essence_grav_curve: Curve
@export var essence_speed_curve: Curve
@export var essence_force_curve: Curve

@onready var boon_manager : Node3D = get_node('Boon Manager')

var unforceable = false
var boon_grav_mult : float = 1.0

@onready var ui_manager = get_node('/root/Game Manager/UI Manager/')

func _ready() -> void:
	reg_head_position = head.position.y
	PlayerManager.register_player(self)
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	
	head.position.y = reg_head_position
	
	default_fov = camera.fov
	sprinting_fov = default_fov + sprinting_fov_adjustment
	crouching_fov = default_fov + crouching_fov_adjustment
	
	collider = standing_collider
	crouching_collider.set_deferred("disabled", true)
	wall_jump_timer = 0
	
	tps_camera_default_pos = tps_camera.position
	tps_camera_default_rot = tps_camera.rotation
	
	if is_on_floor():
		was_just_on_ground = true

func _unhandled_input(event: InputEvent) -> void:
	if player_enabled:
		# Mouse capturing
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			game_manager.capture_mouse()
		#if Input.is_key_pressed(KEY_ESCAPE):
			#game_manager.release_mouse()
		
		# Look around
		#print(str(mouse_captured) + '||||' + str(event is InputEventMouseMotion))
		if mouse_captured and event is InputEventMouseMotion:
			rotate_look(event.relative)
		
		# Toggle freefly mode
		

func _physics_process(delta: float) -> void:
	
	# handle camera swap
	if Input.is_action_just_pressed('toggle_camera_mode'):
		toggle_cam_mode()
	# handle third person free look
	if Input.is_action_pressed('third_person_free_look') and not camera_mode:
		freelook = true
	else:
		freelook = false
		#tps_camera.position = tps_camera_default_pos
		tps_camera.rotation = tps_camera_default_rot
		
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()
	
	mouse_captured = game_manager.mouse_captured
	
	if player_enabled:
	# disabled player anims for now
		##handle animations
		#if not is_moving:
			#model_animation_player.play("idle")
		#elif is_sprinting:
			#model_animation_player.play("run")
			##audio_manager.play_movement_audio()
		#elif is_moving and not is_sprinting:
			#model_animation_player.play("walk")
			##audio_manager.play_movement_audio()
		
		if is_on_floor() or not is_on_wall():
			is_wall_running = false
		
		if not is_wall_running:
			wall_run_timer = 0.0
		
		if not can_wall_jump and is_on_floor():
			can_wall_jump = true
		
		if not can_wall_run and is_on_floor():
			can_wall_run = true
			
		
		if has_attacked_since_last_wall_run:
			can_wall_run = true
			can_wall_jump = true
			has_attacked_since_last_wall_run = false
		# reset FOV if not crouching or sprinting
		if not is_crouching and not is_sprinting and not is_sliding:
			adjust_to_default_fov()
			move_speed = base_speed
		
		# If freeflying, handle freefly and nothing else
		if can_freefly and freeflying:
			var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
			var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			motion *= freefly_speed * delta
			move_and_collide(motion)
			return
		
		if is_sliding:
			if not Input.is_action_pressed(input_crouch) or move_speed <= crouch_speed or not is_moving:
				move_speed = crouch_speed
				if 'sliding' in active_actions:
					active_actions.erase('sliding')
				is_crouching = true
				is_sliding = false
				is_sprinting = false
				
			else:
				var floor_dot = 0
				if is_on_floor():
					floor_dot = -global_transform.basis.z.dot(get_floor_normal())
				if not is_on_floor() or get_floor_angle() < 0.45:
					move_speed -= sliding_speed_loss * delta
				elif get_floor_angle() > 0.45:
					if floor_dot <= 0:
						move_speed -= sliding_speed_loss * 4 * delta # slow slide faster if going uphill
					if floor_dot > 0 and move_speed < sliding_speed:  # regain max slide speed if going downwards
						move_speed += sliding_speed_loss * delta
				if move_speed > sliding_speed:
					move_speed = sliding_speed
				
				
		if is_wall_running:
			if wall_run_timer <= 0:
				is_wall_running = false
				current_wall_run_grav_mod = wall_run_grav_mod
				
		# Apply gravity to velocity
		if has_gravity:
			if not is_on_floor() and not is_wall_running:
				velocity += get_gravity() * gravity_modifier * delta * essence_grav_curve.sample(float(essence)/100) * boon_grav_mult
			elif is_wall_running:
				velocity += get_gravity() * gravity_modifier * delta * current_wall_run_grav_mod * essence_grav_curve.sample(float(essence)/100) * boon_grav_mult

		if (is_on_wall_only() and get_slide_collision_count() > 1) and Input.is_action_pressed('move_forward') and is_sprinting and velocity.y <= 0:
			
			var wall_collision_normal = get_slide_collision(1).get_normal()
			var wall_side_vector = Vector2(wall_collision_normal.x, wall_collision_normal.z)
			if can_wall_run or prev_wall_run_jump_side != wall_side_vector:
				# check to make sure the player is somewhat orthogonal to the wall
				var wall_normal = get_wall_normal()
				var forward_dir = -global_transform.basis.z
				var wall_dot = forward_dir.dot(wall_normal)
				if wall_dot < 0.5 and wall_dot > -0.5:
					wall_run_timer = wall_run_length
					current_wall_run_grav_mod = wall_run_grav_mod
					velocity.y = 0
					can_wall_run = false
					is_wall_running = true
					prev_wall_run_jump_side = wall_side_vector
					wall_run_normal = Vector3(-wall_collision_normal.x, wall_collision_normal.y, -wall_collision_normal.z)
				

		# Apply jumping
		if can_jump:
			if 'jump' in active_actions:
					active_actions.erase('jump')
			if Input.is_action_just_pressed(input_jump):
				is_wall_running = false
				if is_on_floor():  # regular jump
					if 'jump' not in active_actions:
						active_actions.append('jump')
					if is_sprinting:
						velocity.y = jump_velocity_sprinting
					else:
						velocity.y = jump_velocity_default
					audio_manager.play_jump_sfx()
				elif is_on_wall_only() and get_slide_collision_count() > 1:  # wall jump
					var wall_collision_normal = get_slide_collision(1).get_normal()
					var wall_side_vector = Vector2(wall_collision_normal.x, wall_collision_normal.z)
					
					if can_wall_jump or prev_wall_jump_side != wall_side_vector:
						# Set wall jump direction (horizontal push away from wall)
						wall_jump_direction = Vector3(wall_collision_normal.x, 0, wall_collision_normal.z).normalized()
						wall_jump_timer = wall_jump_momentum_time
						
						# Apply immediate horizontal velocity
						velocity.x = wall_jump_direction.x * wall_jump_push_strength
						velocity.z = wall_jump_direction.z * wall_jump_push_strength
						
						prev_wall_jump_side = wall_side_vector
						can_wall_jump = false
						
						if 'jump' not in active_actions:
							active_actions.append('jump')
						if is_sprinting:
							velocity.y = jump_velocity_sprinting
						else:
							velocity.y = jump_velocity_default
						audio_manager.play_jump_sfx()

		# Modify speed based on sprinting
		if can_sprint and Input.is_action_pressed(input_sprint) and is_moving and Input.is_action_pressed(input_forward):
			is_sprinting = true
			move_speed = sprint_speed
			adjust_to_sprinting_fov()
			if 'sprint' not in active_actions:
				active_actions.append('sprint')
		else:
			is_sprinting = false
			if 'sprint' in active_actions:
					active_actions.erase('sprint')
					
		# Modify speed based on crouching
		if can_crouch and Input.is_action_pressed(input_crouch):
			# DEBUG!! hurt player
			#essence -= 1
			# if sprinting currently: slide, then go into crouch
			if is_sprinting and ((is_on_floor() and -global_transform.basis.z.dot(get_floor_normal()) >= 0) or not is_on_floor()):
				# cannot start slide if going uphill
				apply_force(0.2, Vector3(0,-1,0), true, 0.2, true)
				swap_collider(true)
				is_sliding = true
				is_sprinting = false
				can_sprint = false
				adjust_camera_to_crouching()
				move_speed = sliding_speed
				if 'sliding' not in active_actions:
					active_actions.append('sliding')
			elif not is_sliding: # if not sprinting, default crouch
				swap_collider(true)
				can_sprint = false
				is_crouching = true
				move_speed = crouch_speed
				adjust_camera_to_crouching()
				adjust_to_crouching_fov()
				if 'crouch' not in active_actions:
					active_actions.append('crouch')	
		else:
			# if you try to uncrouch whilst under a surface that you could not enter while standing, don't uncrouch
			ray_cast_3d.force_raycast_update()
			if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider() is CSGCombiner3D:
				is_crouching = true
				if 'crouch' not in active_actions:
					active_actions.append('crouch')
				pass
			else:
				swap_collider(false)
				can_sprint = true
				is_crouching = false
				adjust_camera_to_standing()
				if 'crouch' in active_actions:
						active_actions.erase('crouch')	

		# Apply desired movement to velocity (REWORKED SECTION)
		if can_move:
			# Determine control strength based on state
			if not is_sliding:
				control_strength = 1.0
			else:
				control_strength = 0.07
			
			var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
			
			# Update active actions for UI
			if input_dir[1] > 0:
				if 'move forward' in active_actions:
					active_actions.erase('move forward')
				if 'move backward' not in active_actions:
					active_actions.append('move backward')
			elif input_dir[1] < 0:
				if 'move forward' not in active_actions:
					active_actions.append('move forward')
				if 'move backward' in active_actions:
					active_actions.erase('move backward')
			else:
				if 'move forward' in active_actions:
					active_actions.erase('move forward')
				if 'move backward' in active_actions:
					active_actions.erase('move backward')
					
			if input_dir[0] > 0:
				if 'move left' in active_actions:
					active_actions.erase('move left')
				if 'move right' not in active_actions:
					active_actions.append('move right')
			elif input_dir[0] < 0:
				if 'move left' not in active_actions:
					active_actions.append('move left')
				if 'move right' in active_actions:
					active_actions.erase('move right')
			else:
				if 'move left' in active_actions:
					active_actions.erase('move left')
				if 'move right' in active_actions:
					active_actions.erase('move right')
			
			var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			
			# Adjust control during wall jump
			if wall_jump_timer > 0:
				var time_ratio = wall_jump_timer / wall_jump_momentum_time
				control_strength = lerp(1.0, wall_jump_air_control, time_ratio)
			
			# Reduce control in air
			if not is_on_floor():
				control_strength *= air_strafe_mobility
			
			# PHYSICS-BASED MOVEMENT: Add acceleration instead of setting velocity
			if move_dir:
				is_moving = true
				
				# Calculate target velocity
				var target_velocity = move_dir * move_speed * essence_speed_curve.sample(float(essence)/100)
				
				# Add acceleration toward target velocity (only affects horizontal movement)
				var velocity_horizontal = Vector3(velocity.x, 0, velocity.z)
				var acceleration_force = (target_velocity - velocity_horizontal) * acceleration * control_strength * delta
				
				velocity.x += acceleration_force.x
				velocity.z += acceleration_force.z
			else:
				is_moving = false
				
				# Apply friction when not actively moving
				var current_friction = friction
				
				# Adjust friction based on state
				if not is_on_floor():
					current_friction = air_friction
				elif is_sliding:
					current_friction = slide_friction
				
				# During wall jump, apply minimal friction
				if wall_jump_timer > 0:
					current_friction *= 0.1
				
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
			is_moving = false
			# When movement is disabled, still allow external forces but apply strong friction
			var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
			if horizontal_velocity.length() > 0.01:
				var friction_vector = horizontal_velocity.normalized() * friction * 2.0 * delta
				if friction_vector.length() > horizontal_velocity.length():
					velocity.x = 0
					velocity.z = 0
				else:
					velocity.x -= friction_vector.x
					velocity.z -= friction_vector.z
		
		# decrease wall jump timer
		if wall_jump_timer > 0:
			wall_jump_timer -= delta
			
		# decrease wall run timer
		if wall_run_timer > 0:
			apply_force(1, wall_run_normal, false, 0.0, true)
			wall_run_timer -= delta
			current_wall_run_grav_mod += wall_run_decay * delta
		
		# Use velocity to actually move
		if is_wall_running:
			if abs(velocity.x) + abs(velocity.z) < wall_run_min_speed:
				is_wall_running = false
		
		# Apply external forces
		velocity += forcer_vector
		move_and_slide()
		forcer_vector = Vector3(0,0,0)
		
		if is_on_floor() and not was_just_on_ground:
			audio_manager.play_land_sfx(y_velocity_pre_impact)
			was_just_on_ground = true
		
		if not is_on_floor():
			y_velocity_pre_impact = velocity.y
			was_just_on_ground = false
			
	if freelook and not camera_mode:
		tps_camera.look_at(head.global_position, Vector3.UP)

## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	
	if not freelook:
		rotate_y(look_rotation.y)
		head.transform.basis = Basis()
		head.rotate_x(look_rotation.x)
		#equipment_manager.rotate_active_equipment(Basis(), look_rotation.x)
	else:
		tps_pivot.transform.basis = Basis()
		tps_pivot.rotate_y(look_rotation.y)
		tps_pivot.rotate_x(look_rotation.x)


func enable_freefly():
	if not freeflying:
		collider.disabled = true
		freeflying = true
		velocity = Vector3.ZERO

func disable_freefly():
	if freeflying:
		collider.disabled = false
		freeflying = false

## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false
		
		
## TWEENS!!! 

func adjust_to_sprinting_fov():
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", sprinting_fov, fov_adjustment_duration)

func adjust_to_crouching_fov():
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", crouching_fov, fov_adjustment_duration)
	
func adjust_to_default_fov():
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", default_fov, fov_adjustment_duration)
	
func adjust_camera_to_crouching():
	var tween = get_tree().create_tween()
	tween.tween_property(head, "position:y", crouch_head_position, camera_height_adjustment_duration)
	
func adjust_camera_to_standing():
	var tween = get_tree().create_tween()
	tween.tween_property(head, "position:y", reg_head_position, camera_height_adjustment_duration)
	
func swap_collider(now_crouching : bool):
	if now_crouching:
		collider = crouching_collider
		standing_collider.set_deferred("disabled", true)
		crouching_collider.set_deferred("disabled", false)
	else:
		collider = standing_collider
		crouching_collider.set_deferred("disabled", true)
		standing_collider.set_deferred("disabled", false)
		
func apply_force(strength : float, direction : Vector3, sustained : bool = false, duration : float = 0.0, override_unforceable : bool = false):
	if (not unforceable and not freeflying) or override_unforceable:
		if sustained:
			var force_object = preload("res://Scenes/Physics/forcer.tscn").instantiate()
			force_object.force_strength = strength
			force_object.force_direction = direction
			force_object.is_sustained = sustained
			force_object.duration = duration
			add_child(force_object)
		else:
			forcer_vector += direction * strength * essence_force_curve.sample(float(essence) / 100)
		
func hit_by_weapon(amount : int, overheal : bool = false, dedicated_overheal : bool = false):  # REQUIREMENT OF WEAPON TARGETS GROUP
	#print('player recieved damage: ' + str(amount))
	if amount > 0:
		if not invincible:
			audio_manager.play_hit_sfx()
			var remainder = amount
			if overessence > 0:
				if amount > overessence:
					remainder = amount - overessence 
					overessence = 0
				else:
					remainder = 0
					overessence -= amount
			essence -= remainder
			if essence < 0:
				essence = 0
	
	if essence <= 0 and not invincible:
		game_manager.signal_killed(self)
		invincible = true
	
	if amount < 0:
		if dedicated_overheal:
			overessence -= amount
		elif overheal:
			if essence - amount > 100:
				overessence -= (100 - (essence - amount))
				essence -= (amount + (100 - (essence - amount)))
			else:
				essence -= amount
		else:
			essence -= amount
		if essence > 100:
			essence = 100

func round_reset(weapon : String):
	reset_essence()
	invincible = false
	if not weapon == 'null':
		equipment_manager.clear_inventory()
		equipment_manager.add_equipment(0, weapon, true, true)
	boon_manager.clear_boons()
	velocity = Vector3(0,0,0)
	essence_blast.reset_cooldown()

func reset_essence():
	essence = max_essence
	overessence = 0
	
func toggle_weapons(mode : bool, keep_weapons_visible : bool = false):
	if mode:  # toggle on
		equipment_manager.show()
		equipment_manager.disabled = false
		equipment_manager.enable_equipment()
		essence_blast.enabled = true
	else:  # toggle off
		if not keep_weapons_visible:
			equipment_manager.hide()
		else:
			equipment_manager.show()
		essence_blast.enabled = false
		equipment_manager.disabled = true
		equipment_manager.disable_equipment()

func update_essence_blast_status(cooldown : float):
	if ui_manager.get_child(1).has_node('HUD'):
		ui_manager.get_child(1).get_node('HUD').set_essence_blast_cooldown(cooldown)
		
		
func toggle_cam_mode():
	print('toggling cam')
	if camera_mode:  # become third person
		tps_camera.make_current()
		camera_mode = false
	else:  # become first person
		camera.make_current()
		camera_mode = true
