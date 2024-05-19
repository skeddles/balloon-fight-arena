extends CharacterState

var char
func _init(character): 
	CAN_BOUNCE = false
	CAN_DIE_FROM_TILES = false
	CAN_GET_POPPED = false
	CAN_DROWN = false
	char = character

func start():
	print(char.CharacterName, "start falling...")
	char.current_balloons = 0
	char.collision_mask = 0
	char.velocity.x = 0
	char.velocity.y = -50
	char.get_node("Sprite").play("fall")
	char.get_node("Audio/Falling").play(0)
	char.is_dead = true
	char.playerHUD.update()
	

func process(delta, _input):
	char.velocity.y += char.gravity * delta
	if char.position.y > 400: 
		char.queue_free()
		print(char.CharacterName," character fell off screen")
	else:
		char.move_and_slide()

	
