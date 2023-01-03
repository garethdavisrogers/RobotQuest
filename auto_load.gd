extends Node

func _ready():
	var level_canvas = get_owner().get_node("Sprite").texture
	var x_limit = level_canvas.get_width()
	var y_limit = level_canvas.get_height()
