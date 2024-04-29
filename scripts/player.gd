extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -75.0
const GRAVITY_MULTIPLIER = 0.5
const FRICTION = 0.75

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity*GRAVITY_MULTIPLIER * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		$Sprite.animation = 'flap'
		$Sprite.play()
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
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
		if ($Sprite.animation != 'flap'):
			$Sprite.animation = 'float'
		
	
		
	#var collision = move_and_collide(velocity * delta)
	#if collision:
		#print("I collided with ", collision.get_collider().name)
		#if collision.get_collider().is_in_group("character"):
			#print("charbounce")
			#velocity = velocity.bounce(collision.get_normal())
	print("v:",velocity,' | input:',Input.get_axis("ui_left", "ui_right"))
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print("I collided with ", collision.get_collider().name)
		
		if collision.get_collider().is_in_group("character"):
			print("\n[",i," collision with ",collision.get_collider().name,"] normal: ",collision.get_normal())
			var mob = collision.get_collider()
			
			var travel = collision.get_travel() 
			var remainder = collision.get_remainder()
			var newVel = (travel + remainder) / delta
			
			print ('travel: ',travel, " | remainder: ", remainder, " | newVel: ", newVel)
			
			velocity = newVel.bounce(collision.get_normal())
			print("new velocity",velocity)
			break
			
			# we check that we are hitting it from above.
			#if Vector2.UP.dot(collision.get_normal()) < -0.1:
				#print("is below")
				# If so, we squash it and bounce.
				#mob.squash()
				#target_velocity.y = bounce_impulse
				# Prevent further duplicate calls.


func _on_sprite_animation_finished():
	if $Sprite.animation == 'flap':
		$Sprite.animation = 'float'


func _on_sprite_animation_changed():
	$Sprite.play()


func checkCollisions(collision):
	if not collision: return

	print("collided with character", collision.get_collider())

	# If the collider is with a mob

func _on_balloons_animation_finished():
	if $Balloons.animation.ends_with("pop"):
		$Balloons.animation = 'float'
