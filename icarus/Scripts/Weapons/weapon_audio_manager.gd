extends Node3D

@export var primary_fire_audio: AudioStreamPlayer3D
@export var no_ammo_audio: AudioStreamPlayer3D
@export var reload_audio: AudioStreamPlayer3D
@export var equip_audio: AudioStreamPlayer3D
@export var enemy_hit_audio: AudioStreamPlayer3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_primary_audio():
	primary_fire_audio.play()

func play_no_ammo_audio():
	no_ammo_audio.play()
	
func play_reload_audio():
	reload_audio.play()

func play_equip_audio():
	equip_audio.play()

func play_enemy_hit_audio():
	enemy_hit_audio.play()
