extends CharacterBody2D

# The proper name of the character
@export var CharacterName:String

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
var invincible = false

func init():
	print("READY")
	$Balloons.animation = str(current_balloons) + "_idle"

func _draw():
	if controller and controller.has_method("debugDraw"):
		controller.debugDraw(self)
	if invincible:
		draw_circle(Vector2(-15,-15),1,Color(0,1,1))

func _physics_process(delta):
	if controller and controller.has_method("debugDraw"): queue_redraw()
	
	if invincible && Time.get_ticks_msec() > invincible: invincible = false
	
	# Add the gravity.
	if falling:
		velocity.y += gravity * delta
		if position.y > 360: queue_free()
		return move_and_slide()
	elif not is_on_floor():
		velocity.y += gravity*GRAVITY_MULTIPLIER * delta
	
	if not controller: return move_and_slide()
	var input = controller.getInput(self)
	
	# Handle Jumping
	if input.jumped:
		$Sprite.animation = 'flap'
		$Sprite.play()
		if is_on_floor(): velocity.y = JUMP_VELOCITY
		else: velocity.y = lerp(velocity.y, FLAP_VELOCITY, 0.15)
	
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
		
		if collision.get_collider().is_in_group("character"):
			print("\n[",i," collision with ",collision.get_collider().name,"] normal: ",collision.get_normal(), " | dot: ", Vector2.UP.dot(collision.get_normal()))
			
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
	$Audio/Pop.playing = true
	if current_balloons == 0:
		falling = true
		collision_mask = 0
		$Sprite.animation = "fall"
	else:
		invincible = Time.get_ticks_msec() + 1000
	

func _on_sprite_animation_finished():
	if $Sprite.animation == 'flap':	$Sprite.animation = 'float'

func _on_sprite_animation_changed():
	$Sprite.play()
	
func _on_balloons_animation_changed():
	$Balloons.play()
	
func _on_balloons_animation_finished():
	print("finito",$Balloons.animation)
	if current_balloons && $Balloons.animation.ends_with("pop"):
		$Balloons.animation = str(current_balloons) + "_idle"

func _on_balloon_area_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	print("balloon shape entered", body.name)
	
func _on_balloon_area_area_entered(area):
	if not invincible:
		if area.name == "FeetArea": 
			print("balloon area entered", area.name)
			loseBalloon()
