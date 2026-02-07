extends Node3D

var head
var player
@export var inventory_size : int = 2
var default_equipment : String = "0"  # for now, default equipment is the Default Weapon. Later, will probably be fists.
var inventory
var inventory_array : Array[Array] = []  # contains a sub-array for each equipped item: [String: Item Name, Bool: Can be Equipped?]
var active_equipment : int = -1  # index of child nodes
var data_manager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data_manager = get_node("/root/Game Manager/Sub Managers/Data Manager/")
	player = get_parent().get_parent().get_parent()
	head = get_parent().get_parent()
	for i in range(0,inventory_size):  # for now, create empty child nodes as temp item placeholders 
		var temp_child = Node3D.new()
		temp_child.name = "EMPTY SLOT " + str(i)
		add_child(temp_child)
		get_child(i).hide()
		get_child(i).process_mode = Node.PROCESS_MODE_DISABLED
		print("Created empty inventory slot")
		inventory_array.append([("EMPTY SLOT " + str(i)), false])
	print(str(inventory_array))
	
	call_deferred('late_ready')  # used to add the default equipment, but waits til after the data manager is ready.
	
func late_ready():
	# add the default equipment to slot 0
	add_equipment(0, default_equipment, true, true)  # add and equip the default weapon
	print(str(inventory_array))
	add_equipment(1, default_equipment, true, false)  # add and equip the default weapon
	print(str(inventory_array))
	print(str(active_equipment))
 
func _process(_delta: float) -> void:
	# handles swapping weapon inputs
	# currently handles up to 3 equips, probably will end up only having 2 tho
	# number press inputs
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

func swap_active_equipment(new_active_index : int):
	
	if not new_active_index == active_equipment:
		if not new_active_index > inventory_size - 1:
			if not inventory_array[new_active_index][1] == false:  # only works if you can swap to the new index
				var current_active = get_child(active_equipment)
				var new_active = get_child(new_active_index)
				current_active.hide()
				current_active.process_mode = Node.PROCESS_MODE_DISABLED
				new_active.show()
				new_active.process_mode = Node.PROCESS_MODE_ALWAYS
				active_equipment = new_active_index
				print('[Equip Manager] Active equipment: ' + str(new_active_index))
		else:
			print('[Equip Manager] Error: equipment index is out of range.')
	else:
		print('[Equip Manager] Warning: attempting to swap to already active equipment.')

func add_equipment(equipment_index : int, equipment_id : String, can_equip : bool = true, is_auto_active : bool = false):
	# rename the new node if a child with the same name already exists
	var equip_name : String = data_manager.weapon_dict[equipment_id][1]
	var name_already_exists : bool = false
	if has_node(equip_name):
		print('[Equip Manager]: Child with this name already exists. Renaming new node.')
		name_already_exists = true
		equip_name = equip_name + ' ' + str(equipment_index)
		
	if not equipment_index > inventory_size - 1:
		if inventory_array[equipment_index] == null:  # if nothing is equipped (should never be the case though)
			var equipment_scene : String = data_manager.weapon_dict[equipment_id][0]
			var new_equipment = load(equipment_scene).instantiate()
			add_child(new_equipment)
			if name_already_exists:
				new_equipment.name = equip_name
		else:
			var old_equip = get_child(equipment_index)
			old_equip.free()
			var equipment_scene : String = data_manager.weapon_dict[equipment_id][0]
			var new_equipment = load(equipment_scene).instantiate()
			add_child(new_equipment)
			move_child(new_equipment, equipment_index)
			if name_already_exists:
				new_equipment.name = equip_name
		inventory_array[equipment_index] = [data_manager.weapon_dict[equipment_id][1], can_equip]
		get_child(equipment_index).hide()
		get_child(equipment_index).process_mode = Node.PROCESS_MODE_DISABLED
		if is_auto_active and can_equip:
			swap_active_equipment(equipment_index)
		elif is_auto_active and not can_equip:
			print('[Equip Manager] Warning: new equipment should not be automatically activated and not equippable!')
	else:
		print('[Equip Manager] Error: equipment index is out of range.')
	# TODO: align the weapon with the camera (might be done in the weapon behaviour script though
	
func remove_equipment(equipment_index : int):
	if not equipment_index > inventory_size - 1:
		if inventory_array[equipment_index] == null:  # if nothing is equipped (should never be the case though)
			pass
		else:
			var old_child = get_child(equipment_index)
			old_child.free()
			var empty_child = Node3D.new()
			empty_child.name = "EMPTY SLOT " + str(equipment_index)
			add_child(empty_child)
			print("Created empty inventory slot.")
			inventory_array[equipment_index] = [("Slot" + str(equipment_index)), false]
	else:
		print('[Equip Manager] Error: equipment index is out of range.')
