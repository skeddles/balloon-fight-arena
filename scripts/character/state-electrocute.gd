extends CharacterState

var char

func _init(character): 
	CAN_BOUNCE = false
	CAN_DIE_FROM_TILES = false
	CAN_GET_POPPED = false
	CAN_DROWN = false
	char = character

func start():
	char.get_node("Sprite").play("electrocute")
	var zap = char.get_node("Audio/Zap")
	char.collision_mask = 0
	zap.finished.connect(_on_zap_finished)
	zap.play()
	char.is_dead = true

func _on_zap_finished():
	char.switch_state("falling")
