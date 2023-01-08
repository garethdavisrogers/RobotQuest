extends Node
onready var sprite = $Detector/Sprite
onready var anim = $Detector/anim
var damage = 1
var blastdir = 1
onready var detector = $Detector
var exploding = false

func _ready():
	add_to_group('attacks')
	add_to_group('players')
	sprite.scale.x = sprite.scale.y * 1

func _physics_process(delta):
	if(not exploding):
		self.position.x += 8 * blastdir
	
func anim_switch(new_anim):
	if(anim.current_animation != new_anim):
		anim.play(new_anim)

func _on_anim_animation_finished(anim_name):
	if(anim_name == 'explode'):
		self.queue_free()
	
func _on_Detector_area_entered(area):
	exploding = true
	anim_switch('explode')
