extends "res://Enemy.gd"

func _ready():
	position.x = 500
	position.y = 200
func _physics_process(_delta):
	send_z_index()
	if health <= 0:
		anim_switch('fall')
	elif hitstun > 0:
		state_stagger()
	else:
		match state:
			'default':
				state_default()
			'closing':
				state_closing()
			'attack':
				state_attack()

func state_default():
	damage_loop()
	movedir = Vector2(0, 0)
	if player_x != null and player_y != null:
		state_machine('closing')
	else:
		anim_switch('idle')
	

func state_closing():
	get_player_location()
	damage_loop()
	movement_loop()
	spritedir_loop()
	anim_switch('walk')
	if player_x != null or player_y != null:
		get_movedir()
	else:
		state_machine('default')
	
func state_attack():
	damage_loop()
	get_player_location()
	spritedir_loop()
	movedir = Vector2(0, 0)
	if player_x > 0:
		movedir.x = -1
	else:
		movedir.x = 1
	var abs_x = abs(player_x)
	var abs_y = abs(player_y)
	if abs_x > 100 and abs_y > 20:
		state_machine('closing')
	else:
		if cooldown_timer.get_time_left() > 0:
			anim_switch('shuffle')
		else:
			anim_switch('liteattack1')

func state_stagger():
	anim_switch('stagger')
	
func _on_detectRadius_body_entered(body):
	if body.TYPE == 'PLAYER':
		state_machine('closing')

func _on_detectRadius_body_exited(body):
	if body.TYPE == 'PLAYER':
		player_x = null
		player_y = null
		state_machine('default')


func _on_anim_animation_finished(anim_name):
	if anim_name == 'liteattack1left' or anim_name == 'liteattack1right':
		cooldown_timer.start(3)
	if anim_name == 'shuffleleft' or anim_name == 'shuffleright':
		state_machine('closing')
	if anim_name == 'staggerleft' or anim_name == 'staggerright':
		hitstun = 0
		state_machine('closing')
	if anim_name == 'fallleft' or anim_name == 'fallright':
		queue_free()
