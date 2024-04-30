extends CharacterBody2D

## The proper name of the character
@export var CharacterName:String
## Whether this character should be able to use a parachute while falling
@export var HasParachute:bool = false

var controller : Node

const SPEED = 100.0
const FLAP_VELOCITY = -100.0
const JUMP_VELOCITY = -50.0
const GRAVITY_MULTIPLIER = 0.2
const AIR_FRICTION = 1

var playerNumber:int

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_balloons = 4
var falling = false
var parachuting = false
var invincible = false

func init():
	$Balloons.animation = str(current_balloons) + "_idle"

func _draw():
	if controller:
		if controller.has_method("debugDraw"):
			controller.debugDraw(self)
		if "DEBUG" in controller and controller.DEBUG and invincible:
			draw_circle(Vector2(-15,-15),1,Color(0,1,1))

func _physics_process(delta):
	if controller and controller.has_method("debugDraw"): queue_redraw()
	if invincible && Time.get_ticks_msec() > invincible: invincible = false
	
	# Falling
	if falling:
		velocity.y += gravity * delta
		if position.y > 400: queue_free()
		return move_and_slide()
	# Falling with parachute
	elif parachuting:
		if is_on_floor():
			parachuting = false
			$Balloons.visible = false
		else:
			velocity.x = lerp(velocity.x,sin(Time.get_ticks_msec() / 500 ) * 32, 0.1)
			velocity.y += gravity*GRAVITY_MULTIPLIER*0.25 * delta
			if position.y > 360: queue_free()
			return move_and_slide()
	# Jumping without balloon
	elif not is_on_floor() and current_balloons == 0:
		velocity.y += gravity * delta
	# Floating with balloon
	elif not is_on_floor():
		velocity.y += gravity*GRAVITY_MULTIPLIER * delta
	
	if not controller: return move_and_slide()
	var input = controller.getInput(self)
	
	# Handle Jumping
	if input.jumped:
		if is_on_floor(): 
			if current_balloons > 0:
				velocity.y = JUMP_VELOCITY
			else:
				velocity.y = JUMP_VELOCITY*2
		elif current_balloons > 0: 
			$Sprite.animation = 'flap'
			$Sprite.play()
			velocity.y = lerp(velocity.y, FLAP_VELOCITY, 0.15)
	
	# Handle Movement
	if input.dirAxis:
		if is_on_floor():
			velocity.x = input.dirAxis * SPEED
		else:
			velocity.x = move_toward(velocity.x, input.dirAxis * SPEED, AIR_FRICTION)
		$Sprite.flip_h = input.dirAxis > 0
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, 1)
	
	# Play Animations
	if (is_on_floor()):
		if (velocity.x == 0): $Sprite.animation = 'idle'
		else: $Sprite.animation = 'walk'
	else:
		if ($Sprite.animation != 'flap'): $Sprite.animation = 'float'
	
	# Move
	move_and_slide()
	
	# Check Collisions
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print("I collided with ", collision.get_collider().name)
		var collider = collision.get_collider()
		if collider.is_in_group("character"):
			if (falling): break
			if current_balloons == 0 and !falling:
				startFalling()
				break
			var normal = collision.get_normal()
			print("\n[",i," collision with ",collider.name,"] normal: ",normal, " | dot: ", Vector2.UP.dot(normal))
			
			var travel = collision.get_travel() 
			var remainder = collision.get_remainder()
			var newVel = (travel + remainder) / delta
			
			print ('travel: ',travel, " | remainder: ", remainder, " | newVel: ", newVel)
			
			velocity = newVel.bounce(collision.get_normal())
			print("new velocity",velocity)	
			break

func loseBalloon ():
	print("POOOPPPPPPPPPPPPPPPPPPPPPPPPPP",name)
	$Balloons.animation = str(current_balloons) + "_pop"
	current_balloons -= 1
	if current_balloons < 0: printerr("current_balloons dropped below 0, should be impossible", name, current_balloons)
	$Audio/Pop.playing = true
	if current_balloons == 0:
		if HasParachute:
			$Sprite.animation = "parachute"
			$Balloons.animation = "parachute"
			parachuting = true
			invincible = Time.get_ticks_msec() + 500
		else:
			startFalling()
	else:
		invincible = Time.get_ticks_msec() + 1000

func startFalling():
	if (falling): return
	print("start falling...")
	falling = true
	collision_mask = 0
	$Sprite.animation = "fall"
	$Audio/Falling.play(0)

func _on_sprite_animation_finished():
	if $Sprite.animation == 'flap':	$Sprite.animation = 'float'

func _on_sprite_animation_changed():
	$Sprite.play()
	
func _on_balloons_animation_changed():
	$Balloons.play()
	
func _on_balloons_animation_finished():
	print("finito",$Balloons.animation)
	if $Balloons.animation.ends_with("pop"):
		if (current_balloons > 0):
			$Balloons.animation = str(current_balloons) + "_idle"
		else:
			$Balloons.visible = false

func _on_balloon_area_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	print("balloon shape entered", body.name)
	
func _on_balloon_area_area_entered(area):
	if invincible: return
	if current_balloons == 0: startFalling()
	var otherCharacter = area.get_parent()
	if otherCharacter.falling or otherCharacter.parachuting or otherCharacter.current_balloons < 1: return
	if area.name == "FeetArea": 
		print("balloon area entered", area.name)
		
		#position.angle_to(otherCharacter.position)
		var collision_angle = position.angle_to(otherCharacter.position)
		# Calculate the bounce angles for each character
		var bounce_angle1 = collision_angle + PI / 2  # 90 degrees offset
		var bounce_angle2 = collision_angle - PI / 2  # -90 degrees offset

		# Set the velocities based on the bounce angles and desired speed
		velocity = Vector2(cos(bounce_angle1), sin(bounce_angle1)) * 40
		otherCharacter.velocity = Vector2(cos(bounce_angle2), sin(bounce_angle2)) * 75
		
		loseBalloon()

