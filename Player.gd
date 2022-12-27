extends "res://Fighter.gd"

func _ready():
	lastdirection = movedir
	
func _physics_process(delta):
	clamp_movement()
	if(health > 0):
		movement_loop()
		increment_timers(delta)
		if(timers['stun_timer'] < 0):
			knockdir = null
			match state:
				'attack':
					state_attack()
				'jump':
					state_jump(delta)
				'land':
					state_land()
				'takeoff':
					state_takeoff()
				'fly':
					state_fly()
				'idle':
					state_idle()
				'stagger':
					state_stagger()
				'crash':
					state_crash()
				'recover':
					state_recover()
				'defend':
					state_defend()
					
			controls_loop()
			spritedir_loop()
	else:
		anim_switch('die')
		
func controls_loop():
	var left = Input.is_action_pressed('ui_left')
	var right = Input.is_action_pressed('ui_right')
	var up = Input.is_action_pressed('ui_up')
	var down = Input.is_action_pressed('ui_down')
	
	movedir.x = -int(left) + int(right)
	movedir.y = -int(up) + int(down)
	if(movedir != Vector2(0, 0)):
		lastdirection = movedir
	
	if(timers['cool_down'] < 0):
		##actions that can be taken when not stunned
		if(Input.is_action_just_pressed('lite_attack')):
			anim_switch(str('lite_attack', current_attack_index))
			attack_input_pressed()
			
		elif(Input.is_action_just_pressed("heavy_attack")):
			if(current_attack_index > 3):
				anim_switch(str('heavy_attack', 3))
			else:
				anim_switch(str('heavy_attack', current_attack_index))
			attack_input_pressed()
			
		elif(Input.is_action_just_pressed("blast")):
			if(state == 'idle' or state == 'attack'):
				anim_switch('blast')
				blast()
				attack_input_pressed()
		elif(Input.is_action_pressed('defend')):
			anim_switch('block')
			state_machine('defend')
			
		elif(Input.is_action_just_released('defend')):
			state_machine('idle')
			
		elif(Input.is_action_just_pressed('jump')):
			if(state == 'idle'):
				timers['jump_timer'] = 0.6
				anim_switch('jump')
				state_machine('jump')
			elif(state == 'fly'):
				timers['jump_timer'] = 0.6
				state_machine('land')
			elif(timers['jump_timer'] < 0.4):
				state_machine('takeoff')
				
func _on_anim_animation_finished(anim_name):
	if(anim_name == 'die'):
		queue_free()
	elif(anim_name == 'takeoff'):
		state_machine('fly')
	elif(anim_name == 'recover'):
		if(health < 0):
			anim_switch('die')
		state_machine('idle')
		timers['stun_timer'] = 0.5


func _on_PowerUpCol_area_entered(area):
	if(area.is_in_group('small_power_ups')):
		health = min(health + 25, max_health)
