extends Node
onready var sprite = $Detector/Sprite
onready var anim = $Detector/anim
onready var blast_timer = 5
var groups = []
var blastdir = 1
var damage = 1
var exploding = false

func _ready():
	add_to_group('attacks')
	sprite.scale.x = sprite.scale.y * 1

func anim_switch(new_anim):
	if(anim.current_animation != new_anim):
		anim.play(new_anim)

func _on_anim_animation_finished(anim_name):
	if(anim_name == 'explode'):
		blast_timer = -1
		queue_free()
	
