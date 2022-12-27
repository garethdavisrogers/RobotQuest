extends "res://Fighter.gd"

var in_melee_attack_range = false
var target_position = null
var player_detected = false
onready var detector = $Detector
onready var in_range_collider = $Sprite/InRangeCollider
##player_detected is based on enter/exit $Detector signals
func _ready():
	##handicaps will slow down the enemy reactions to taste
	handicap['lite'] = 0.5
	handicap['heavy'] = 0.8
	handicap['combo_time'] = 0.5
	
func _physics_process(delta):
	clamp_movement()
	if(health > 0):
	##timers always tick if greater than 0
		increment_timers(delta)
		##enemy can only function if not staggered
		if(timers['stun_timer'] < 0):
			knockdir = null
			if(player_detected and in_melee_attack_range):
				if(timers['cool_down'] < 0):
					anim_switch(str('lite_attack', current_attack_index))
					attack_input_pressed()
			elif(player_detected):
				state_machine('seek')
			else:
				state_machine('idle')
				in_melee_attack_range = false
				player_detected = false
				
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
		movement_loop()
		spritedir_loop()
	else:
		anim_switch('die')
	
func state_seek():
	current_attack_index = 1
	var t = get_player_position()
	##if no player is in detect radius, change to idle state
	if(t != null):
		close_distance(t)
	else:
		player_detected = false
	
func get_player_position():
	var players = get_tree().get_nodes_in_group('players')
	if(not players):
		return null
	var player_position = players[0].global_position
	return player_position

func close_distance(player_pos):
	movedir = get_position().direction_to(player_pos)
	if(speed == 0):
			speed += 1
	else:
		speed = accelerate(speed)
	spritedir_loop()
	anim_switch('walk')
	
func _on_Detector_body_entered(body):
	if(body.is_in_group('players')):
		player_detected = true


func _on_Detector_body_exited(_body):
	var bodies = detector.get_overlapping_bodies()
	for b in bodies:
		if(b.is_in_group('players')):
			return
	player_detected = false


func _on_InRangeCollider_body_entered(body):
	if(body.is_in_group('players')):
		in_melee_attack_range = true


func _on_InRangeCollider_body_exited(body):
	var bodies = in_range_collider.get_overlapping_bodies()
	for b in bodies:
		if(b != body and b.is_in_group('players')):
			return
	in_melee_attack_range = false


func _on_anim_animation_finished(anim_name):
	if(anim_name=='die'):
		queue_free()
