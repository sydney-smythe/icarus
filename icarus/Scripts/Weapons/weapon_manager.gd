extends Node3D

# this script is a generic script used to handle inputs and base information such as ammo, reloading, and firing calls
var player: CharacterBody3D
var arm_anim_manager : Node3D
@export var is_enabled = true
@export_group("PRIMARY ACTION")
enum Prim_fire_type {
	SINGLE,
	BURST,
	AUTO
}
@export var prim_fire_type : Prim_fire_type = Prim_fire_type.SINGLE
@export var prim_magazine_size : int = 10
@export var prim_reload_time : float = 1.0
## FIRE DELAY 
# for single fire: min time between shots fired
# for burst fire: fire delay - time between the bursts | burst item delay - time between the shots in the burst
# for auto: min time between shots fired
@export var prim_fire_delay : float = 0.2 
@export var prim_burst_item_delay : float = 0.1
@export var prim_burst_size : int = 3
var prim_current_ammo : int
var prim_fire_delay_timer
var prim_reload_timer
var prim_is_reloading : bool = false

var ai_prim_fire_length_max : float = 1.0
var ai_prim_fire_length_min : float = 0.1
var ai_prim_fire_timer : float = 0

@export_group("SECONDARY ACTION")
enum Sec_fire_type {
	SCOPE,
	ACTION_SINGLE,
	ACTION_BURST,
	ACTION_AUTO,
}
@export var sec_fire_type : Sec_fire_type = Sec_fire_type.SCOPE
@export var sec_has_ammo : bool = false
var sec_is_scoping : bool = false  # only if scope type
var sec_current_ammo : int  # only if has_ammo = true
@export var sec_magazine_size : int = 10  # only if has_ammo = true
@export var sec_reload_time : float = 1.0  # only if has_ammo = true
var sec_reload_timer  # only if has_ammo = true
var sec_is_reloading : bool = false  # only if has_ammo = true
## FIRE DELAY 
# for single fire: min time between shots fired
# for burst fire: fire delay - time between the bursts | burst item delay - time between the shots in the burst
# for auto: min time between shots fired
@export var has_sec_action : bool = false
@export var sec_fire_delay : float = 0.2  # only if action type
@export var sec_burst_item_delay : float = 0.1  # only if action type
@export var sec_burst_size : int = 3  # only if action type
var sec_fire_delay_timer  # only if action type

var weapon_behaviour
var animation_manager
@export var player_controlled = false

var check_fire : bool = false
@onready var game_manager = get_node('/root/Game Manager/')
@onready var equipment_manager = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weapon_behaviour = get_child(0)
	animation_manager = weapon_behaviour.get_child(0)
	
	prim_reload_timer = prim_reload_time
	prim_fire_delay_timer = 0
	prim_current_ammo = prim_magazine_size
	
	sec_reload_timer = sec_reload_time
	sec_fire_delay_timer = 0
	sec_current_ammo = sec_magazine_size
	call_deferred('late_ready')
	
func late_ready():
	arm_anim_manager = equipment_manager.get_node('Arm Anim Manager')
	if player_controlled:
		player = PlayerManager.get_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	is_enabled = not equipment_manager.disabled
	if not is_enabled:
		weapon_behaviour.full_cooldown_timer = 0
	if ai_prim_fire_timer > 0:
		ai_prim_fire_timer -= delta
		if equipment_manager.host.target_mode:
			activate_primary()
			
	if check_fire and not game_manager.is_paused:
		if Input.is_action_pressed('primary_action') and is_enabled:
				activate_primary()
	
	if prim_fire_delay_timer > 0:
		prim_fire_delay_timer -= delta
	if sec_fire_delay_timer > 0:
		sec_fire_delay_timer -= delta
		
	if prim_is_reloading:
		if prim_reload_timer > 0:
			prim_reload_timer -= delta
		else:
			#print('primary reload complete')
			prim_is_reloading = false
			prim_current_ammo = prim_magazine_size
			if player_controlled:
				equipment_manager.update_hud_ammo(prim_current_ammo)
	
	if sec_is_reloading:
		if sec_reload_timer > 0:
			sec_reload_timer -= delta
		else:
			#print('secondary reload complete')
			sec_is_reloading = false
			sec_current_ammo = sec_magazine_size
		
	if has_sec_action and player_controlled and not game_manager.is_paused:
		if not sec_is_reloading or not sec_has_ammo:
			if sec_fire_type == Sec_fire_type.ACTION_BURST or sec_fire_type == Sec_fire_type.ACTION_SINGLE:
				if Input.is_action_just_pressed('secondary_action') and (sec_current_ammo > 0 or not sec_has_ammo):
					secondary_action()
			elif sec_fire_type == Sec_fire_type.ACTION_AUTO:
				if Input.is_action_pressed('secondary_action') and (sec_current_ammo > 0 or not sec_has_ammo):
					secondary_action()
			elif sec_fire_type == Sec_fire_type.SCOPE:
				if sec_is_scoping and Input.is_action_just_released('secondary_action'):
					sec_is_scoping = false
					secondary_action()
				elif not sec_is_scoping and Input.is_action_just_pressed('secondary_action'):
					sec_is_scoping = true
					secondary_action()

func _input(_event: InputEvent) -> void:
	if player_controlled and not game_manager.is_paused and is_enabled and not animation_manager.active_anim:
		if prim_fire_type == Prim_fire_type.AUTO:
			if Input.is_action_pressed('primary_action'):
				check_fire = true
				activate_primary()
			elif Input.is_action_just_released('primary_action'):
				check_fire = false
		else:
			if Input.is_action_just_pressed('primary_action'):
				activate_primary()
			
		if ((prim_current_ammo < prim_magazine_size and Input.is_action_just_pressed('reload')) or (prim_current_ammo == 0 and Input.is_action_just_pressed('primary_action'))) and not prim_is_reloading:
			reload()
		
func reload():
	arm_anim_manager.play_reload()
	animation_manager.play_reload()
	weapon_behaviour.play_reload_sfx()
	prim_is_reloading = true
	#print('starting reload')
	prim_reload_timer = prim_reload_time * equipment_manager.reload_mult		

func ai_activate_primary():
	if prim_fire_type == Prim_fire_type.AUTO:
		if not ai_prim_fire_timer > 0:
			ai_prim_fire_timer = randf_range(ai_prim_fire_length_min, ai_prim_fire_length_max)
	else:
		activate_primary()

func activate_primary():
	if not prim_is_reloading:
		if prim_current_ammo > 0:
			if prim_fire_type == Prim_fire_type.BURST or prim_fire_type == Prim_fire_type.SINGLE:
				if prim_fire_delay_timer <= 0:
					if prim_current_ammo > 0:
						primary_action()
			elif prim_fire_type == Prim_fire_type.AUTO:
				if prim_fire_delay_timer <= 0:
					if prim_current_ammo > 0:
						primary_action()
		else:
			reload()
	
		
func primary_action():
	prim_fire_delay_timer = prim_fire_delay * equipment_manager.prim_fire_rate_mult
	arm_anim_manager.play_fire()
	if prim_fire_type == Prim_fire_type.BURST:
		for i in range(0,prim_burst_size):
			if prim_current_ammo > 0:
				weapon_behaviour.primary_fire()
				prim_current_ammo -= 1
				#print('fired shot ' + str(i+1))
				await get_tree().create_timer(prim_burst_item_delay).timeout
			else:
				weapon_behaviour.play_no_ammo_sfx()
				break
				#print('out of ammo, not firing')
			if player_controlled:
				equipment_manager.update_hud_ammo(prim_current_ammo)
	else:
		weapon_behaviour.primary_fire()
		prim_current_ammo -= 1
		if player_controlled:
			equipment_manager.update_hud_ammo(prim_current_ammo)
		#if prim_current_ammo <= 0:
			#print('out of primary ammo')
	
		
func secondary_action():
	if sec_fire_type == Sec_fire_type.SCOPE:
		weapon_behaviour.secondary_fire()
	elif sec_fire_type == Sec_fire_type.ACTION_BURST:
		for i in range(0, sec_burst_size):
			if sec_has_ammo:
				if sec_current_ammo > 0:
					weapon_behaviour.secondary_fire()
					sec_current_ammo -= 1
					#print('fired shot ' + str(i+1))
					await get_tree().create_timer(sec_burst_item_delay).timeout
				#else:
					#print('out of ammo, not firing')
			else:
				weapon_behaviour.secondary_fire()
				#print('fired shot ' + str(i+1))
				await get_tree().create_timer(sec_burst_item_delay).timeout
	elif sec_fire_type == Sec_fire_type.ACTION_SINGLE:
		weapon_behaviour.primary_fire()
		if sec_has_ammo:
			prim_current_ammo -= 1
			#if prim_current_ammo <= 0:
				#print('out of secondary ammo')
				
func play_equip_sfx():
	weapon_behaviour.play_equip_sfx()
