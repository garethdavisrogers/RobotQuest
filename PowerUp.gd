extends Node2D

onready var audio = $Audio

func _ready():
	pass # Replace with function body.

func _on_Area2D_area_entered(area):	
	audio.play()
	$Sprite.hide()

func _on_Audio_finished():
	queue_free()
