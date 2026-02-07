extends Label

@onready var player: CharacterBody3D = $"../Player"

func _process(_delta: float) -> void:
	var text_item : String = 'Active Actions:'
	for item in player.active_actions:
		text_item = text_item + "\n" + str(item)
	self.text = text_item
