extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -75.0
const GRAVITY_MULTIPLIER = 0.5
const FRICTION = 0.75

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum {CHASE,FLEE}

var target
var lastUpdate = 0
var lastInput = 0
const INPUT_LIMIT = 1000

func getInput():
	var enemyInput = {
		dirAxis = 0,
		jumped = false
	}
	return enemyInput
	
	if target:
		var directionOfTarget = get_global_position().direction_to(target.get_global_position())
		if directionOfTarget.x < -0.25: enemyInput.dirAxis = -1
		if directionOfTarget.x > 0.25: enemyInput.dirAxis = 1
		
		if Time.get_ticks_msec() - lastInput > 1000:
			if (directionOfTarget.y < 0):
				enemyInput.jumped = true
				lastInput = Time.get_ticks_msec()
		
	return enemyInput

func _physics_process(delta):
	
	if not is_on_floor(): velocity.y += gravity*GRAVITY_MULTIPLIER * delta
	
	if Time.get_ticks_msec() - lastUpdate > 1000: updateTarget()
	#print (Time.get_ticks_msec() - lastUpdate,"-", Time.get_ticks_msec(),"-",  lastUpdate)

	var enemyInput = getInput()
	
	if enemyInput.jumped:
		$Sprite.animation = 'flap'
		$Sprite.play()
		velocity.y = JUMP_VELOCITY

	var direction = enemyInput.dirAxis
	if direction:
		if is_on_floor():
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, FRICTION)
		$Sprite.flip_h = direction > 0
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, 1)
	
	if (is_on_floor()):
		if (velocity.x == 0): 
			$Sprite.animation = 'idle'
		else:
			$Sprite.animation = 'walk'
	else:
		#$Sprite.flip_h = velocity.x>0
		if ($Sprite.animation != 'flap'):
			$Sprite.animation = 'float'
		
	move_and_slide()
#
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print("I collided with ", collision.get_collider().name)
		
		if collision.get_collider().is_in_group("character"):
			#print("enemy collided with character | y:",collision.get_normal().y)
			var mob = collision.get_collider()
			
			velocity = velocity.bounce(collision.get_normal())
			
			
	#var collision = move_and_collide(velocity * delta)
	#if collision:
		#print("I collided with ", collision.get_collider().name)
		#if collision.get_collider().is_in_group("character"):
			#print("charbounce")
			#velocity = velocity.bounce(collision.get_normal())

func updateTarget():
	var characters = get_tree().get_nodes_in_group("character").filter(func(c): return c != self)
	if characters.size() < 1: return null
	target = characters.reduce(func(accum: Node, character: Node):
		var current_distance = get_global_position().distance_to(character.get_global_position())
		var accum_distance = get_global_position().distance_to(accum.get_global_position())
		if current_distance < accum_distance: return character
		else: return accum
	)
	lastUpdate = Time.get_ticks_msec()


func _on_sprite_animation_finished():
	if $Sprite.animation == 'flap':
		$Sprite.animation = 'float'

func _on_sprite_animation_changed():
	$Sprite.play()
