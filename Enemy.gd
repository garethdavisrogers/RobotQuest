extends "res://Fighter.gd"

onready var detector = $Detector
onready var in_range_collider = $Sprite/InRangeCol

var target_position = null
var target_direction = null
var target_distance = null
var target_details = {
	'target_position':null,
	'target_direction':null,
	'target_distance':null
	}
var in_melee_attack_range = false
var player_detected = false

##player_detected is based on enter/exit $Detector signals
	
func _physics_process(delta):
	increment_timers(delta)
	##timers always tick if greater than 0
	clamp_movement()
	##idle until player detected
	if(health > 0):
		init_movement()
		movement_loop()
		spritedir_loop()
		if(player_detected):
			get_player_info()
			##enemy can only function if not staggered
			##seek target
			if(timers['stun_timer'] < 0):
				knockdir = null
				if(timers['cool_down'] < 0):
					if(in_melee_attack_range):
						anim_switch(str('lite_attack', current_attack_index))
						attack_input_pressed()
					else:
						current_attack_index = 1
						state_machine('seek')
		else:
			current_attack_index = 1
			movedir = Vector2(0,0)
			state_machine('idle')
	else:
		anim_switch('idle')
		
	match state:
			'attack':
				state_attack()
			'seek':
				state_seek()
			'idle':
				state_idle()
			'stagger':
				state_stagger()
			'defend':
				state_defend()
			'grapple':
				state_grapple()
			'charge':
				state_charge()
			'clinched':
				state_clinched()
			'wind_up':
				state_windup()
			'die':
				state_die()
	
func state_seek():
	##if no player is in detect radius, change to idle state
	current_attack_index = 1
	speed = accelerate(speed)
	anim_switch('walk')
	movedir = target_direction

func get_player_info():
	var entities = detector.get_overlapping_bodies()
	for entity in entities:
		if(entity.is_in_group('players') and entity.is_in_group('entities')):
			var sprite_pos = entity.get_node('Sprite')
			target_position = sprite_pos.global_position
			target_details['target_position'] = sprite_pos.global_position
			target_direction = global_position.direction_to(target_position)
			target_details['target_direction'] = global_position.direction_to(target_position)
			target_distance = global_position.distance_to(target_position)
			target_details['target_distance'] = global_position.distance_to(target_position)
	
func _on_Detector_body_entered(body):
	if(body.is_in_group('players')):
		player_detected = true

func _on_Detector_body_exited(_body):
	var bodies = detector.get_overlapping_bodies()
	for b in bodies:
		if(b.is_in_group('players')):
			player_detected = true
	player_detected = false

func _on_GrappleCollider_area_entered(area):
	if(area.is_in_group('players')):
		state_machine('grapple')

func _on_InRangeCol_body_entered(body):
	if(body.is_in_group('players')):
		in_melee_attack_range = true

func _on_InRangeCol_body_exited(_body):
	var bodies = in_range_col.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group('player')):
			in_melee_attack_range = true
	in_melee_attack_range = false

func _on_anim_animation_finished(anim_name):
	if(anim_name=='die'):
		queue_free()
