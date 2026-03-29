extends Node3D

@export var head : Node3D
@export var host : CharacterBody3D
@export var inventory_size : int = 2
var default_equipment : String = "0"  # for now, default equipment is the Default Weapon. Later, will probably be fists.
var inventory
var inventory_array : Array[Array] = []  # contains a sub-array for each equipped item: [String: Item Name, Bool: Can be Equipped?, Node: Reference to the weapon node]
var active_equipment : int = -1  # index of child nodes
var data_manager
var ui_manager
@export var player_controlled = true
var disabled = false
var attachment_point : Node3D
var prim_fire_rate_mult : float = 1.0 # lower = faster fire rate
var reload_mult : float = 1.0 # lower = faster reload
@export var animation_player : AnimationPlayer
#var active_model : Node3D
@export var weapon_anchor : Marker3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if player_controlled:
	attachment_point = get_node("Arms_Rig/Skeleton3D/BoneAttachment3D/Attachment Point")
	#else:
		#attachment_point = self
	data_manager = get_node("/root/Game Manager/Sub Managers/Data Manager/")
	ui_manager = get_node("/root/Game Manager/SubViewportContainer/SubViewport/UI Manager/")
	host = get_parent().get_parent().get_parent()
	head = get_parent().get_parent()
	for i in range(0,inventory_size):  # for now, create empty child nodes as temp item placeholders 
		var temp_child = Node3D.new()
		temp_child.name = "EMPTY SLOT " + str(i)
		attachment_point.add_child(temp_child)
		attachment_point.get_child(i).hide()
		attachment_point.get_child(i).process_mode = Node.PROCESS_MODE_DISABLED
		#print("Created empty inventory slot")
		inventory_array.append([("EMPTY SLOT " + str(i)), false, null])
	#print(str(inventory_array))
	
	#call_deferred('late_ready')  # used to add the default equipment, but waits til after the data manager is ready.
	update_hud_weapons()
	
func late_ready():
	# add the default equipment to slot 0
	#if not player_controlled:
		#add_equipment(0, default_equipment, true, true)
	pass
		#add_equipment(equipment_index : int, equipment_id : String, can_equip : bool = true, is_auto_active : bool = false, auto_assign_index = false)
	#add_equipment(0, default_equipment, true, true)  # add and equip the default weapon
	#print(str(inventory_array))
	#add_equipment(1, default_equipment, true, false)  # add and equip the default weapon
	#print(str(inventory_array))
	#print(str(active_equipment))
 
func _process(_delta: float) -> void:
	# handles swapping weapon inputs
	# currently handles up to 3 equips, probably will end up only having 2 tho
	# number press inputs
	if player_controlled and not disabled:
		if Input.is_action_just_pressed('equip_1'):
			if inventory_array[0][1]:  # if can be equipped
				swap_active_equipment(0)
			else:
				print('cannot swap to equip 0')
		if Input.is_action_just_pressed('equip_2'):
			if inventory_array[1][1]:  # if can be equipped
				swap_active_equipment(1)
			else:
				print('cannot swap to equip 1')
		#if Input.is_action_just_pressed('equip_3'):
			#if inventory_array[2][1]:  # if can be equipped
				#swap_active_equipment(2)
			#else:
				#print('cannot swap to equip 2')
		# scroll inputs
		if Input.is_action_just_pressed("cycle_equip_next"):
			for i in range(0,inventory_size):
				var index = (i + active_equipment + 1) % inventory_size
				if inventory_array[index][1] and index != active_equipment:
					swap_active_equipment(index)
					break
		
		if Input.is_action_just_pressed("cycle_equip_prev"):
			for i in range(inventory_size, 0, -1):
				var index = (i + active_equipment - 1) % inventory_size
				if inventory_array[index][1] and index != active_equipment:
					swap_active_equipment(index)
					break

func disable_equipment():
	var current_active = attachment_point.get_child(active_equipment)
	#disabled = true
	current_active.hide()
	current_active.process_mode = Node.PROCESS_MODE_DISABLED

func enable_equipment():
	var current_active = attachment_point.get_child(active_equipment)
	#disabled = false
	current_active.show()
	current_active.process_mode = Node.PROCESS_MODE_ALWAYS

func swap_active_equipment(new_active_index : int, override_same_swap = false):
	# override same swap is only used when replacing a weapon when equipping a new one in the active slot
	if not new_active_index == active_equipment or override_same_swap:
		if not new_active_index > inventory_size - 1:
			if not inventory_array[new_active_index][1] == false:  # only works if you can swap to the new index
				var current_active = attachment_point.get_child(active_equipment)
				var new_active = attachment_point.get_child(new_active_index)
				current_active.hide()
				current_active.process_mode = Node.PROCESS_MODE_DISABLED
				new_active.show()
				new_active.process_mode = Node.PROCESS_MODE_ALWAYS
				new_active.get_node('Weapon Manager').play_equip_sfx()
				active_equipment = new_active_index
				#active_model = new_active.get_child(0).get_child(0).get_child(0).get_child(0)  # get the pivot node
				print('[Equip Manager] Active equipment: ' + str(new_active_index))
		else:
			print('[Equip Manager] Error: equipment index is out of range.')
	else:
		print('[Equip Manager] Warning: attempting to swap to already active equipment.')
	
	if not player_controlled:
		host.set_attack_range()
	update_hud_weapons()

func add_equipment(equipment_index : int, equipment_id : String, can_equip : bool = true, is_auto_active : bool = false, auto_assign_index = false):
	# if auto assign index, find the first empty index, and if there are none, replace current weapon
	if auto_assign_index:
		equipment_index = active_equipment
		for index in range(0, inventory_size):
			#print(inventory_array[index][0].to_lower())
			if 'EMPTY' in inventory_array[index][0] or 'node' in inventory_array[index][0].to_lower() or 'slot' in inventory_array[index][0].to_lower():
				equipment_index = index
				break
	
	# rename the new node if a child with the same name already exists
	var equip_name : String = data_manager.weapon_dict[equipment_id][1]
	var name_already_exists : bool = false
	if has_node(equip_name):
		print('[Equip Manager]: Child with this name already exists. Renaming new node.')
		name_already_exists = true
		equip_name = equip_name + ' ' + str(equipment_index)
	
	var new_equipment_node = null
	if not equipment_index > inventory_size - 1:
		if inventory_array[equipment_index] == null:  # if nothing is equipped (should never be the case though)
			var equipment_scene : String = data_manager.weapon_dict[equipment_id][0]
			var new_equipment = load(equipment_scene).instantiate()
			new_equipment.player_controlled = player_controlled
			attachment_point.add_child(new_equipment)
			if name_already_exists:
				new_equipment.name = equip_name
			new_equipment_node = new_equipment
		else:
			var old_equip = attachment_point.get_child(equipment_index)
			old_equip.free()
			var equipment_scene : String = data_manager.weapon_dict[equipment_id][0]
			var new_equipment = load(equipment_scene).instantiate()
			print(str(attachment_point))
			attachment_point.add_child(new_equipment)
			new_equipment.get_child(0).player_controlled = player_controlled
			attachment_point.move_child(new_equipment, equipment_index)
			if name_already_exists:
				new_equipment.name = equip_name
			new_equipment_node = new_equipment
		inventory_array[equipment_index] = [data_manager.weapon_dict[equipment_id][1], can_equip, new_equipment_node]
		attachment_point.get_child(equipment_index).hide()
		attachment_point.get_child(equipment_index).process_mode = Node.PROCESS_MODE_DISABLED
		if is_auto_active and can_equip:
			swap_active_equipment(equipment_index, true)
		elif is_auto_active and not can_equip:
			print('[Equip Manager] Warning: new equipment should not be automatically activated and not equippable!')
		update_hud_weapons()
	else:
		print('[Equip Manager] Error: equipment index is out of range.')
	
func remove_equipment(equipment_index : int):
	if not equipment_index > inventory_size - 1:
		if inventory_array[equipment_index] == null:  # if nothing is equipped (should never be the case though)
			pass
		else:
			var old_child = attachment_point.get_child(equipment_index)
			old_child.free()
			var empty_child = Node3D.new()
			empty_child.name = "EMPTY SLOT " + str(equipment_index)
			attachment_point.add_child(empty_child)
			#print("Created empty inventory slot.")
			inventory_array[equipment_index] = [("Slot" + str(equipment_index)), false, null]
		update_hud_weapons()
	else:
		print('[Equip Manager] Error: equipment index is out of range.')

func clear_inventory():
	for index in range(0,inventory_size):
		remove_equipment(index)

func attack():  # used for enemy AI
	# triggers activate_primary() in the active equipments weapon_manager script
	attachment_point.get_child(active_equipment).get_child(0).ai_activate_primary()
	
func get_max_range() -> float:  # used for enemy AI
	return attachment_point.get_child(active_equipment).get_child(0).get_child(0).fire_range
	
func update_hud_ammo(ammo : int):
	if player_controlled:
		ui_manager.update_hud_ammo(active_equipment, ammo)
	
func update_hud_weapons():
	if player_controlled:
		print(active_equipment)
		ui_manager.update_hud_weapons(active_equipment, inventory_array)
#func rotate_active_equipment(new_basis, rot):
	#active_model.transform.basis = new_basis
	#active_model.rotate_x(rot)
