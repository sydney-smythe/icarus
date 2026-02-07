extends Label

@onready var player: CharacterBody3D = $"../Player"

func _process(_delta: float) -> void:
	var text_item : String = 'Move Speed: ' + str(player.move_speed)
	self.text = text_item
