extends Node3D

# this script is a generic script used to handle inputs and base information such as ammo, reloading, and firing calls

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
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if check_fire:
		if Input.is_action_pressed('primary_action'):
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
	
	if sec_is_reloading:
		if sec_reload_timer > 0:
			sec_reload_timer -= delta
		else:
			#print('secondary reload complete')
			sec_is_reloading = false
			sec_current_ammo = sec_magazine_size
		
	if has_sec_action and player_controlled:
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
	if player_controlled:
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
		prim_is_reloading = true
		#print('starting reload')
		prim_reload_timer = prim_reload_time		

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
	prim_fire_delay_timer = prim_fire_delay
	if prim_fire_type == Prim_fire_type.BURST:
		for i in range(0,prim_burst_size):
			if prim_current_ammo > 0:
				weapon_behaviour.primary_fire()
				prim_current_ammo -= 1
				#print('fired shot ' + str(i+1))
				await get_tree().create_timer(prim_burst_item_delay).timeout
			else:
				print('out of ammo, not firing')
	else:
		weapon_behaviour.primary_fire()
		prim_current_ammo -= 1
		if prim_current_ammo <= 0:
			print('out of primary ammo')
	
		
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
				else:
					print('out of ammo, not firing')
			else:
				weapon_behaviour.secondary_fire()
				#print('fired shot ' + str(i+1))
				await get_tree().create_timer(sec_burst_item_delay).timeout
	elif sec_fire_type == Sec_fire_type.ACTION_SINGLE:
		weapon_behaviour.primary_fire()
		if sec_has_ammo:
			prim_current_ammo -= 1
			if prim_current_ammo <= 0:
				print('out of secondary ammo')
