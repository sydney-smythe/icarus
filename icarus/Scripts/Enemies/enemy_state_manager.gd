extends Node3D

@export var max_health : int = 3
@export var is_booster : bool = false
@export var boost_strength : float = 1.0
var current_health : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health

func change_current_health(health_alteration : int):
	# negative health alteration = healing, positive health alteration = damage
	current_health -= health_alteration
	
	#if health_alteration > 0 and is_booster:
		#%Player.apply_force(boost_strength)
	
	if current_health > max_health:
		current_health = max_health
		
	if current_health <= 0:
		current_health = 0
		kill_enemy()
	
	print('applied damage to enemy: ' + str(health_alteration) + ' | current health: ' + str(current_health))

func kill_enemy():
	print('enemy killed. freeing...')
	get_parent().queue_free()
