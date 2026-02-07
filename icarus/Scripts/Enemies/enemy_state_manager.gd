extends Node3D

@export var max_health : int = 10
var current_health : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health


func change_current_health(health_alteration : int):
	# negative health alteration = healing, positive health alteration = damage
	current_health -= health_alteration
	
	if current_health > max_health:
		current_health = max_health
		
	if current_health < 0:
		current_health = 0
		kill_enemy()
	
	print('applied damage to enemy: ' + str(health_alteration) + ' | current health: ' + str(current_health))

func kill_enemy():
	print('enemy killed. freeing...')
	queue_free()
