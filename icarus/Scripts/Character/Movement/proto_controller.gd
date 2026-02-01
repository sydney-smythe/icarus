# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D



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
@export var can_freefly : bool = false

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
# Wall run parameters
@export var wall_run_length : float = 3.0  # seconds you can run on the wall for straight (before gravity regains full control of y)
@export var wall_run_decay : float = 0.2  # higher = the quicker gravity regains control
var wall_run_grav_mod : float = 0.0  # modifies how strong gravity will be this physics process call
var wall_run_timer : float = 0.0  # when > 0, applies wall run protocol
var is_wall_running : bool = false
var current_wall_run_grav_mod : float  # is the agent that acts on gravity, the other one dictates this one's starting value
var can_wall_run : bool = true
## How fast do we run?
@export var sprint_speed : float = 9.2
## How fast are we when crouching?
@export var crouch_speed : float = 4.0
@export var sliding_speed : float = 9.9
@export var sliding_speed_loss : float = 2.9  # amount of speed lost per second
## How fast do we freefly?
@export var freefly_speed : float = 25.0
@export var gravity_modifier : float = 2.0

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

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var camera: Node3D = $Head/Camera3D
@onready var standing_collider: CollisionShape3D = $"Standing Collider"
@onready var crouching_collider: CollisionShape3D = $"Crouching Collider"
@onready var ray_cast_3d: RayCast3D = $RayCast3D
var collider  # active collider


@export_group("Camera Adjustments")
# head position (used to move the camera while crouched / uncrouched)
@export var reg_head_position : float = 1.7
var crouch_head_position : float = 1.1  # IF THIS IS CHANGED, ALSO MUST CHANGE THE CROUCHING COLLIDER HEIGHT TO MATCH!
var head_node_position : float
var camera_height_adjustment_duration : float = 0.12  # seconds
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

func _ready() -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
			if 'freeflying' not in active_actions:
				active_actions.append('freeflying')
		else:
			disable_freefly()
			if 'freeflying' in active_actions:
				active_actions.erase('freeflying')

func _physics_process(delta: float) -> void:
	
	if not can_wall_jump and is_on_floor():
		can_wall_jump = true
	
	if not can_wall_run and is_on_floor():
		can_wall_run = true
	
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
			move_speed -= sliding_speed_loss * delta
			
			
	if is_wall_running:
		if wall_run_timer <= 0:
			is_wall_running = false
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor() and not is_wall_running:
			velocity += get_gravity() * gravity_modifier * delta
		elif is_wall_running:
			velocity += get_gravity() * gravity_modifier * delta * current_wall_run_grav_mod

	if is_on_wall_only() and get_slide_collision_count() > 1:
		
		var wall_collision_normal = get_slide_collision(1).get_normal()
		var wall_side_vector = Vector2(wall_collision_normal.x, wall_collision_normal.z)
		if can_wall_run or prev_wall_run_jump_side != wall_side_vector:
			wall_run_timer = wall_run_length
			current_wall_run_grav_mod = wall_run_grav_mod
			velocity.y = 0
			can_wall_run = false
			is_wall_running = true
			prev_wall_run_jump_side = wall_side_vector

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
		# if sprinting currently: slide, then go into crouch
		swap_collider(true)
		if is_sprinting:
			is_sliding = true
			is_sprinting = false
			can_sprint = false
			adjust_camera_to_crouching()
			move_speed = sliding_speed
			if 'sliding' not in active_actions:
				active_actions.append('sliding')
		elif not is_sprinting and not is_sliding: # if not sprinting, default crouch
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

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		#if not is_on_floor():
			#input_dir = Vector2(input_dir[0] * 0.01, input_dir[1])
		#print(str(input_dir))
		# capture the current movement inputs for UI
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
		
		# calculate how much control the player has during wall jump
		var control_strength = 1.0
		if wall_jump_timer > 0:
			# gradually restore control as timer runs out
			var time_ratio = wall_jump_timer / wall_jump_momentum_time
			control_strength = lerp(1.0, wall_jump_air_control, time_ratio)
		if not is_on_floor():
			control_strength *= air_strafe_mobility
		
		if move_dir:
			is_moving = true
			# apply movement with reduced control during wall jump
			var target_velocity_x = move_dir.x * move_speed 
			var target_velocity_z = move_dir.z * move_speed
			
			#print('adj move speed: ' + str(move_speed * control_strength))
			velocity.x = move_toward(velocity.x, target_velocity_x, move_speed * control_strength)
			velocity.z = move_toward(velocity.z, target_velocity_z, move_speed * control_strength)
		else:
			is_moving = false
			# only apply friction when not in wall jump momentum
			if wall_jump_timer <= 0:
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
			else:
				# apply minimal friction during wall jump
				velocity.x = move_toward(velocity.x, 0, move_speed * 0.1)
				velocity.z = move_toward(velocity.z, 0, move_speed * 0.1)
	else:
		is_moving = false
		velocity.x = 0
		velocity.y = 0
	
	# decrease wall jump timer
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
		
	# decrease wall run timer
	if wall_run_timer > 0:
		wall_run_timer -= delta
	# Use velocity to actually move
	move_and_slide()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


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
