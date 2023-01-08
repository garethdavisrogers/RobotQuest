extends "res://Fighter.gd"

onready var health_bar = $HUD/VBox/HealthBar

func _ready():
	var camera = $Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = x_limit
	camera.limit_bottom = y_limit
	health_bar.value = health
	
func _physics_process(delta):
	update_ui()
	increment_timers(delta)
	init_movement()
	can_attack_ground = false
	if(state == 'idle' or state == 'attack'):
		can_attack_ground = true
	clamp_movement()
	if(health > 0):
		if(timers['stun_timer']<0):
			knockdir = null
		movement_loop()
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
			'clinched':
				state_clinched()
			'grapple':
				state_grapple()
			'flying_strike':
				flying_strike()
				
		spritedir_loop()
		if(state != 'clinched' and state != 'stagger'):
			controls_loop()
	else:
		anim_switch('die')
		
func controls_loop():
	var left = Input.is_action_pressed('ui_left')
	var right = Input.is_action_pressed('ui_right')
	var up = Input.is_action_pressed('ui_up')
	var down = Input.is_action_pressed('ui_down')
	
	movedir.x = -int(left) + int(right)
	movedir.y = -int(up) + int(down)
	
	if(timers['cool_down'] < 0 and state != 'stagger' and state != 'crash'):
		##actions that can be taken when not stunned
		if(Input.is_action_just_pressed('grab')):
			state_machine('grapple')
		elif(Input.is_action_just_pressed('lite_attack')):
			if(can_attack_ground):
				anim_switch(str('lite_attack', current_attack_index))
				attack_input_pressed()
			else:
				state_machine('flying_strike')
			
		elif(Input.is_action_just_pressed("heavy_attack")):
			if(can_attack_ground):
				if(current_attack_index > 3):
					anim_switch(str('heavy_attack', 3))
				else:
					anim_switch(str('heavy_attack', current_attack_index))
				attack_input_pressed()
			
		elif(Input.is_action_just_pressed("blast")):
			if(can_attack_ground):
				anim_switch('blast')
				blast()
				attack_input_pressed()
		elif(Input.is_action_pressed('defend')):
			if(can_attack_ground):
				anim_switch('block')
				state_machine('defend')
			
		elif(Input.is_action_just_released('defend')):
				state_machine('idle')
			
		elif(Input.is_action_just_pressed('jump')):
			if(can_attack_ground):
				timers['jump_timer'] = 0.6
				anim_switch('jump')
				state_machine('jump')
			elif(state == 'fly'):
				state_machine('land')
			elif(timers['jump_timer'] < 0.4):
				state_machine('takeoff')
				
func update_ui():
	health_bar.value = health
				
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
	if(area.is_in_group('quarter')):
		health = min(health + 25, max_health)

func _on_GrappleCol_area_entered(area):
	state_machine('grapple')
	area.get_parent().global_position = clinch_point.get_global_position()
