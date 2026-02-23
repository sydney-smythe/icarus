extends Node3D

@onready var player: CharacterBody3D = $".."
@export var walk_sfx: AudioStreamPlayer3D 
@export var essence_blast_sfx : AudioStreamPlayer3D
@export var sliding_sfx : AudioStreamPlayer3D
@export var jump_sfx : AudioStreamPlayer3D
@export var land_sfx : AudioStreamPlayer3D
@export var wall_run_sfx : AudioStreamPlayer3D
@export var wind_sfx : AudioStreamPlayer3D
var fading_out_slide = false
var sliding_vol : float
var fading_out_wall_run = false
var wall_run_vol : float

@export var landing_volume_curve: Curve
@export var wind_velocity_threshold = 15
@export var wind_velocity_curve : Curve

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sliding_vol = sliding_sfx.volume_db
	wall_run_vol = wall_run_sfx.volume_db

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	play_movement_audio()
	
	
func play_movement_audio():
	#print(str(sliding_sfx.volume_db))
	# play sliding audio
	if not player.freeflying and player.player_enabled:
		if player.is_sliding:
			if not player.is_on_floor():
				fade_out_audio(sliding_sfx, 0.2, sliding_vol)
			elif not sliding_sfx.is_playing() and player.is_on_floor():
				fade_in_audio(sliding_sfx, 0.1, sliding_vol)
		elif not player.is_sliding and sliding_sfx.is_playing() and not fading_out_slide:
			fade_out_audio(sliding_sfx, 0.2, sliding_vol)
			
		# play wall running audio
		if player.is_wall_running:
			if not wall_run_sfx.is_playing():
				fade_in_audio(wall_run_sfx, 0.03, wall_run_vol)
		elif not player.is_wall_running and wall_run_sfx.is_playing() and not fading_out_wall_run:
			fade_out_audio(wall_run_sfx, 0.2, wall_run_vol)
			
		# play walking / crouching / spriting audio
		if not player.is_sliding and player.is_moving and player.is_on_floor() and player.player_enabled:
			if player.is_sprinting:
				walk_sfx.pitch_scale = 1.5
			elif player.is_crouching:
				walk_sfx.pitch_scale = 0.7
			elif player.is_moving:
				walk_sfx.pitch_scale = 1.0
			if not walk_sfx.is_playing():
				walk_sfx.play()
		else:
			if walk_sfx.is_playing():
				walk_sfx.stop()
				
		#play wind audio
		var total_vel = abs(player.velocity.x) + abs(player.velocity.y) + abs(player.velocity.z)
		if total_vel > wind_velocity_threshold:
			if not player.is_on_floor() and not wind_sfx.is_playing():
				play_wind_sfx(total_vel)
			if wind_sfx.is_playing():
				update_wind_vol(total_vel)
		if not total_vel > wind_velocity_threshold or player.is_on_floor():
			fade_out_audio(wind_sfx, 0.2)
	
	# disable movement sounds if player is freeflying
	if player.freeflying or not player.player_enabled:
		if walk_sfx.is_playing():
			walk_sfx.stop()
		if sliding_sfx.is_playing():
			sliding_sfx.stop()
		if wall_run_sfx.is_playing():
			wall_run_sfx.stop()
		if wind_sfx.is_playing():
			wind_sfx.stop()
func play_essence_blast():
	essence_blast_sfx.play()

func play_jump_sfx():
	jump_sfx.play()

func play_wind_sfx(total_velocity : float):
	if total_velocity > 40:
		total_velocity = 40
	print('vol: ' + str(wind_velocity_curve.sample(total_velocity)))
	wind_sfx.volume_db = wind_velocity_curve.sample(total_velocity)
	fade_in_audio(wind_sfx, 0.8, wind_sfx.volume_db)
	#wind_sfx.play()
	
func update_wind_vol(total_velocity : float):
	if total_velocity > 40:
		total_velocity = 40
	#print('vol: ' + str(wind_velocity_curve.sample(total_velocity)))
	wind_sfx.volume_db = wind_velocity_curve.sample(total_velocity)

func play_land_sfx(y_velocity : float):
	#print('y velo:' + str(y_velocity))
	var adj_y_velocity = y_velocity/-22  # adjusts it so that we get a value between 0 and 1
	#print('adj y velo:' + str(adj_y_velocity))
	if adj_y_velocity > 1:
		adj_y_velocity = 1
	elif adj_y_velocity < 0:
		adj_y_velocity = 0
	#print('vol: ' + str(landing_volume_curve.sample(adj_y_velocity)))
	land_sfx.volume_db = landing_volume_curve.sample(adj_y_velocity)
	land_sfx.play()

func fade_out_audio(audio_source : AudioStreamPlayer3D, fade_time : float = 0.2, default_vol : float = 0):
	var original_vol = default_vol
	if default_vol == 0:
		original_vol = audio_source.volume_db
		
	fading_out_slide = true
	var tween = get_tree().create_tween()
	tween.tween_property(audio_source, "volume_db", -80, fade_time)
	await tween.finished
	audio_source.stop()
	audio_source.volume_db = original_vol
	fading_out_slide = false
	
func fade_in_audio(audio_source : AudioStreamPlayer3D, fade_time : float = 0.2, default_vol : float = 0):
	var original_vol = default_vol
	if default_vol == 0:
		original_vol = audio_source.volume_db
		
	var tween = get_tree().create_tween()
	audio_source.volume_db = -80
	audio_source.play()
	tween.tween_property(audio_source, "volume_db", original_vol, fade_time)
	await tween.finished
