extends Control

@onready var essence: Label = $"Essence Info/VBoxContainer/PanelContainer/MarginContainer/Essence"
@onready var weapon_name: Label = $"Weapon Info/PanelContainer/MarginContainer/VBoxContainer/Weapon Name"
@onready var ammo: Label = $"Weapon Info/PanelContainer/MarginContainer/VBoxContainer/Ammo"
@onready var boon_names: Label = $"Essence Info/VBoxContainer/Boon Info/PanelContainer/MarginContainer/HBoxContainer/Boon Names"
@onready var boon_times: Label = $"Essence Info/VBoxContainer/Boon Info/PanelContainer/MarginContainer/HBoxContainer/Boon Times"
@onready var player = null
var equipment_manager
var boon_manager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerManager.get_player()
	equipment_manager = player.get_node('Head').get_node('Camera3D').get_node('Equipment Manager')
	boon_manager = player.get_node('Boon Manager')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	for boon in boon_manager.active_boons:
		boon_names.text = boon_names.text + boon + '\n'
		boon_times.text = boon_times.text + str(int(boon_manager.active_boons[boon])) + 's\n'
	boon_names.text = boon_names.text.left(boon_names.text.length()-1)
	boon_times.text = boon_times.text.left(boon_times.text.length()-1)
