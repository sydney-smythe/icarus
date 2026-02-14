extends Area3D

@export var blast_strength_player : float = 4.0
@export var blast_strength_enemy : float = 18.0
@export var blast_vertical_modifier : Vector3 = Vector3(0, 1, 0)
@export var strength_distance_curve : Curve
var max_distance : float = 4.0 # MUST BE CHANGED IF BLAST COLLIDER SIZE CHANGES
@onready var player: CharacterBody3D = $"../../.."
@onready var camera: Camera3D = $".."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('essence_blast'):
		if player.essence > 10:
			player.essence -= 10
			player.apply_force(blast_strength_player, camera.global_transform.basis.z.normalized())
			var bodies = get_overlapping_bodies()
			for body in bodies:
				if body != player and body.is_in_group('Is Forceable'):
					
					var distance : float = player.global_transform.origin.distance_to(body.global_transform.origin)
					var strength_mult : float = strength_distance_curve.sample(distance/4.0)
					print(str(body.name) + ' at distance: ' + str(distance) + ' with strength mult: ' + str(strength_mult))
					body.apply_force(blast_strength_enemy * strength_mult, ((body.global_position - camera.global_position).normalized() + blast_vertical_modifier))
			#apply_force(strength : float, direction : Vector3, sustained : bool = false, duration : float = 0.0):
