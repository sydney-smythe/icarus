extends Camera3D

@onready var player = get_parent().get_parent()

# enum PLAYER_STATES {idle, walk, run, crouch, crouch_walk, slide, wall_run, in_air}
var amount_freq_bob : Array = [  # array for the head bob amount and frequency for each player state
	[0.0, 0.0], # idle
	[0.7, 0.7], # walk
	[1.0, 1.0], # run
	[0.0, 0.0], # crouch
	[0.4, 0.5], # crouch walk
	[0.0, 0.0], # slide
	[0.2, 0.9], # wall run
	[0.0, 0.0], # in air
	]

var time : float = 0.0

var head_bob_amount : float = 0.0
var head_bob_frequency = 0.0
var bob_freq_mult = 18
var bob_amount_mult = 0.11
var default_height : float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_height = position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# update head bob amount based on player state
	head_bob_amount = amount_freq_bob[player.player_state][0]
	head_bob_frequency = amount_freq_bob[player.player_state][1]
	# this still scares me 
	time += delta
	# apply head bob
	if head_bob_amount != 0.0 and head_bob_frequency != 0.0:
		position.y = (sin(time * head_bob_frequency * bob_freq_mult) * head_bob_amount * bob_amount_mult)
	else:
		position.y = default_height
