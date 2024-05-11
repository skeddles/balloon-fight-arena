extends Sprite2D

var rng = RandomNumberGenerator.new()
var direction = 0

const SPEED = 10
const LEFT_SIDE = -32 - 64
const RIGHT_SIDE = 672 + 64

func _ready():
	spawn()
	pass
	
func _process(delta):
	position.x += direction * delta * SPEED
	if position.x >= RIGHT_SIDE or position.x <= LEFT_SIDE: 
		spawn()
	
func spawn():
	position.y = randi_range(32,240)
	
	if (randf() > 0.5):
		position.x = LEFT_SIDE
		region_rect = Rect2(96, 160, 56, 40)
		direction = 1
	else:
		position.x = RIGHT_SIDE
		region_rect = Rect2(96, 120, 56, 40)
		direction = -1

