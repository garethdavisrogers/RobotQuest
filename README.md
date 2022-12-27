# 2DFighterClass
A 2D fighter class for the godot engine
2D Fighter

##Class Fighter

Every fighter has:
	-KinematicBody2D
	-Sprite
		-blast_spawn
		-HitCol
			-HitCollider
		-HitBox
			-CollisionShape2D
		-HitBox
	-BodyCollider
	
##Node descriptions
	
	KinematicBody2D - the root node of the 2DFighter class
	
	Sprite - The frames and parent of blast_spawn,
	HitCol, and HitBox.  The reason for this is the fliph from the sprite
	must apply to the collision shapes as well.
	
	BodyCollider - The most basic collision shape, its purpose is to 
	detect if the player is touching something in the level.  It is not
	for doing or taking damage. Child of root because KinematicBody2D
	requires a collisionshape
	
	InRangeCollider - A collider to determine when an opponent is in range of
	a melee attack right now.  On a target entering, the target is determined
	to be in range
	
	HitBox - The area2D with collision shape meant to interpret damage
	to the parent node.  Inactive in stagger, death, block
	
	HitCol - The area2D with collision shape meant to transmit damage to
	a hitbox of another type.
	
##Vars

acceleration_coefficient - speed is the minimum of max and speed * acceleration_coefficient
~DEPRECATED

max_speed - a cap for the speed a fighter can move.  It is used in a min function with whatever
the current speed is

health - metric for how close to death the player is

movedir - the x and y direction to be multiplied by speed to determine movement

state - the current condition of the player each with its distinct set of rules

speed - the current coefficient of the movedir

type - the fighter's damage/damaging group.  Determines who can damage who.

cool_down - A timer set at -1 that is set to the respective cooldown after an attack.
The time will be a positive integer that is subtracted by delta each frame

jump_timer - determines the latency between jump and land or jump and fly

stun_timer - the time an enemy is stunned and cannot attack or take damage.  Always slightly
shorter than the invincibility period

combo_timer - the time the player has to make input to continue the combo

##Timer principles

All timers are constantly ticking down if they are more than -1

On attacking the combo_timer should be set to the amount of time the player
has to enter another input
The combo_timer should always be larger than the cool down if you want the combo
to continue and smaller than the cool down if you want the combo to end

##Jumping
When jumping in a straight line, the player should rise and fall the same distance

##Collision Layers
1-Body Colliders
Body Colliders interact with other physics bodies
2-Hit Boxes
Hit boxes interact with hit colliders
3-Hit Colliders
Hit Colliders interact with hit boxes
4-InRange Colliders
InRange Colliders interact with hitboxes and hitcolliders
5-Interact Colliders
Interact Colliders interact with interactables
6-Item Colliders
Interact with items
7-Detector Colliders
Interact with physics bodies
8-Projectiles
Interact with hitboxes
