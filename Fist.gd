extends Node2D

onready var sprite = $Detector/Sprite
onready var anim = $Detector/anim
onready var detector = $Detector
var exploding = false
var nearest_player_location = null
var deployed = false
var target = null
var damage = 1

func _ready():
		anim_switch('deploy')
	
func _physics_process(_delta):
	if(deployed and not exploding):
		if(target != null):
			var target_vector = 5 * global_position.direction_to(target.global_position)
			var target_rot = global_position.angle_to(target.global_position)
			self.rotate(target_rot)
			self.global_position += target_vector
		else:
			exploding = true
			anim_switch('explode')
		
func anim_switch(new_anim):
	if(anim.current_animation != new_anim):
		anim.play(new_anim)


func _on_anim_animation_finished(anim_name):
	if(anim_name == 'deploy'):
		deployed = true
	if(anim_name == 'explode'):
		queue_free()


func _on_Detector_area_entered(area):
	if(area.is_in_group('hitboxes')):
		target = area


func _on_HitCol_area_entered(area):
	if(area.is_in_group('hitboxes')):
		exploding = true
		anim_switch('explode')
