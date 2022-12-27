extends Node

##main state changing function
func state_machine(new_state, current_state):
	if(current_state != new_state):
		current_state = new_state
		
##plays new animations or continues existing ones
func anim_switch(new_anim, anim_player):
	if(anim_player.current_animation != new_anim):
		anim_player.play(new_anim)

##increment timers
func increment_timers(timers, d):
	for timer in timers:
		if(timers[timer] > -1):
			timers[timer] -= d
	
##change speed functions
func accelerate(s, ms):
	if(s < ms):
		return lerp(s, ms, 0.1)
	return ms

func decelerate(s):
	if(s > 0):
		return lerp(s, 0, 0.2)
	return 0
