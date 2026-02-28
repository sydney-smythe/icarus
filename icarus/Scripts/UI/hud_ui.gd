extends Control

@export var essence: Label
@export var weapon_name: Label
@export var ammo: Label
@export var boon_names: Label
@export var boon_times: Label
@export var essence_blast_counter : Label
@onready var player = null
var equipment_manager
var boon_manager
var blast_timer : float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerManager.get_player()
	equipment_manager = player.get_node('Head').get_node('Camera3D').get_node('Equipment Manager')
	boon_manager = player.get_node('Boon Manager')


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
		if equipment_manager.active_equipment != -1:
			weapon_name.text = str(equipment_manager.inventory_array[equipment_manager.active_equipment][0])
			ammo.text = str(equipment_manager.get_child(equipment_manager.active_equipment).get_child(0).prim_current_ammo)
		else:
			weapon_name.text = 'UNARMED'
			ammo.text = '-'
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
	
