extends CharacterState

var char
var droppingStartY = 0
var gravity

func _init(character): 
	CAN_POP_OTHERS = true
	char = character
	gravity = char.gravity

func start():
	char.current_balloons = 0
	droppingStartY = char.position.y 
	char.velocity = Vector2(0, 50)
	char.get_node("Sprite").play("dropping")
	char.get_node("Balloons").animation = "0_idle"
	char.get_node("Audio/Drop").play()

func process(delta, _input):
	print ("dropping dueces ",  char.position.y - droppingStartY > char.DroppingDistance)
	
	char.velocity.y += gravity*char.DroppingGravity * delta
	
	if char.position.y - droppingStartY > char.DroppingDistance: char.switch_state("falling")
	if char.position.y > 400: char.queue_free()
		
	for i in char.get_slide_collision_count():
		var collision = char.get_slide_collision(i)
		var collider = collision.get_collider()

func _on_landing(delta):
	char.switch_state("normal")
