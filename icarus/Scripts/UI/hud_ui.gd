extends Control

@onready var essence: Label = $'Essence Info/PanelContainer/MarginContainer/Essence'
@onready var weapon_name: Label = $"Weapon Info/PanelContainer/MarginContainer/VBoxContainer/Weapon Name"
@onready var ammo: Label = $"Weapon Info/PanelContainer/MarginContainer/VBoxContainer/Ammo"
@onready var player = %Player
@onready var equipment_manager = player.get_node('Head').get_node('Camera3D').get_node('Equipment Manager')
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#print(str(equipment_manager))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	essence.text = 'ESSENCE: ' + str(player.essence)
	weapon_name.text = str(equipment_manager.inventory_array[equipment_manager.active_equipment][0])
	ammo.text = str(equipment_manager.get_child(equipment_manager.active_equipment).get_child(0).prim_current_ammo)
