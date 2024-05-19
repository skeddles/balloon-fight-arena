extends CharacterState

var char
var Sprite
var gravity
var JumpHeight
var TopLandSpeed
var LandFriction

func _init(character): 
	CAN_POP_OTHERS = true
	CAN_GET_POPPED = false
	CAN_DIE_FROM_TOUCH = true
	char = character


func start():
	Sprite = char.Sprite
	gravity = char.gravity
	JumpHeight = char.JumpHeight
	TopLandSpeed = char.TopLandSpeed
	LandFriction = char.LandFriction
	char.get_node("Balloons").animation = "0_idle"
	char.switchCollisionShape()
	print(char.CharacterName, " im goin balloonless ", TopLandSpeed, " / ", LandFriction)

func process(delta, input):
	if char.is_on_floor():
		if not input.dirAxis: 
			char.velocity.x = lerp(char.velocity.x, 0.0, LandFriction)
	else:
		char.velocity.y += gravity * delta
		

func _update_animation():
	if char.is_on_floor():
		if abs(char.velocity.x) < 25: Sprite.animation = 'idle'
		else: Sprite.animation = 'walk'
	else:
		if (Sprite.animation != 'flap'): Sprite.animation = 'float'


func _on_move(input):
	char.Sprite.flip_h = input.dirAxis > 0
	char.velocity.x = lerp(char.velocity.x, input.dirAxis * TopLandSpeed, 0.1)

func _on_jump(_input):
	if char.is_on_floor():
		char.velocity.y = (-JumpHeight) * 2

func _on_attack():
	if char.HasDropping and not char.is_on_floor():
		char.switch_state("dropping")
