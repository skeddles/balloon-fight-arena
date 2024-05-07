extends CharacterBody2D
class_name Character
## The PNG of this character's sprite sheet
@export var SpriteSheet:CompressedTexture2D



@export_group("Character Source")
## The proper name of the character
@export var CharacterName:String
## The name of the game or media this character came from
@export var CharacterSource:String
enum characterSourceTypes {Game,Interpretation,RelatedGame,RomHack,FanGame,Original}
## The type of media that the source is
@export var CharacterSourceType:characterSourceTypes
## The name of the original artist that created this sprite (or its source), if known
@export var OriginalArtist:String


@export_group("Character Abilities")
## Whether this character should be able to use a parachute while falling
@export var HasParachute:bool = false
@export var ParachuteGravity:float = 0.1
@export var HasDropping:bool = false
@export var DroppingGravity:float = 0.9
@export var DroppingDistance:int = 999

@export_group("Character Stats")
# How quickly the player comes to a stop after letting go of run button (0.0-0.1)
@export var LandFriction:float = 0.2
# The fastest this character can travel while in the air
@export var TopAirSpeed:float = 100
# The fastest this character can travel while on the ground
@export var TopLandSpeed:float = 100
# The vertical speed attained when this character jumps off the ground
@export var JumpHeight:float = 50
# The amount of gravity the character expiriences when they have at least 1 balloon (multiplied with the normal gravity)
@export var BalloonGravity:float = 0.4
# The percentage of their full TopAirSpeed that the character reaches with each flap
@export var FlapStrength:float = 0.2

# set by code on setup
var controller:Node
var playerHUD:PlayerHUD
var playerNumber:int
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# player state variables
var current_balloons = 0
var stored_balloons = 0
var falling = false
var parachuting = false
var invincible = false
var current_fill_amount = 0
var dropping = false
var droppingStartY = 0

func _physics_process(delta):
	if DEBUG or (controller and controller.has_method("debugDraw")): queue_redraw()
	if invincible && Time.get_ticks_msec() > invincible: invincible = false
	
	# Falling
	if falling:
		velocity.y += gravity * delta
		if position.y > 400: queue_free()
		return move_and_slide()
	# Falling with parachute
	elif parachuting and not is_on_floor():
		velocity.x = lerp(velocity.x,sin(Time.get_ticks_msec() / 500 ) * 32, 0.1)
		velocity.y += gravity*ParachuteGravity * delta
		if position.y > 400: queue_free()
		return move_and_slide()
	# Dropping
	elif dropping:
		print ("dropping dueces ",  position.y - droppingStartY > DroppingDistance)
		if position.y - droppingStartY > DroppingDistance:
			startFalling()
		else:
			velocity.y += gravity*DroppingGravity * delta
			if position.y > 400: queue_free()
	# Jumping without balloon
	elif not is_on_floor() and current_balloons == 0:
		velocity.y += gravity * delta
	# Floating with balloon
	elif not is_on_floor():
		velocity.y += gravity*BalloonGravity * delta
	
	if not controller: return move_and_slide()
	var input = controller.getInput(self)
	
	# Handle Jumping / Flapping
	if input.jumped and not falling and not dropping and not parachuting:
		if is_on_floor(): 
			if current_balloons > 0:
				velocity.y = -JumpHeight
			else:
				velocity.y = (-JumpHeight) * 2
		elif current_balloons > 0: 
			$Sprite.animation = 'flap'
			$Sprite.play()
			velocity.y = lerp(velocity.y, -TopAirSpeed, FlapStrength)
	
	# Balloon Filling
	var filling=false
	if $Sprite.animation == 'refill': filling = true
	if input.fill and is_on_floor() and velocity.x < 5:
		if $Sprite.animation != 'refill' or !$Sprite.is_playing():
			if stored_balloons > 0 and current_balloons < 4:
				current_fill_amount+=1
				filling = true
				$Audio/Fill.play()
				$Sprite.play("refill")
				if current_fill_amount>2: $BalloonFilling.play("fill_2")
				else: $BalloonFilling.play("fill_1")
			else: # TODO play nono sound effect
				pass
	if input.dirAxis or input.jumped:
		current_fill_amount = 0
		filling=false
		$BalloonFilling.play("blank")
		
	# Handle Movement
	if input.dirAxis:
		$Sprite.flip_h = input.dirAxis > 0
		if is_on_floor():
			velocity.x = input.dirAxis * TopLandSpeed
		elif input.jumped:
			velocity.x = lerp(velocity.x, input.dirAxis * TopAirSpeed, 0.2)
	elif is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, LandFriction)

	# Handle Special Ability Actions
	if input.action:
		if HasDropping:
			if not is_on_floor() and current_balloons > 0 and not dropping and not parachuting:
				dropping = true
				current_balloons = 0
				droppingStartY = position.y 
				velocity.x = 0
				velocity.y = 50
				$Sprite.play("dropping")
				print(CharacterName, " play dropping?", $Sprite.animation)
				$Balloons.animation = "0_idle"
				$Audio/Drop.play()
				


	# Play Animations
	if is_on_floor():
		if filling: $Sprite.animation = 'refill'
		elif abs(velocity.x) < 25: $Sprite.animation = 'idle'
		else: $Sprite.animation = 'walk'
	elif not parachuting and not dropping:
		if ($Sprite.animation != 'flap'): $Sprite.animation = 'float'
		print(CharacterName, " play dropping?", $Sprite.animation)
	
	# Move
	move_and_slide()

	# Check Collisions
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var localShape = collision.get_local_shape()
		var otherShape = collision.get_collider_shape()
		#print(CharacterName, " shape ",	localShape, " disabled:",localShape.disabled)
		if localShape.disabled or (otherShape and otherShape.disabled): continue
		var collider = collision.get_collider()
		#print(CharacterName, "I collided with ", collider.name, ' [is in bounce group: ', collider.is_in_group("ground"),"]")
		if collider.is_in_group("character"):
			if (falling): break
			if current_balloons == 0 and not falling and not dropping:
				print(CharacterName, "i should die", falling, dropping)
				startFalling()
				break
			if collider.current_balloons == 0 and !collider.falling and !dropping:
				print(CharacterName, "you should die")
				collider.startFalling()
			
			bounce(collision, delta)
			break
		elif collider.is_in_group("bounce") and not is_on_floor():
			bounce(collision, delta)
			break
		elif collider.is_in_group("ground") and is_on_floor():
			if dropping:
				print("stop drop and roll")
				dropping = false
				$Sprite.animation = "0_idle"
			if falling:
				parachuting = false
				$Balloons.animation = "0_idle"
		elif collider.is_in_group("water"):
			$Audio/Drown.play()
			splash()
			falling = true
			playerHUD.update()
			break

func bounce(collision, delta):
	var normal = collision.get_normal()
	#print("\n[",i," collision with ",collider.name,"] normal: ",normal, " | dot: ", Vector2.UP.dot(normal))
	var travel = collision.get_travel() 
	var remainder = collision.get_remainder()
	var newVel = (travel + remainder) / delta
	velocity = newVel.bounce(collision.get_normal())
	#print ('travel: ',travel, " | remainder: ", remainder, " | newVel: ", newVel, " | bouncedVel: ", velocity)
	$Audio/Bounce.play()
	
func loseBalloon ():
	print(CharacterName, "POOOPPPPPPPPPPPPPPPPPPPPPPPPPP",name)
	$Balloons.animation = str(current_balloons) + "_pop"
	current_balloons -= 1
	if current_balloons < 0: printerr(CharacterName, "current_balloons dropped below 0, should be impossible", name, current_balloons)
	$Audio/Pop.playing = true
	if current_balloons == 0:
		switchCollisionShape()
		if is_on_floor():
			$Sprite.animation = "idle_0"
			$Balloons.animation = "blank"
		elif HasParachute:
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
	print(CharacterName, "start falling...")
	falling = true
	dropping = false
	collision_mask = 0
	velocity.x = 0
	velocity.y = -50
	$Sprite.play("fall")
	$Audio/Falling.play(0)
	playerHUD.update()

func _on_sprite_animation_finished():
	if $Sprite.animation == 'flap':	
		$Sprite.animation = 'float'
	if $Sprite.animation == 'refill':
		if stored_balloons > 0 and current_fill_amount>=4:
			current_fill_amount = 0
			stored_balloons -= 1
			current_balloons += 1
			playerHUD.update()
			switchCollisionShape()
			$BalloonFilling.play("blank")
			$Balloons.animation = str(current_balloons) + "_idle"
			$Audio/Filled.play()

func _on_sprite_animation_changed():
	$Sprite.play()
	
func _on_balloons_animation_changed():
	$Balloons.play()
	
func _on_balloons_animation_finished():
	print(CharacterName, "finito",$Balloons.animation)
	if $Balloons.animation.ends_with("pop"):
		$Balloons.animation = str(current_balloons) + "_idle"


func _on_balloon_area_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	print(CharacterName, " balloon shape entered", body.name)
	
func _on_balloon_area_area_entered(area):
	var otherCharacter = area.get_parent()
	print(CharacterName, " my balon pop?! thanks ", otherCharacter.CharacterName)
	if invincible or current_balloons == 0 or otherCharacter.falling: return
	#used to be if otherCharacter.falling or otherCharacter.parachuting or otherCharacter.current_balloons < 1: return
	if area.name == "FeetArea": 
		print(CharacterName, " balloon area entered", area.name)
		
		#position.angle_to(otherCharacter.position)
		var collision_angle = position.angle_to(otherCharacter.position)
		# Calculate the bounce angles for each character
		var bounce_angle1 = collision_angle + PI / 2  # 90 degrees offset
		var bounce_angle2 = collision_angle - PI / 2  # -90 degrees offset

		# Set the velocities based on the bounce angles and desired speed
		velocity = Vector2(cos(bounce_angle1), sin(bounce_angle1)) * 40
		otherCharacter.velocity = Vector2(cos(bounce_angle2), sin(bounce_angle2)) * 75
		loseBalloon()

func switchCollisionShape():
	print(CharacterName, " switching collision shape",current_balloons == 0)
	if current_balloons == 0:
		$HasBallonsCollisionShape.set_deferred("disabled", true)
		$NoBallonsCollisionShape.set_deferred("disabled", false)
	else:
		$HasBallonsCollisionShape.set_deferred("disabled", false)
		$NoBallonsCollisionShape.set_deferred("disabled", true)
	
	print(CharacterName, "$HasBallonsCollisionShape.disabled",$HasBallonsCollisionShape.disabled)
	print(CharacterName, "$NoBallonsCollisionShape.disabled",$NoBallonsCollisionShape.disabled)


func init():
	$Balloons.animation = str(current_balloons) + "_idle"
	update_texture($Sprite, SpriteSheet)
	update_texture($Balloons, SpriteSheet)

# changes a sprite texture at the beginning of the match
func update_texture(sprite: AnimatedSprite2D, texture: Texture2D):
	var reference_frames := sprite.sprite_frames
	var updated_frames := SpriteFrames.new()

	for animation_name in reference_frames.get_animation_names():
		if animation_name != "default":
			updated_frames.add_animation(animation_name)
			updated_frames.set_animation_speed(animation_name, reference_frames.get_animation_speed(animation_name))
			updated_frames.set_animation_loop(animation_name, reference_frames.get_animation_loop(animation_name))

			for i in range(reference_frames.get_frame_count(animation_name)):
				var original_frame := reference_frames.get_frame_texture(animation_name, i) as AtlasTexture
				var updated_texture := original_frame.duplicate() as AtlasTexture
				updated_texture.atlas = texture

				# Copy the region from the original frame
				updated_texture.region = original_frame.region

				# Find the index of the frame with the matching texture
				var frame_index := -1
				for j in range(updated_frames.get_frame_count(animation_name)):
					if updated_frames.get_frame_texture(animation_name, j) == original_frame:
						frame_index = j
						break

				# If the frame is found, update it
				if frame_index != -1:
					updated_frames.set_frame(animation_name, frame_index, updated_texture)
				else:
					# Add the frame with the correct duration if not found
					updated_frames.add_frame(animation_name, updated_texture, reference_frames.get_frame_duration(animation_name, i))

	updated_frames.remove_animation("default")
	sprite.sprite_frames = updated_frames
	sprite.play() # Ensure the animation plays
	
const DEBUG = false
@onready var default_font = ThemeDB.fallback_font
func _draw():
	if controller:
		if controller.has_method("debugDraw"):
			controller.debugDraw(self)
	if DEBUG:
		if invincible: draw_circle(Vector2(-15,-15),1,Color(0,1,1))
		draw_string(default_font, Vector2(10, -5), str(current_balloons), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
		if !$HasBallonsCollisionShape.disabled: draw_string(default_font, Vector2(10, 5),'c:has', HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
		if !$NoBallonsCollisionShape.disabled: draw_string(default_font, Vector2(10, 5),'c:no', HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
		if current_fill_amount > 0:
			draw_string(default_font, Vector2(0, -15), str(current_fill_amount), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
	
func _on_drown_finished():
	queue_free()

func splash():
	var sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = load("res://art/fx/splash.tres")
	sprite.connect("animation_finished", Callable(delete_on_animation_complete).bind(sprite))
	sprite.position = Vector2(position.x,310)
	sprite.play("splash")
	get_tree().root.add_child(sprite)
func delete_on_animation_complete(e): e.queue_free()
