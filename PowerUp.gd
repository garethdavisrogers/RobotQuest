extends Node2D

func _ready():
	pass # Replace with function body.

func _on_Area2D_area_entered(_area):	
	queue_free()
