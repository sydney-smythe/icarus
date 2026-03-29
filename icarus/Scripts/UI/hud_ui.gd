extends Control

@export var essence: Label
@export var active_weapon_name : Label
var weapon_names : Array[String] = ['EMPTY', 'EMPTY']
@export var weapon_one_ammo : Label
@export var weapon_two_ammo : Label
@export var boon_names: Label
@export var boon_times: Label
@export var essence_blast_counter : Label
@onready var player = null
var equipment_manager
var boon_manager
var blast_timer : float = 0.0
var active_equipment_index = -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerManager.get_player()
	equipment_manager = player.equipment_manager
	boon_manager = player.get_node('Boon Manager')
	print('ca;;;')
	player.equipment_manager.update_hud_weapons()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if player:
		if blast_timer > 0:
			essence_blast_counter.text = str(int(blast_timer))
			blast_timer -= delta
		else:
			essence_blast_counter.text = 'F'  # for now, hardcoded button. will change when buttons can be rebound
		if player.overessence != 0:
			essence.text = 'ESSENCE: ' + str(player.essence) + ' + ' + str(player.overessence)
		else:
			essence.text = 'ESSENCE: ' + str(player.essence) 
		
		#if equipment_manager.active_equipment != -1:
			#weapon_one_name.text = str(equipment_manager.inventory_array[equipment_manager.active_equipment][0])
			#weapon_one_ammo.text = str(equipment_manager.get_child(equipment_manager.active_equipment).get_child(0).prim_current_ammo)
		#else:
			#weapon_one_name.text = 'UNARMED'
			#weapon_one_ammo.text = '-'
		
		boon_names.text = ''
		boon_times.text = ''
		#print(str(boon_manager.active_boons))
		for boon in boon_manager.active_boons:
			boon_names.text = boon_names.text + boon + '\n'
			boon_times.text = boon_times.text + str(int(boon_manager.active_boons[boon])) + 's\n'
		boon_names.text = boon_names.text.left(boon_names.text.length()-1)
		boon_times.text = boon_times.text.left(boon_times.text.length()-1)

func set_essence_blast_cooldown(cooldown : float):
	blast_timer = cooldown
	
func update_weapon_info(active_index : int, inventory_array : Array):  # updates the name and ammo of the weapon at this index (in the future, the image as well)
	print(str(inventory_array))
	# weapon one
	if inventory_array[0][2] != null:
		weapon_names[0] = inventory_array[0][0]
		update_ammo(0, inventory_array[0][2].get_child(0).prim_current_ammo)
	else:
		#print('empty 1')
		weapon_names[0] = 'EMPTY'
		update_ammo(0, -1)
	if inventory_array[1][2] != null:
		weapon_names[1] = inventory_array[1][0]
		update_ammo(1, inventory_array[1][2].get_child(0).prim_current_ammo)
	else:
		#print('empty 2')
		weapon_names[1] = 'EMPTY'
		update_ammo(1, -1)
	#update_ammo(index, ammo)
	if active_equipment_index != active_index:
		set_active_weapon_ui(active_index)

func update_ammo(index : int, ammo : int):  # updates the ammo counter of the desired weapon
	var ammo_text = str(ammo)
	if ammo < 0:
		ammo_text = '-'
		
	if index == 0:
		weapon_one_ammo.text = ammo_text
	else:
		weapon_two_ammo.text = ammo_text
	if active_equipment_index != index:
		set_active_weapon_ui(index)

func set_active_weapon_ui(active_index : int):
	active_equipment_index = active_index
	active_weapon_name.text = weapon_names[active_index]
