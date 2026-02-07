extends Label

@onready var player: CharacterBody3D = $"../Player"

func _process(_delta: float) -> void:
	var text_item : String = 'Vel. Vec: ' + str(player.velocity)
	self.text = text_item
