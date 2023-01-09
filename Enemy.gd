extends "res://Fighter.gd"

onready var detector = $Detector
onready var charge_range_col = $Sprite/ChargeRangeCol
onready var in_range_col = $Sprite/InRangeCol

var target_position = null
var target_direction = null
var target_distance = null
var target_details = {
	'target_position':null,
	'target_direction':null,
	'target_distance':null,
	'target_is_flying':false
	}
var in_melee_attack_range = false
var player_detected = false

##player_detected is based on enter/exit $Detector signals
func _ready():
	handicap = 0.3
	
func _physics_process(delta):
	increment_timers(delta)
	##timers always tick if greater than 0
	clamp_movement()
	##idle until player detected
	if(health > 0):
		if(not state_is_grapple()):
			init_movement()
			movement_loop()
			spritedir_loop()
		if(state != 'grapple' and state != 'clinched'):
			if(player_detected):
				get_player_info()
				movedir = target_details['target_direction']
				##enemy can only function if not staggered
				##seek target
				if(timers['stun_timer'] < 0):
					knockdir = null
					if(timers['cool_down'] < 0 and state != 'wind_up' and state != 'charge' and state != 'air_attack'):
						if(in_melee_attack_range):
							anim_switch(str('lite_attack', current_attack_index))
							attack_input_pressed()
						elif(target_details['target_is_flying']):
							timers['wind_up'] = 1
							state_machine('wind_up')
						else:
							current_attack_index = 1
							state_machine('seek')
		
			else:
				current_attack_index = 1
				in_melee_attack_range = false
				movedir = Vector2(0,0)
				state_machine('idle')
	else:
		state_machine('die')
		
	match state:
			'attack':
				state_attack()
			'air_attack':
				state_air_attack()
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
				state_windup(target_details['target_is_flying'])
			'die':
				state_die()
	
func state_seek():
	##if no player is in detect radius, change to idle state
	current_attack_index = 1
	speed = accelerate(speed)
	anim_switch('walk')

func get_player_info():
	var entities = detector.get_overlapping_bodies()
	for entity in entities:
		if(entity.is_in_group('players') and entity.is_in_group('entities')):
			var sprite_pos = entity.get_node('Sprite')
			target_details['target_position'] = sprite_pos.global_position
			target_details['target_direction'] = global_position.direction_to(target_details['target_position'])
			target_details['target_distance'] = global_position.distance_to(target_details['target_position'])
			if(entity.is_in_group('flying')):
				target_details['target_is_flying'] = true
			else:
				target_details['target_is_flying'] = false

func state_air_attack():
	if(target_details['target_is_flying']):
		speed = 1
		anim_switch('air_attack')
		if(timers['cool_down'] < 0):
			var fist = load('res://Fist.tscn').instance()
			var level = get_owner()
			level.add_child(fist)
			var spawn_pos = blast_spawn.get_global_position()
			fist.set_position(spawn_pos)
			timers['cool_down'] = 10
	else:
		state_machine('seek')
	
func _on_Detector_body_entered(body):
	if(body.is_in_group('players')):
		player_detected = true

func _on_Detector_body_exited(_body):
	var bodies = detector.get_overlapping_bodies()
	for b in bodies:
		if(b.is_in_group('players')):
			return
	player_detected = false

func _on_InRangeCol_body_entered(body):
	if(body.is_in_group('players')):
		in_melee_attack_range = true

func _on_InRangeCol_body_exited(_body):
	var bodies = in_range_col.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group('player')):
			return
	in_melee_attack_range = false

func _on_ChargeRangeCol_body_entered(body):
	if(body.is_in_group('players') and timers['cool_down'] < 0):
		var rng = get_random_number(1,2)
		if(rng % 2 == 0):
			timers['wind_up'] = 1
			state_machine('wind_up')
		
func _on_anim_animation_finished(anim_name):
	if(anim_name=='die'):
		queue_free()
	if(anim_name=='pummel'):
		state_machine('seek')
