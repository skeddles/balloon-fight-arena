extends CharacterBody2D
class_name Character

var update_texture = preload("res://scripts/util/update-texture.gd").new()

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
var playerHUD
var playerNumber:int
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Nodes
@onready var Sprite = get_node("Sprite")

# player state variables
var current_balloons = 0
var stored_balloons = 0
var invincible = false
var invincible_until = 0
var is_dead = false

var state = {
	falling = preload("res://scripts/character/state-falling.gd").new(self),
	electrocute = preload("res://scripts/character/state-electrocute.gd").new(self),
	parachute = preload("res://scripts/character/state-parachute.gd").new(self),
	dropping = preload("res://scripts/character/state-dropping.gd").new(self),
	normal = preload("res://scripts/character/state-normal.gd").new(self),
	balloonless = preload("res://scripts/character/state-balloonless.gd").new(self),
	#filling = preload("res://scripts/character/state-filling.gd").new(self),
}
var current_state:CharacterState

func switch_state(stateName:String):
	print(CharacterName, " switching state to ",stateName)
	current_state = state[stateName]
	current_state.name = stateName
	if "start" in current_state: current_state.start()
	return current_state

func _physics_process(delta):
	if DEBUG or (controller and controller.has_method("debugDraw")): queue_redraw()
	if not controller: return
	if invincible && Time.get_ticks_msec() > invincible_until: invincible = false
	
	var input = controller.getInput(self)
	
	if "process" in current_state: current_state.process(delta, input)

	if "_on_jump" in current_state 		and input.jumped:	current_state._on_jump(input)
	if "_on_move" in current_state  	and input.dirAxis: 	current_state._on_move(input)
	if "_on_attack" in current_state  	and input.action: 	current_state._on_attack()

	move_and_slide()
	
	if "_update_animation" in current_state: current_state._update_animation()

	# Check Collisions
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var localShape = collision.get_local_shape()
		#print(CharacterName, " shape ",	localShape, " disabled:",localShape.disabled)
		#if localShape.disabled or (otherShape and otherShape.disabled): continue
		#print(CharacterName, "I collided with ", collider.name, ' [is in bounce group: ', collider.is_in_group("ground"),"]")	
		
		if current_state.CAN_DIE_FROM_TILES:
			if collider is TileMap:
				var coords = collider.get_coords_for_body_rid(collision.get_collider_rid())
				var tiledata = collider.get_cell_tile_data(0,coords)
				if tiledata.get_custom_data("Kill"): 
					bounce(collision, delta, 25)
					loseBalloon()
					break
			if collider.is_in_group("electrocute"):
				switch_state("electrocute")
				collider.queue_free()
				break
		if collider.is_in_group("character"):
			if current_state.CAN_DIE_FROM_TOUCH:
				print(CharacterName, " i should die ")
				switch_state("falling")
				break
			if collider.current_state.CAN_DIE_FROM_TOUCH:
				print(CharacterName, " you should die ", collider.CharacterName)
				collider.switch_state("falling")
			bounce(collision, delta,50)
			break
		if collider.is_in_group("bounce") and not is_on_floor():
			var otherShape = collision.get_collider_shape()
			if otherShape and otherShape.is_in_group("ceiling"):
				bounce(collision, delta, 100)
			bounce(collision, delta, 50)
			break
		if collider.is_in_group("ground") and is_on_floor() and "_on_landing" in current_state:
			current_state._on_landing()
			break
		if current_state.CAN_DROWN and collider.is_in_group("water"):
			$Audio/Drown.play()
			splash()
			switch_state("falling")
			playerHUD.update()
			break

func bounce(collision, delta, minimumSpeed):
	var normal = collision.get_normal()
	#print("\n[",i," collision with ",collider.name,"] normal: ",normal, " | dot: ", Vector2.UP.dot(normal))
	var travel = collision.get_travel() 
	var remainder = collision.get_remainder()
	var newVel = (travel + remainder) / delta
	velocity = newVel.bounce(collision.get_normal())
	#print ('travel: ',travel, " | remainder: ", remainder, " | newVel: ", newVel, " | bouncedVel: ", velocity)
	if velocity.length() < minimumSpeed: velocity = minimumSpeed * normal
	$Audio/Bounce.play()
	
func loseBalloon ():
	if invincible: return
	if current_balloons == 0:
		switch_state("falling")
	print(CharacterName, "'s Balloon Popped")
	$Balloons.animation = str(current_balloons) + "_pop"
	current_balloons -= 1
	if current_balloons < 0: printerr(CharacterName, "current_balloons dropped below 0, should be impossible", name, current_balloons)
	$Audio/Pop.playing = true
	if current_balloons == 0:
		print(CharacterName, " out of balloons")
		switchCollisionShape()
		if is_on_floor():
			print(CharacterName, " out of balloons - but on floor")
			switch_state("balloonless")
		elif HasParachute:
			print(CharacterName, " out of balloons - but has parachute")
			switch_state("parachute")
		else:
			print(CharacterName, " out of balloons - is ded")
			switch_state("falling")
	else:
		print("made invincible")
		go_invincible(1000)

func _on_sprite_animation_finished():
	if "_on_sprite_animation_finished" in current_state: current_state._on_sprite_animation_finished()

func _on_sprite_animation_changed(): $Sprite.play()
	
func _on_balloons_animation_changed(): $Balloons.play()
	
func _on_balloons_animation_finished():
	print(CharacterName, "finito",$Balloons.animation)
	if $Balloons.animation.ends_with("pop"):
		$Balloons.animation = str(current_balloons) + "_idle"


func _on_balloon_area_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	print(CharacterName, " balloon shape entered", body.name)


func _on_balloon_area_area_entered(area):
	if not current_state.CAN_GET_POPPED: return
	var otherCharacter = area.get_parent()
	print(CharacterName, " my balon pop?! thanks ", otherCharacter.CharacterName)
	if invincible or not current_state.CAN_GET_POPPED or not otherCharacter.current_state.CAN_POP_OTHERS: return
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
	$HasBallonsCollisionShape.set_deferred("disabled", current_balloons == 0)
	$NoBallonsCollisionShape.set_deferred("disabled", current_balloons > 0)


func go_invincible(ms):
	invincible = true
	invincible_until = Time.get_ticks_msec() + ms


func init():
	$Balloons.animation = str(current_balloons) + "_idle"
	update_texture.update_texture($Sprite, SpriteSheet)
	update_texture.update_texture($Balloons, SpriteSheet)
	switch_state("normal")


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



const DEBUG = false
@onready var default_font = ThemeDB.fallback_font
func _draw():
	if controller:
		if controller.has_method("debugDraw"):
			controller.debugDraw(self)
	if DEBUG:
		if invincible: draw_circle(Vector2(-15,-15),1,Color(0,1,1))
		#draw_string(default_font, Vector2(10, -5), str(current_balloons), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
		draw_string(default_font, Vector2(-10, -15), str(current_state.name), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
		#if !$HasBallonsCollisionShape.disabled: draw_string(default_font, Vector2(10, 5),'c:has', HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
		#if !$NoBallonsCollisionShape.disabled: draw_string(default_font, Vector2(10, 5),'c:no', HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
		#if current_fill_amount > 0:
		#	draw_string(default_font, Vector2(0, -15), str(current_fill_amount), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
	
