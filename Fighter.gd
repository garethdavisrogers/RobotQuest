extends KinematicBody2D

##load nodes
onready var sprite = $Sprite
onready var overlay = $Overlay
onready var blast_spawn = $Sprite/blast_spawn
onready var hitcol = $Sprite/HitCol
onready var hitbox = $Sprite/HitBox
onready var in_range_col = $Sprite/InRangeCol
onready var anim = $anim
onready var clinch_point = $Sprite/ClinchPoint
onready var shadow = $Shadow
onready var hit1 = $Hit1
onready var hit2 = $Hit2

##clamp
var x_limit = 0
var y_limit = 0
##respective fighter attributes
export(int) var max_speed = 200
export(int) var max_health = 10
export(int) var max_combo_index = 1
export(float) var acceleration_constant = 0.1

##universal fighter attributes
var type = 'enemies'
var health = 10
var default_shadow_diff = 45
const time_till_next_input = 0.5
const jump_constant = 10
var state = 'idle'
var speed = 0
var max_jump = 300
var movedir = Vector2(0, 0)
var knockdir = null
var lastdirection = movedir
var is_in_combo = false
var current_attack_index = 1
var can_attack_ground = false
##timers
var timers = {
	'cool_down': -1, 
	'jump_timer': -1, 
	'stun_timer': -1, 
	'combo_timer': -1,
	'charge_timer': -1,
	'wind_up': -1,
	'grapple_timer': -1
	}
##METHODS
func _ready():
	##distance between sprite and shadow for jumping etc
	x_limit = get_owner().get_node('Sprite').texture.get_width()
	y_limit = get_owner().get_node('Sprite').texture.get_height()
	default_shadow_diff = get_shadow_diff()
	health = max_health
	
##controls displacement
func movement_loop():
	var motion
	var knockback = 400
	if(knockdir != null):
		motion = knockdir.normalized() * knockback
	elif(movedir == Vector2(0, 0) and (speed > 0)):
		motion = lastdirection * speed
	else:
		motion = movedir.normalized() * speed
		lastdirection = movedir
# warning-ignore:return_value_discarded
	move_and_slide(motion, Vector2(0,0))

##matches the sprite fliph
func spritedir_loop():
	if(knockdir != null):
		if(knockdir.x < 0):
			sprite.scale.x = sprite.scale.y * 1
		elif(knockdir.x > 0):
			sprite.scale.x = sprite.scale.y * -1
	else:
		if(movedir.x > 0):
			sprite.scale.x = sprite.scale.y * 1
			overlay.scale.x = sprite.scale.y * 1
		elif(movedir.x < 0):
			sprite.scale.x = sprite.scale.y * -1
			overlay.scale.x = sprite.scale.y * -1

func state_idle():
	if(movedir != Vector2(0,0)):
		speed = accelerate(speed)
		if(speed >= 300):
			anim_switch('run')
		else:
			anim_switch('walk')
	else:
		speed = decelerate(speed)
		anim_switch('idle')
		
##the overall attack state, returns to idle on timeout
func state_attack():
	speed = decelerate(speed)
	if(timers['combo_timer'] < 0):
		current_attack_index = 1
		if(is_in_group('players')):
			state_machine('idle')
		else:
			state_machine('seek')

func state_defend():
	speed = decelerate(speed)
	anim_switch('block')
	
func blast():
	speed = decelerate(speed)
	if(is_in_group('players')):
		type = '_player'
	else:
		type = '_enemy'
	var load_string = str('res://blast',type,'.tscn')
	var blast = load(load_string).instance()
	blast.blastdir = lastdirection.x
	var level = get_owner()
	level.add_child(blast)
	var spawn_pos = blast_spawn.get_global_position()
	blast.set_position(spawn_pos)
		
func state_jump(d):
	if(timers['jump_timer'] > 0):
		sprite.position.y -= jump_constant
		timers['jump_timer'] -= d
	else:
		state_machine('land')

func state_land():
	anim_switch('land')
	if(get_shadow_diff() > default_shadow_diff):
		sprite.position.y += 8
	else:
		state_machine('idle')
		
func flying_strike():
	anim_switch('flying_strike')
	if(get_shadow_diff() > default_shadow_diff):
		sprite.position.y += 8
		global_position.x += 12 * lastdirection.x
	else:
		state_machine('idle')

func state_takeoff():
	speed = decelerate(speed)
	anim_switch('takeoff')
	
func state_fly():
	if(movedir == Vector2(0, 0)):
		speed = decelerate(speed)
	else:
		speed = accelerate(speed)

func state_stagger():
	anim_switch('stagger')
	if(timers['stun_timer'] < 0):
		knockdir = null
		state_machine('idle')

func state_crash():
	anim_switch('crash')
	if(get_shadow_diff() > default_shadow_diff):
		sprite.position.y += 12
	else:
		state_machine('recover')

func state_recover():
	anim_switch('recover')
	
func state_grapple():
	knockdir = null
	speed = 0
	if(timers['cool_down'] < 0):
		if(is_in_group('enemies')):
			anim_switch('pummel')
	else:
		anim_switch('grab')
	
func state_clinched():
	if(timers['stun_timer'] > 0):
		knockdir = null
		speed = 0
		anim_switch('clinched')
	else:
		state_machine('idle')

func state_charge():
	if(timers['charge_timer'] > 0):
		anim_switch('charge')
		global_position.x += 12 * lastdirection.x
	else:
		timers['cool_down'] = 2
		state_machine('seek')
	
func state_windup():
	if(timers['wind_up'] > 0):
		speed = decelerate(speed)
		anim_switch('wind_up')
	else:
		timers['charge_timer'] = 1
		state_machine('charge')

func state_die():
	anim_switch('die')
	
func damage_loop():
	health -= 1

func attack_input_pressed():
	current_attack_index += 1
	state_machine('attack')
	reset_combo_timer()

func reset_combo_timer():
	timers['combo_timer'] = 0.5
	if(current_attack_index <= max_combo_index and anim.current_animation != 'heavy_attack3'):
		timers['cool_down'] = 0.3
	else:
		current_attack_index = 1
		timers['cool_down'] = 0.8
	
##HELPER FUNCTIONS

##main state changing function
func state_machine(s):
	if(state != s):
		state = s
		
##plays new animations or continues existing ones
func anim_switch(new_anim):
	if(anim.current_animation != new_anim):
		anim.play(new_anim)

##increment timers
func increment_timers(d):
	for timer in timers:
		if(timers[timer] > -1):
			timers[timer] -= d
	
##change speed functions
func accelerate(s):
	if(state == 'fly'):
		return lerp(s, max_speed, 0.3)
	elif(s < max_speed):
		return lerp(s, max_speed, acceleration_constant)
	return max_speed

func decelerate(s):
	if(state == 'fly'):
		return lerp(s, 0, 0.1)
	elif(s > 0):
		return lerp(s, 0, 0.2)
	return 0
	
func get_knockdir(c):
	var pos = self.get_global_position()
	return c.global_position.direction_to(pos)

func clamp_movement():
	position.x = clamp(position.x, 10, x_limit - 10)
	position.y = clamp(position.y, 10, y_limit - 10)

func get_shadow_diff():
	return abs(sprite.position.y - shadow.position.y)

func init_movement():
	if(speed == 0):
			speed += 1
