extends CharacterState

var char
var Sprite
var gravity
var BalloonGravity
var JumpHeight
var TopAirSpeed
var TopLandSpeed
var FlapStrength
var LandFriction

func _init(character): 	
	CAN_POP_OTHERS = true
	char = character


func start():
	gravity = char.gravity
	BalloonGravity = char.BalloonGravity
	JumpHeight = char.JumpHeight
	TopAirSpeed = char.TopAirSpeed
	TopLandSpeed = char.TopLandSpeed
	FlapStrength = char.FlapStrength
	LandFriction = char.LandFriction
	
	print("started normal state ", Sprite)
	Sprite = char.Sprite
	if char.current_balloons == 0: char.switch_state("balloonless")

func process(delta, input):
	if char.is_on_floor():
		if not input.dirAxis:
			char.velocity.x = lerp(char.velocity.x, 0.0, LandFriction)
	else:
		char.velocity.y += gravity * BalloonGravity * delta

func _on_move(input):
	char.Sprite.flip_h = input.dirAxis > 0
	if char.is_on_floor():
		char.velocity.x = lerp(char.velocity.x, input.dirAxis * TopLandSpeed, 0.1)

func _on_jump(input):
	if char.is_on_floor():
		char.velocity.y = -JumpHeight
	else:
		char.Sprite.play('flap')
		char.velocity.y = lerp(char.velocity.y, -TopAirSpeed, FlapStrength)
		if input.dirAxis:
			char.velocity.x = lerp(char.velocity.x, input.dirAxis * TopAirSpeed, 0.2)

func _on_attack():
	if char.HasDropping and not char.is_on_floor():
		char.switch_state("dropping")

func _update_animation():
	if char.is_on_floor():
		if abs(char.velocity.x) < 25: Sprite.animation = 'idle'
		else: Sprite.animation = 'walk'
	else:
		if (Sprite.animation != 'flap'): Sprite.animation = 'float'

func _on_sprite_animation_finished():
	if Sprite.animation == 'flap':	
		Sprite.animation = 'float'
