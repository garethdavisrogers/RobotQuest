extends "res://blast.gd"

func _ready():
	groups = get_groups()
func _physics_process(delta):
	if(not exploding):
		if(blast_timer > 0):
			$Detector.position.x += blastdir * 5
			anim_switch('fire')
		else:
			queue_free()
	else:
		anim_switch('explode')
	blast_timer -= delta

func _on_Detector_area_entered(area):
	if(area.is_in_group('hitboxes')):
		for group in groups:
			if(area.is_in_group(group) and group != 'physics_process'):
				return
		exploding = true
