extends Node3D

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")
var player : CharacterBody3D
var player_state
var state_list
var is_firing : bool = false
var is_reloading : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	anim_tree.active = true
	call_deferred('late_ready')

func late_ready():
	player = PlayerManager.get_player()
	state_list = player.PLAYER_STATES

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# enum PLAYER_STATES {idle, walk, run, crouch, crouch_walk, slide, wall_run, in_air}
	if is_reloading or is_firing:
		return
	
	player_state = player.player_state
	if player_state == state_list.idle or player_state == state_list.crouch or player_state == state_list.in_air:
		state_machine.travel("Idle")
	# for now, all movement will use walk anim
	elif player_state == state_list.walk or player_state == state_list.crouch_walk:  
		state_machine.travel("Walk")
	elif player_state == state_list.run:  
		state_machine.travel("Walk")
	elif player_state == state_list.slide:  
		state_machine.travel("Walk")
	elif player_state == state_list.wall_run:  
		state_machine.travel("Walk")
		
func play_reload():
	#print('a')
	if not is_reloading:
		is_reloading = true
		state_machine.travel("Reload")
	
func play_fire():
	#print('b')
	if not is_firing:
		is_firing = true
		state_machine.travel("Fire")


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Reload":
		#print('done load')
		is_reloading = false
	elif anim_name == "Fire":
		#print('done fire')
		is_firing = false
