extends CharacterState

var Character
var gravity
var ParachuteGravity

func _init(character): 
	Character = character


func start():
	gravity = Character.gravity
	ParachuteGravity = Character.ParachuteGravity
	
	print(Character.CharacterName, " started parachuting")
	Character.get_node("Sprite").animation = "parachute"
	Character.get_node("Balloons").animation = "parachute"
	Character.go_invincible(500)

func process(delta, _input):
	if not Character.is_on_floor():
		Character.velocity.x = lerp(Character.velocity.x,sin(Time.get_ticks_msec() / 500 ) * 32, 0.1)
		Character.velocity.y += gravity*ParachuteGravity * delta
		if Character.position.y > 400: Character.queue_free()

func _on_landing():
	Character.switch_state("balloonless")
	print("2end parachute")

func collide(_collision, collider):
	print("parachute collide")
	if collider.is_in_group("ground") and Character.is_on_floor():
		Character.switch_state("balloonless")
		print("end parachute")
